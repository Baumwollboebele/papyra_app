import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/repositories/document_repository.dart';
import '../../../core/database/default_categories.dart';
import '../../../core/providers/classification_providers.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/ocr_service.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/scanner_service.dart';
import '../../../core/services/thumbnail_service.dart';
import '../domain/pipeline/scan_models.dart';
import '../domain/pipeline/scan_processing.dart';

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);

/// Drives the scan flow: capture → review → OCR/classify/extract → confirm →
/// save. Heavy work (OCR, thumbnail, PDF) runs off the UI isolate. Every failure
/// path resolves to [ScanPhase.error] with a German message — never a crash.
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
        final stored = await fileService.importPage(path);
        pages.add(ScanPage(imagePath: stored));
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

  /// Runs OCR then classification/extraction, producing the confirmation draft.
  Future<void> process() async {
    if (state.pages.isEmpty) return;
    state = state.copyWith(
      phase: ScanPhase.processing,
      progressLabel: 'Text wird erkannt …',
    );
    try {
      final ocr = ref.read(ocrServiceProvider);
      final texts = await ocr.recognizePages(
        state.pages.map((p) => p.imagePath).toList(),
      );
      final pages = [
        for (var i = 0; i < state.pages.length; i++)
          state.pages[i].copyWith(text: texts[i]),
      ];
      final combined = texts.where((t) => t.trim().isNotEmpty).join('\n\n');

      final categories = await ref.read(categoryRepositoryProvider).getAll();
      final idByKey = {for (final c in categories) c.key: c.id};
      final fallbackId = idByKey[CategoryKeys.sonstiges] ?? categories.first.id;

      final result = buildProcessingResult(
        combinedText: combined,
        classifier: ref.read(documentClassifierProvider),
        extractor: ref.read(metadataExtractorProvider),
        categoryIdByKey: idByKey,
        fallbackCategoryId: fallbackId,
      );

      state = state.copyWith(
        phase: ScanPhase.confirm,
        pages: pages,
        classification: result.classification,
        draft: result.draft,
      );
    } catch (_) {
      // OCR failed: still let the user save with empty text.
      final categories = await ref.read(categoryRepositoryProvider).getAll();
      final fallbackId = categories
          .firstWhere(
            (c) => c.key == CategoryKeys.sonstiges,
            orElse: () => categories.first,
          )
          .id;
      state = state.copyWith(
        phase: ScanPhase.confirm,
        draft: ConfirmationDraft(
          title: 'Dokument',
          categoryId: fallbackId,
          suggestedCategoryId: fallbackId,
          confidence: 0,
          lowConfidence: true,
        ),
      );
    }
  }

  void updateDraft(ConfirmationDraft draft) {
    state = state.copyWith(draft: draft);
  }

  /// Generates the searchable PDF + thumbnail and persists the document.
  Future<void> save() async {
    final draft = state.draft;
    if (draft == null || state.pages.isEmpty) return;

    state = state.copyWith(
      phase: ScanPhase.saving,
      progressLabel: 'PDF wird erstellt …',
    );
    final fileService = ref.read(fileServiceProvider);
    final written = <String>[];
    try {
      final pageBytes = <Uint8List>[];
      for (final page in state.pages) {
        pageBytes.add(await fileService.readBytes(page.imagePath));
      }

      final pdfBytes = await compute(
        buildSearchablePdf,
        PdfBuildRequest(
          title: draft.title,
          fontData: await _loadTextLayerFont(),
          pages: [
            for (var i = 0; i < state.pages.length; i++)
              PdfPageInput(imageBytes: pageBytes[i], text: state.pages[i].text),
          ],
        ),
      );
      final pdfPath = await fileService.writePdf(pdfBytes);
      written.add(pdfPath);

      final thumbBytes = await compute(
        generateThumbnailBytes,
        ThumbnailRequest(pageBytes.first),
      );
      final thumbPath = await fileService.writeThumbnail(thumbBytes);
      written.add(thumbPath);

      final ocrText = state.pages.map((p) => p.text).join('\n\n');
      final id = await ref
          .read(documentRepositoryProvider)
          .insertDocument(
            DocumentDraft(
              title: draft.title,
              categoryId: draft.categoryId,
              pdfPath: pdfPath,
              pageImagePaths: state.pages.map((p) => p.imagePath).toList(),
              thumbnailPath: thumbPath,
              sender: draft.sender,
              documentDate: draft.documentDate,
              amountCents: draft.amountCents,
              currency: draft.currency,
              ocrText: ocrText,
              tags: draft.tags,
            ),
          );

      state = state.copyWith(phase: ScanPhase.saved, savedDocumentId: id);
    } on StorageException catch (e) {
      await fileService.deleteAll(written);
      _fail('Nicht genügend Speicherplatz oder Schreibfehler: ${e.message}');
    } catch (_) {
      await fileService.deleteAll(written);
      _fail('Das Dokument konnte nicht gespeichert werden.');
    }
  }

  void _fail(String message) {
    state = state.copyWith(phase: ScanPhase.error, errorMessage: message);
  }

  Uint8List? _cachedFont;

  /// Loads the bundled Inter font (once) for the PDF's invisible text layer, so
  /// German umlauts survive in the searchable layer. Best-effort: null on any
  /// failure, in which case the PDF uses the built-in Latin-1 font.
  Future<Uint8List?> _loadTextLayerFont() async {
    if (_cachedFont != null) return _cachedFont;
    try {
      final data = await rootBundle.load('assets/fonts/Inter-Variable.ttf');
      _cachedFont = data.buffer.asUint8List();
    } catch (_) {
      _cachedFont = null;
    }
    return _cachedFont;
  }
}
