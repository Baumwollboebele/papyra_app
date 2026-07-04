import 'package:flutter/foundation.dart';

import '../classification/models.dart';
import 'scan_models.dart';

/// Where an ingested document came from. All sources funnel through the same
/// [IngestService] (see ARCHITECTURE.md).
enum IngestSource { camera, share, openWith, importFile }

enum IngestStatus { pending, processing, ready, saving, saved, failed }

/// One document-to-be moving through the ingest pipeline. Built from a camera
/// capture, a shared/opened file, or a manual import; processed (OCR → classify
/// → extract) into a [draft]; then persisted.
@immutable
class IngestItem {
  const IngestItem({
    required this.id,
    required this.source,
    required this.pageImagePaths,
    this.displayName,
    this.originalPdfPath,
    this.pdfHasTextLayer = false,
    this.pageTexts = const [],
    this.classification,
    this.draft,
    this.status = IngestStatus.pending,
    this.errorMessage,
    this.savedDocumentId,
  });

  final String id;
  final IngestSource source;

  /// Page images in app storage, used for OCR, thumbnail and (when there is no
  /// [originalPdfPath]) to build the searchable PDF.
  final List<String> pageImagePaths;

  /// Original filename (for the queue UI), when known.
  final String? displayName;

  /// When set, an original PDF was ingested and is kept as-is (no re-render);
  /// it becomes the document's `pdfPath`.
  final String? originalPdfPath;

  final bool pdfHasTextLayer;
  final List<String> pageTexts;
  final ClassificationResult? classification;
  final ConfirmationDraft? draft;
  final IngestStatus status;
  final String? errorMessage;
  final int? savedDocumentId;

  bool get isPdf => originalPdfPath != null;

  IngestItem copyWith({
    List<String>? pageImagePaths,
    List<String>? pageTexts,
    ClassificationResult? classification,
    ConfirmationDraft? draft,
    IngestStatus? status,
    String? errorMessage,
    int? savedDocumentId,
  }) {
    return IngestItem(
      id: id,
      source: source,
      pageImagePaths: pageImagePaths ?? this.pageImagePaths,
      displayName: displayName,
      originalPdfPath: originalPdfPath,
      pdfHasTextLayer: pdfHasTextLayer,
      pageTexts: pageTexts ?? this.pageTexts,
      classification: classification ?? this.classification,
      draft: draft ?? this.draft,
      status: status ?? this.status,
      errorMessage: errorMessage,
      savedDocumentId: savedDocumentId ?? this.savedDocumentId,
    );
  }

  /// All files owned by this item, for cleanup when discarded before saving.
  Iterable<String> get ownedFiles => [...pageImagePaths, ?originalPdfPath];
}

/// A shared/imported input file with its declared MIME type.
@immutable
class IngestFile {
  const IngestFile({required this.path, this.mimeType, this.name});
  final String path;
  final String? mimeType;
  final String? name;
}

/// Raised when an input can't be ingested; carries a German user message.
class IngestException implements Exception {
  const IngestException(this.message);
  final String message;
  @override
  String toString() => 'IngestException: $message';
}
