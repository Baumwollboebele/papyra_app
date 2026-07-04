# ARCHITECTURE.md — Papyra

This document describes the structure of the app, the data flow through the scan pipeline, the persistence layer, and the **extension points** designed for the Phase 2 roadmap.

## Guiding principles

1. **Local-first & offline.** The app never opens a socket. All state lives in SQLite (drift) and files under the app's private documents directory. This is a product requirement (privacy) and a testability win.
2. **Feature-first modularity.** Each feature is a vertical slice (`data / domain / presentation`). Cross-feature code lives in `core/`. A feature never imports another feature's `presentation`; shared contracts live in `core/` or a feature's `domain`.
3. **Pure domain core.** The classifier and metadata extractors are plain Dart — no Flutter, no plugins. This makes them exhaustively unit-testable and swappable (rule-based today, LLM tomorrow) behind a stable interface.
4. **Repository pattern.** Riverpod providers expose repositories; widgets and controllers depend on repository interfaces, not on drift.
5. **Off-main-thread heavy work.** OCR, classification, thumbnailing and PDF generation run through `compute`/isolates so the UI stays at 60fps and can show skeletons/progress.

## Directory layout

```
lib/
  core/
    database/        # drift database, DAOs, connection factory (native + test)
    theme/           # Material 3 theme, deep-teal seed, Inter text theme
    router/          # go_router configuration, route names
    l10n/            # BuildContext extension for AppLocalizations
    services/        # cross-cutting: app-lock (local_auth), secure storage, files,
                     #   ocr (plugin wrapper), scanner (plugin wrapper), pdf, backup
    formatting/      # intl-based date/number/currency helpers (de/en)
    widgets/         # shared widgets: skeletons, empty states, custom-painted illustrations
    providers/       # app-wide Riverpod providers (db, repos, settings)
  features/
    onboarding/
      presentation/  # onboarding pages + controller, "seen" flag in secure storage
    scan/
      data/          # scanner + ocr wrappers behind interfaces
      domain/
        classification/   # PURE DART: classifier, extractors, models  <-- LLM swap point
        pipeline/         # orchestrates scan -> ocr -> classify -> extract -> persist
      presentation/  # review page, pipeline progress, confirmation form
    library/
      data/          # (uses core repositories)
      domain/
      presentation/  # home grid, category list, document detail
    search/
      presentation/  # search page, filters, results with highlighting
    settings/
      presentation/  # settings, category management, backup/restore, privacy page
  l10n/              # app_de.arb (template/base), app_en.arb
  main.dart
```

## Data model (drift)

Tables (see `core/database/`):

- **categories** — `id, key, name, iconName, colorValue, isDefault, sortOrder`. Seeded with the 9 defaults; `key` is a stable identifier the classifier maps to.
- **documents** — `id, title, categoryId(FK), sender, documentDate, createdAt, amountCents(nullable), currency, pdfPath, thumbnailPath, ocrText, isFavorite, pageCount`.
- **document_pages** — `id, documentId(FK), pageIndex, imagePath`.
- **tags** — `id, name(unique)`.
- **document_tags** — `documentId, tagId` (m:n).
- **documents_fts** — FTS5 virtual table over `title, sender, ocrText, tags`. Kept in sync from the repository layer (insert/update/delete mirror writes) so the search index always matches the row. FTS row ids equal document ids.

Rationale for repository-driven FTS sync (vs. SQL triggers): the indexed `tags` column aggregates a m:n relation, which is awkward and brittle in triggers; doing it in one place in Dart is clearer and unit-testable.

## The scan pipeline

`features/scan/domain/pipeline/` orchestrates, with progress surfaced to the UI:

```
NativeScanner (VisionKit / ML Kit)          -> List<page image paths>
  -> Review UI (retake / reorder / delete)
  -> OCR (google_mlkit_text_recognition)    -> per-page text  [off-main-thread]
  -> Classifier (pure Dart)                 -> categoryKey + confidence
  -> Extractors (pure Dart)                 -> title, sender, date, amount, IBAN
  -> Confirmation UI (user edits everything; low confidence pre-selects "Sonstiges")
  -> Persist: generate searchable PDF + thumbnail (isolate), write files,
     insert document + pages + tags, mirror into FTS
```

