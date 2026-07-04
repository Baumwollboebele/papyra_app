// Public named constructor params intentionally map to private fields.
// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/database/default_categories.dart';
import '../../../../core/database/repositories/category_repository.dart';
import '../../../../core/database/repositories/document_repository.dart';
import '../../../../core/database/repositories/group_repository.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/services/pdf_rasterizer.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/thumbnail_service.dart';
import '../../../../core/utils/ids.dart';
import '../classification/document_classifier.dart';
import '../classification/metadata_extractor.dart';
import 'ingest_models.dart';
import 'pdf_text_layer.dart';
import 'scan_models.dart';
import 'scan_processing.dart';

/// The single pipeline all document sources funnel through: camera, share
/// sheet, "open with" and manual import. Turns raw inputs into persisted
/// documents (searchable PDF + thumbnail + FTS) via OCR → classify → extract →
/// confirm. Heavy work runs off the UI isolate.
class IngestService {
  IngestService({
    required FileService fileService,
    required OcrService ocrService,
    required PdfRasterizer pdfRasterizer,
    required DocumentClassifier classifier,
    required MetadataExtractor extractor,
    required CategoryRepository categoryRepository,
    required GroupRepository groupRepository,
    required DocumentRepository documentRepository,
    Future<Uint8List?> Function()? fontLoader,
  }) : _files = fileService,
       _ocr = ocrService,
       _rasterizer = pdfRasterizer,
       _classifier = classifier,
       _extractor = extractor,
       _categories = categoryRepository,
       _groups = groupRepository,
       _documents = documentRepository,
       _fontLoader = fontLoader;

  final FileService _files;
  final OcrService _ocr;
  final PdfRasterizer _rasterizer;
  final DocumentClassifier _classifier;
  final MetadataExtractor _extractor;
  final CategoryRepository _categories;
  final GroupRepository _groups;
  final DocumentRepository _documents;
  final Future<Uint8List?> Function()? _fontLoader;

  static const _imageMimes = {'image/jpeg', 'image/jpg', 'image/png'};
  static const _imageExts = {'.jpg', '.jpeg', '.png'};

  // --- Build items from sources ----------------------------------------------

  /// Wraps already-stored camera page images into a single item.
  IngestItem cameraItem(List<String> storedPageImagePaths) {
    return IngestItem(
      id: uniqueId(),
      source: IngestSource.camera,
      pageImagePaths: storedPageImagePaths,
    );
  }

  /// Builds one item per input file (PDF = multi-page item; image = one page).
  /// Unsupported/corrupt files become a `failed` item so the queue can show
  /// them with a German message rather than crashing.
  Future<List<IngestItem>> buildItems(
    List<IngestFile> files,
    IngestSource source,
  ) async {
    final items = <IngestItem>[];
    for (final file in files) {
      try {
        if (_isImage(file)) {
          items.add(await _imageItem(file, source));
        } else if (_isPdf(file)) {
          items.add(await _pdfItem(file, source));
        } else {
          items.add(_failed(file, 'Dieser Dateityp wird nicht unterstützt.'));
        }
      } on StorageException catch (e) {
        items.add(_failed(file, 'Speichern fehlgeschlagen: ${e.message}'));
      } catch (_) {
        items.add(_failed(file, 'Die Datei konnte nicht gelesen werden.'));
      }
    }
    return items;
  }

  bool _isImage(IngestFile f) =>
      _imageMimes.contains(f.mimeType?.toLowerCase()) ||
      _imageExts.any((e) => f.path.toLowerCase().endsWith(e));

  bool _isPdf(IngestFile f) =>
      f.mimeType?.toLowerCase() == 'application/pdf' ||
      f.path.toLowerCase().endsWith('.pdf');

  IngestItem _failed(IngestFile file, String message) => IngestItem(
    id: uniqueId(),
    source: IngestSource.share,
    pageImagePaths: const [],
    displayName: file.name,
    status: IngestStatus.failed,
    errorMessage: message,
  );

  Future<IngestItem> _imageItem(IngestFile file, IngestSource source) async {
    final stored = await _files.importPage(file.path);
    return IngestItem(
      id: uniqueId(),
      source: source,
      pageImagePaths: [stored],
      displayName: file.name,
    );
  }

