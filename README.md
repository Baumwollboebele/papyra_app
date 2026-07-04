# PaperVault

**Deine Dokumente verlassen nie dein Gerät.**

PaperVault is a **100% offline, local-first** Flutter app for the German market. Scan your paper mail (invoices, payslips, tax letters, contracts, insurance), and PaperVault OCRs it on-device, automatically classifies and files it into smart categories, and makes everything full-text searchable — with no backend, no accounts, no analytics, and no network calls at all.

> Working title. The name is easy to change — see [Renaming](#renaming).

---

## Why it's private by design

- **No network.** The Android build explicitly **removes the `INTERNET` permission** (see `android/app/src/main/AndroidManifest.xml`). If the app can't reach the network, your documents can't leave the device.
- **No accounts, no cloud, no analytics, no ads, no tracking.**
- On-device OCR (Google ML Kit) and a pure-Dart rule-based classifier. Nothing is sent anywhere.
- Optional biometric app lock and iOS at-rest file protection.

## Features (Phase 1 / MVP)

- **Onboarding** (first launch): what it does, the privacy promise, optional app-lock setup.
- **Scan flow:** native multi-page scanner → review (reorder / delete / add pages) → on-device OCR → automatic classification + metadata extraction → editable confirmation → save as a **searchable PDF** with a thumbnail.
- **Rule-based German classifier** into 9 categories (Rechnungen, Lohn & Gehalt, Steuern & Finanzamt, Verträge, Versicherungen, Bank, Gesundheit, Behörden, Sonstiges) with a confidence score; low-confidence documents fall back to *Sonstiges* and prompt the user.
- **Extraction:** German dates (`12.03.2026`, `12. März 2026`), amounts (`1.234,56 €`, preferring totals), IBAN (with mod-97 validation), and a sender heuristic.
- **Library:** category grid with counts + "Zuletzt hinzugefügt"; sortable/filterable category lists; document detail with swipeable pages (Hero animation), metadata card, collapsible OCR text, and actions (share PDF, edit, move, tag, favorite, delete).
- **Search:** global full-text search (SQLite FTS5) with filters (category, date range, favorites), match highlighting, and recent searches.
- **Backup & export:** share any document as PDF; full backup as a single ZIP; restore via file picker. No cloud anywhere.
- **Settings:** app lock, theme (system/light/dark), category management (add/rename/reorder/recolor), backup & restore, and a plain-language German privacy page.

## Tech stack

Material 3 (`ColorScheme.fromSeed`, deep-teal seed, bundled **Inter** font) · `flutter_riverpod` · `go_router` · `cunning_document_scanner` · `google_mlkit_text_recognition` · `drift` (SQLite + FTS5) · `pdf` / `printing` / `share_plus` · `local_auth` / `flutter_secure_storage` · `path_provider` / `intl` / `image` / `archive` · `file_selector` (backup restore) · `freezed` (domain value objects).

## Project structure

Feature-first; see [ARCHITECTURE.md](ARCHITECTURE.md) for the full picture and Phase-2 extension points.

```
lib/
  core/        theme, l10n, router, database (drift), services, formatting, widgets, providers
  features/    onboarding, scan, library, search, settings  (each data/domain/presentation)
  l10n/        app_de.arb (base), app_en.arb
```

---

## Getting started

### Prerequisites

- Flutter **3.44.4** stable / Dart **3.12.2** (a matching SDK is bundled at `../flutter`).
- Android: Android SDK + a device/emulator with **API 24+**.
- iOS: **macOS + Xcode 15+** (iOS cannot be compiled on Windows).

### Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift + freezed codegen
flutter gen-l10n                                            # localizations (also runs on build)
flutter run
```

Regenerate code after changing any drift table, `@freezed` model or `.arb` file. Generated files (`*.g.dart`, `*.freezed.dart`) are committed.

### Running tests

```bash
flutter analyze          # must be clean
dart format .            # formatting
flutter test             # unit + widget tests
```

> **Windows note:** run tests serially with `flutter test --concurrency=1`. Parallel test isolates contend for the bundled `sqlite3.dll` and can fail to load; serial execution avoids this. macOS/Linux CI can run the default parallel mode.

### App icon

The launcher icon is a generated placeholder:

```bash
dart run tool/generate_app_icon.dart   # writes assets/icon/*.png
dart run flutter_launcher_icons         # writes platform icons
```

Replace `assets/icon/app_icon.png` (1024×1024) and `assets/icon/app_icon_foreground.png` (transparent, safe-zone) with your artwork, then rerun `flutter_launcher_icons`.

---

## Building for release

### Android

```bash
flutter build appbundle --release   # Play Store (.aab)
flutter build apk --release         # sideload / testing
```

Before publishing:

1. Set a real `applicationId` in `android/app/build.gradle.kts` (placeholder: `de.example.papervault`).
2. Configure a release signing config (currently signs with debug keys so `--release` runs locally). See [Flutter: Android signing](https://docs.flutter.dev/deployment/android#signing-the-app).
3. Confirm the merged manifest has **no `INTERNET` permission**: build the APK then inspect `build/app/outputs/…/AndroidManifest.xml`, or run `aapt dump permissions`.

### iOS (on macOS)

```bash
flutter build ipa --release
```

One-time Xcode setup (some steps can't be scripted from Windows):

1. Open `ios/Runner.xcworkspace`. Set the **Bundle Identifier** (placeholder `de.example.papervault`) and your signing team.
2. Add `ios/Runner/PrivacyInfo.xcprivacy` to the **Runner** target (Build Phases → Copy Bundle Resources) if not already included.
3. Set **Code Signing Entitlements** to `Runner/Runner.entitlements` (enables `NSFileProtectionComplete` at-rest encryption).
4. Verify the localized `InfoPlist.strings` (`ios/Runner/de.lproj`, `en.lproj`) are part of the target so the camera/Face ID prompts are German + English.

## Minimum OS versions

| Platform | Minimum | Driver |
|---|---|---|
| Android | **API 24 (Android 7.0)** | ML Kit text recognition + document scanner, `local_auth` |
| iOS | **iOS 13.0** | VisionKit document scanner, plugin baseline |

Set in `android/app/build.gradle.kts` (`minSdk = 24`) and the iOS deployment target in Xcode / `ios/Podfile`.

## Permissions

- **Camera** (`android.permission.CAMERA`, `NSCameraUsageDescription`): scanning documents. Rationale strings are localized (de/en).
- **Face ID** (`NSFaceIDUsageDescription`): optional app lock.
- **No internet permission** — intentionally removed on Android; not requested on iOS.

---

## Backup format

A backup is a single **ZIP** (share it anywhere you like — it never leaves the device automatically):

```
manifest.json              { app, format, schemaVersion, createdAt, baseDir }
papervault.sqlite          the SQLite database (documents, categories, tags, FTS)
files/papervault/pages/…       scanned page images
files/papervault/thumbnails/…  thumbnails
files/papervault/pdfs/…        generated PDFs
```

- `format` is the backup format version (currently `1`); `baseDir` records the original absolute media directory.
- **Restore** replaces the current database and media files, then rewrites absolute file paths from the backup's `baseDir` to this device's directory — so a backup restores correctly even on a **different device**.
- Restore is destructive (it replaces current data) and asks for confirmation first.

---

## Renaming

"PaperVault" is a working title. To rename:

1. **App id:** `android/app/build.gradle.kts` (`applicationId`) and the iOS Bundle Identifier in Xcode.
2. **Display name:** `android/app/src/main/AndroidManifest.xml` (`android:label`) and `ios/Runner/Info.plist` (`CFBundleDisplayName` + the `InfoPlist.strings`).
3. **Product name in the UI:** the single `appName` entry in `lib/l10n/app_de.arb` / `app_en.arb`.
4. The Dart package name (`pubspec.yaml` `name:`) is internal only; changing it is optional.

---

## Store-listing checklist

**Shared**

- [ ] Final app name + subtitle/short description (German primary, English secondary).
- [ ] App icon replaced (see [App icon](#app-icon)); feature graphic / screenshots (phone + tablet, light + dark).
- [ ] Privacy policy URL (the in-app "Über & Datenschutz" text can be the basis).
- [ ] Version + build number bumped in `pubspec.yaml`.

**Google Play**

- [ ] Real `applicationId` + release signing (Play App Signing).
- [ ] Data safety form: **no data collected, no data shared** (matches reality).
- [ ] Confirm `INTERNET` is absent from the release manifest.
- [ ] Target API level meets the current Play requirement (`targetSdk`).

**Apple App Store**

- [ ] Bundle id + provisioning/signing team.
- [ ] `PrivacyInfo.xcprivacy` in the target; App Privacy questionnaire: **no tracking, no data collection**.
- [ ] Camera + Face ID usage strings present and localized (de/en).
- [ ] Data-protection entitlement enabled.

---

## Package decisions

- **`freezed`** is pinned to a stable `^3.1.0` (matching `freezed_annotation ^3.1.0`); `flutter pub add` had resolved a `-dev` prerelease, which is unsuitable for a production build.
- **`file_selector`** (Apache-2.0, flutter.dev) was added for the backup **restore** file picker — the only capability the listed stack did not cover. It is free, permissive and offline.
- **`sqlite3_flutter_libs`** currently resolves to `0.6.0+eol`; it still works and bundles SQLite with FTS5. Revisit if a maintained successor ships.
- The searchable-PDF text layer embeds the bundled Inter font for full German coverage, with a safe fallback to the built-in Latin-1 font.

## Known limitations

- iOS has not been compiled in this environment (Windows); all iOS files are configured but must be built/verified on macOS.
- Device-only features (native scanner, on-device OCR, biometrics) are abstracted behind interfaces and covered by logic/widget tests with fakes rather than live runs.
- The placeholder icon is functional but not final artwork.

## Roadmap (Phase 2 — designed for, not implemented)

Due-date reminders, at-rest DB encryption (SQLCipher), optional cloud sync, and an LLM-powered classifier as a premium IAP. Clean extension points are described in [ARCHITECTURE.md](ARCHITECTURE.md).

## License

Application code: choose your license before publishing. Bundled **Inter** font is under the SIL Open Font License (`assets/fonts/OFL.txt`). All dependencies use permissive licenses (MIT/BSD/Apache/OFL).