Each external dependency (scanner, OCR) sits behind an interface in `features/scan/data/`, with the plugin implementation injected via a Riverpod provider. Tests use fakes.

### Classification & extraction (the swap point)

`domain/classification/` exposes:

- `DocumentClassifier` — interface: `ClassificationResult classify(String ocrText)`.
- `RuleBasedClassifier` — German keyword scoring into the 9 categories, returns best category + normalized confidence + per-category scores.
- `MetadataExtractor` — pure functions: German dates (`dd.MM.yyyy` and `12. März 2026`), amounts (`1.234,56 €`, preferring values near `Gesamtbetrag`/`Rechnungsbetrag`/`zu zahlen`), IBAN, sender heuristic (letterhead + legal-form boost).

Because these are pure and interface-backed, Phase 2 can drop in an `LlmClassifier` implementing `DocumentClassifier` with zero changes to the pipeline or persistence. See "Phase 2 extension points".

## State management

`flutter_riverpod`. Conventions:

- `Provider` for singletons (database, repositories, services).
- `AsyncNotifier` / `Notifier` for screen controllers and derived state.
- No `BuildContext` in domain/data. UI reads providers; controllers call repositories.

## Navigation

`go_router`. Routes are named constants in `core/router/`. Top-level shell hosts Library (home), Search, Settings; Scan is a pushed flow. Document detail uses a Hero transition from the list thumbnail.

## Theming & localization

- Material 3, `ColorScheme.fromSeed(seedColor: deepTeal)`, light + dark, Inter bundled locally (OFL) — no runtime font fetch.
- `gen_l10n` with `app_de.arb` as template. `intl` provides all date/number/currency formatting; the app forces formatting to the active locale.

## Error handling strategy

Every failure path yields a **German** message and a way forward, never a crash:

- Camera permission denied → rationale + button to open system settings.
- Scanner cancelled → silently return to previous screen.
- OCR failure → save the document anyway with empty text + a non-blocking notice.
- Low storage / file write failure → explain and abort the save cleanly (no partial rows).
- Restore of an incompatible backup → validation message, no mutation.

Services return typed results (`Result`/sealed failures) rather than throwing across layers.

## Testing strategy

- **Pure domain:** exhaustive table-driven tests for classifier and extractors (real German document snippets).
- **Repositories:** in-memory drift, verifying CRUD + FTS sync + search ranking.
- **Widgets:** scan-confirmation and search screens with pumped localizations and provider overrides.
- **No test touches the network or a real device plugin.**

---

## Phase 2 extension points (designed for, NOT implemented)

These are deliberately stubbed/abstracted so they can be added without reworking Phase 1.

1. **Due-date reminders for invoices.**
   - Extraction already produces `documentDate` and amount; add a nullable `dueDate` column (extractor for `zahlbar bis` / `Zahlungsziel` already isolated).
   - Extension point: a `ReminderScheduler` service interface in `core/services/`; a local-notification implementation plugs in later. No network needed.

2. **At-rest encryption (SQLCipher / AES).**
   - The database connection is created in one factory (`core/database/connection.dart`). Swapping `NativeDatabase` for an encrypted variant (SQLCipher via `sqlcipher_flutter_libs`) is a single-file change; the passphrase already has a home in `flutter_secure_storage`.
   - File blobs (PDFs/thumbnails) go through `core/services/file_service.dart`; an encrypting decorator can wrap it.

3. **Optional cloud sync.**
   - All persistence is behind repositories. A sync engine would observe a change log; add an append-only `changes` table and a `SyncService` interface. The UI never assumes local-only, so enabling sync is additive. (Ships disabled; offline remains the default and the privacy promise.)

4. **LLM-powered classification & extraction (premium IAP).**
   - `DocumentClassifier` / `MetadataExtractor` interfaces are the seam. An `LlmClassifier` (on-device model or user-provided endpoint) implements the same contract; the pipeline is unchanged.
   - A `ClassifierSelector` provider chooses rule-based vs. LLM based on an entitlement flag; IAP/entitlement is the only new surface.

Each extension point is a named interface with a single Phase-1 implementation, so Phase 2 is "add an implementation + a provider override", not "rewrite".