  Future<IngestItem> _pdfItem(IngestFile file, IngestSource source) async {
    final bytes = await _files.readBytes(file.path);
    if (!isPdf(bytes)) {
      return _failed(file, 'Die Datei ist keine gültige PDF.');
    }
    final hasText = pdfHasTextLayer(bytes);
    // Keep the original PDF untouched (no lossy re-render).
    final originalPdf = await _files.importPdf(file.path);
    final pages = <String>[];
    try {
      await for (final png in _rasterizer.rasterize(bytes)) {
        pages.add(await _files.writePageImage(png));
      }
    } catch (_) {
      await _files.deleteAll([originalPdf, ...pages]);
      return _failed(
        file,
        'Das PDF konnte nicht verarbeitet werden '
        '(möglicherweise passwortgeschützt oder beschädigt).',
      );
    }
    if (pages.isEmpty) {
      await _files.deleteAll([originalPdf]);
      return _failed(file, 'Das PDF enthält keine lesbaren Seiten.');
    }
    return IngestItem(
      id: uniqueId(),
      source: source,
      pageImagePaths: pages,
      originalPdfPath: originalPdf,
      pdfHasTextLayer: hasText,
      displayName: file.name,
    );
  }

  // --- Process (OCR → classify → extract) ------------------------------------

  /// OCRs the pages, classifies, extracts metadata and suggests a group.
  /// On OCR failure the item is still `ready` with a safe fallback draft.
  Future<IngestItem> process(IngestItem item) async {
    if (item.status == IngestStatus.failed) return item;
    try {
      final texts = await _ocr.recognizePages(item.pageImagePaths);
      final combined = texts.where((t) => t.trim().isNotEmpty).join('\n\n');

      final categories = await _categories.getAll();
      final idByKey = {for (final c in categories) c.key: c.id};
      final fallbackId = idByKey[CategoryKeys.sonstiges] ?? categories.first.id;

      final result = buildProcessingResult(
        combinedText: combined,
        classifier: _classifier,
        extractor: _extractor,
        categoryIdByKey: idByKey,
        fallbackCategoryId: fallbackId,
      );
      final suggestedGroupId = await _groups.suggestGroupId(
        result.draft.categoryId,
        result.draft.sender,
      );

      return item.copyWith(
        pageTexts: texts,
        classification: result.classification,
        draft: result.draft.copyWith(groupId: suggestedGroupId),
        status: IngestStatus.ready,
      );
    } catch (_) {
      final categories = await _categories.getAll();
      final fallbackId = categories
          .firstWhere(
            (c) => c.key == CategoryKeys.sonstiges,
            orElse: () => categories.first,
          )
          .id;
      return item.copyWith(
        status: IngestStatus.ready,
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

  // --- Persist ---------------------------------------------------------------

  /// Persists the item using [draft]. PDF sources keep the original file; image
  /// sources build a searchable PDF. Returns the new document id.
  Future<int> persist(IngestItem item, ConfirmationDraft draft) async {
    final written = <String>[];
    final pageBytes = <Uint8List>[];
    for (final path in item.pageImagePaths) {
      pageBytes.add(await _files.readBytes(path));
    }

    String pdfPath;
    if (item.isPdf) {
      pdfPath = item.originalPdfPath!; // preserve the original, no re-render
    } else {
      final pdfBytes = await compute(
        buildSearchablePdf,
        PdfBuildRequest(
          title: draft.title,
          fontData: await _loadFont(),
          pages: [
            for (var i = 0; i < item.pageImagePaths.length; i++)
              PdfPageInput(imageBytes: pageBytes[i], text: _textAt(item, i)),
          ],
        ),
      );
      pdfPath = await _files.writePdf(pdfBytes);
      written.add(pdfPath);
    }

    try {
      final thumbBytes = await compute(
        generateThumbnailBytes,
        ThumbnailRequest(pageBytes.first),
      );
      final thumbPath = await _files.writeThumbnail(thumbBytes);
      written.add(thumbPath);

      return await _documents.insertDocument(
        DocumentDraft(
          title: draft.title,
          categoryId: draft.categoryId,
          pdfPath: pdfPath,
          pageImagePaths: item.pageImagePaths,
          thumbnailPath: thumbPath,
          sender: draft.sender,
          documentDate: draft.documentDate,
          amountCents: draft.amountCents,
          currency: draft.currency,
          ocrText: item.pageTexts.join('\n\n'),
          tags: draft.tags,
          groupId: draft.groupId,
        ),
      );
    } catch (_) {
      await _files.deleteAll(written);
      rethrow;
    }
  }

  String _textAt(IngestItem item, int i) =>
      i < item.pageTexts.length ? item.pageTexts[i] : '';

  Future<Uint8List?> _loadFont() async {
    if (_fontLoader == null) return null;
    try {
      return await _fontLoader();
    } catch (_) {
      return null;
    }
  }
}
