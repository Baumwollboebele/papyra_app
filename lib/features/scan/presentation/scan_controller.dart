import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/ingest_providers.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/scanner_service.dart';
import '../domain/pipeline/scan_models.dart';

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);

/// Drives the camera scan flow: capture → review → process → confirm → save.
/// The actual OCR/classify/persist work lives in the shared [IngestService]
/// (see ingestServiceProvider), so camera, share and import all use one
/// pipeline. Every failure path resolves to [ScanPhase.error] with a German
/// message — never a crash.
class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  void reset() => state = const ScanState();

  /// Launches the native scanner and imports captured pages into storage.
  Future<void> startScan() async {
    state = const ScanState(phase: ScanPhase.capturing);
    try {
      final paths = await ref.read(scannerServiceProvider).scan();
      if (paths.isEmpty) {
        state = const ScanState(); // cancelled
        return;
      }
      final fileService = ref.read(fileServiceProvider);
      final pages = <ScanPage>[];
      for (final path in paths) {
        pages.add(ScanPage(imagePath: await fileService.importPage(path)));
      }
      state = ScanState(phase: ScanPhase.review, pages: pages);
    } on StorageException catch (e) {
      _fail('Speichern fehlgeschlagen: ${e.message}');
    } catch (_) {
      _fail(
        'Der Scanner konnte nicht gestartet werden. '
        'Bitte prüfe die Kamera-Berechtigung.',
      );
    }
  }

  /// Adds more pages to the current set (retake / add page).
  Future<void> addPages() async {
    final existing = state.pages;
    try {
      final paths = await ref.read(scannerServiceProvider).scan();
      if (paths.isEmpty) return;
      final fileService = ref.read(fileServiceProvider);
      final pages = [...existing];
      for (final path in paths) {
        pages.add(ScanPage(imagePath: await fileService.importPage(path)));
      }
      state = state.copyWith(pages: pages);
    } catch (_) {
      _fail('Weitere Seiten konnten nicht gescannt werden.');
    }
  }

  void removePage(int index) {
    final pages = [...state.pages];
    final removed = pages.removeAt(index);
    ref.read(fileServiceProvider).deleteAll([removed.imagePath]);
    state = state.copyWith(pages: pages);
  }

  /// [newIndex] is already adjusted for the removed item (ReorderableListView's
  /// onReorderItem contract).
  void reorderPages(int oldIndex, int newIndex) {
    final pages = [...state.pages];
    final moved = pages.removeAt(oldIndex);
    pages.insert(newIndex, moved);
    state = state.copyWith(pages: pages);
  }

  /// Runs OCR + classification + extraction via the shared ingest service.
  Future<void> process() async {
    if (state.pages.isEmpty) return;
    state = state.copyWith(
      phase: ScanPhase.processing,
      progressLabel: 'Text wird erkannt …',
    );
    final ingest = ref.read(ingestServiceProvider);
    final item = ingest.cameraItem(
      state.pages.map((p) => p.imagePath).toList(),
    );
    final processed = await ingest.process(item);
    state = state.copyWith(
      phase: ScanPhase.confirm,
      item: processed,
      classification: processed.classification,
      draft: processed.draft,
    );
  }

  void updateDraft(ConfirmationDraft draft) {
    state = state.copyWith(draft: draft);
  }

  /// Persists the confirmed document via the shared ingest service.
  Future<void> save() async {
    final draft = state.draft;
    final item = state.item;
    if (draft == null || item == null || state.pages.isEmpty) return;

    state = state.copyWith(
      phase: ScanPhase.saving,
      progressLabel: 'Wird gespeichert …',
    );
    try {
      final id = await ref.read(ingestServiceProvider).persist(item, draft);
      state = state.copyWith(phase: ScanPhase.saved, savedDocumentId: id);
    } on StorageException catch (e) {
      _fail('Nicht genügend Speicherplatz oder Schreibfehler: ${e.message}');
    } catch (_) {
      _fail('Das Dokument konnte nicht gespeichert werden.');
    }
  }

  void _fail(String message) {
    state = state.copyWith(phase: ScanPhase.error, errorMessage: message);
  }
}
