# CLAUDE.md — Papyra

Project conventions, common commands, and an architecture summary for anyone (human or AI) working in this repo.

## What this is

**Papyra** (working title — see "Renaming" below) is a **100% offline, local-first** Flutter app for the German market. Users scan paper mail (invoices, payslips, tax letters, contracts, insurance), the app OCRs it on-device, classifies and files it into smart categories, and makes everything full-text searchable. No backend, no accounts, no analytics, no runtime network calls. Privacy ("Deine Dokumente verlassen nie dein Gerät") is the core value proposition (DSGVO/GDPR).

## Non-negotiable constraints

- **Zero licensing cost.** Only free, permissively licensed packages (MIT/BSD/Apache/OFL). No paid SDKs, no API keys, no server.
- **Fully offline.** No runtime network calls anywhere. Android build must not request the `INTERNET` permission.
- **Privacy first.** No data collection of any kind. Everything stays on device.
- **One codebase, iOS + Android.** Latest stable Flutter, Dart 3, sound null safety.
- **German-first, fully localized.** All user-facing strings via `gen_l10n`. Base locale `de`, second locale `en`. **No hardcoded UI strings.**

## Toolchain

- Flutter **3.44.4** stable / Dart **3.12.2** (bundled SDK at `../flutter`).
- On this machine Flutter is not on `PATH`; prefix commands, e.g. in PowerShell:
  `$env:Path = "D:\Workspace\paperless\flutter\bin;" + $env:Path`

## Common commands

Run from the project root (`paperless/`):

```bash
flutter pub get                        # fetch deps
dart run build_runner build --delete-conflicting-outputs   # codegen: drift, freezed, json
dart run build_runner watch --delete-conflicting-outputs   # codegen in watch mode
flutter gen-l10n                       # regenerate localizations (also runs on build)
flutter analyze                        # static analysis — MUST be clean
dart format .                          # format — run before every commit
flutter test                           # unit + widget tests — MUST be green
flutter test --concurrency=1           # on Windows: avoids sqlite3.dll lock contention
flutter run                            # run on a connected device/emulator
flutter build apk --release            # Android release build
flutter build appbundle --release      # Play Store bundle
flutter build ios --release            # iOS (requires macOS + Xcode)
dart run flutter_launcher_icons        # regenerate app icons
```

**After any change to a `@freezed` model, a drift table, or a `@JsonSerializable`, re-run `build_runner`.** Generated files (`*.g.dart`, `*.freezed.dart`, `*.drift.dart`) are committed.

## Quality bar (enforced before every commit)

1. `flutter analyze` — zero issues.
2. `dart format .` — no diff.
3. `flutter test` — all green.

Commits are small, focused, and use **Conventional Commits** (`feat:`, `fix:`, `test:`, `docs:`, `chore:`, `refactor:`).

## Architecture (summary — full detail in ARCHITECTURE.md)

Feature-first. Each feature owns `data/ domain/ presentation/`; cross-cutting code lives in `lib/core/`.

```
lib/
  core/            # theme, l10n access, router, db, services, shared widgets, utils
  features/
    onboarding/
    scan/
    library/
    search/
    settings/
  l10n/            # app_de.arb (base), app_en.arb
  main.dart
```

Rules:

- **Repository pattern.** Presentation talks to repositories via Riverpod providers, never to drift directly.
- **Immutable models** with `freezed`. No business logic in widgets.
- **Heavy work off the main thread.** OCR, classification, thumbnailing and PDF generation run via `compute`/isolates with visible progress UI.
- **The classifier + extractors (`lib/features/scan/domain/classification/`) are pure Dart** with no Flutter/plugin imports, so they are unit-testable and later swappable for an LLM-based implementation. Do not add plugin dependencies there.

## Default categories (stable keys — do not renumber)

`rechnungen, lohn_gehalt, steuern, vertraege, versicherungen, bank, gesundheit, behoerden, sonstiges`
The seeded row `sonstiges` is the fallback for low-confidence classification.

## Platform notes

- **App id:** `de.example.papyra` (placeholder — see "Renaming").
- **iOS:** requires `NSCameraUsageDescription` + `NSFaceIDUsageDescription` (de/en), `PrivacyInfo.xcprivacy`, file protection. iOS **cannot be compiled on Windows** — verify on macOS.
- **Android:** camera permission with rationale; **no `INTERNET` permission** (proves the offline claim). minSdk is driven by the ML Kit / scanner plugins — see README.

## Renaming

The name "Papyra" is a working title. To rename:

1. App id: `flutter pub run change_app_package_name:main <new.id>` or edit `android/app/build.gradle.kts` (`applicationId`) and the iOS bundle id in Xcode.
2. Display name: `android/app/src/main/AndroidManifest.xml` (`android:label`) and `ios/Runner/Info.plist` (`CFBundleDisplayName`).
3. User-facing product name: the `appName` entry in `lib/l10n/app_de.arb` / `app_en.arb` (single source of truth for UI).
4. Dart package name (`pubspec.yaml` `name:`) is internal only; changing it is optional and touches all imports.

## Testing conventions

- Pure-Dart logic (classifier, extractors): plain `flutter test`, table-driven cases in `test/features/scan/`.
- Repositories: in-memory drift (`NativeDatabase.memory()`), one DB per test.
- Widgets: `testWidgets` with a `ProviderScope` override and pumped `MaterialApp` carrying localization delegates.
- Running drift/repository tests on desktop needs the native sqlite3 library available to the Dart VM — see README "Running tests".
