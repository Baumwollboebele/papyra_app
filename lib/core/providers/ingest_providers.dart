import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/scan/domain/pipeline/ingest_service.dart';
import '../services/file_service.dart';
import '../services/ocr_service.dart';
import '../services/pdf_rasterizer.dart';
import 'classification_providers.dart';
import 'database_providers.dart';

Uint8List? _cachedFont;

/// Loads the bundled Inter font once (for the searchable-PDF text layer).
Future<Uint8List?> _loadInter() async {
  if (_cachedFont != null) return _cachedFont;
  final data = await rootBundle.load('assets/fonts/Inter-Variable.ttf');
  return _cachedFont = data.buffer.asUint8List();
}

/// The single ingest pipeline shared by camera, share sheet, "open with" and
/// manual import.
final ingestServiceProvider = Provider<IngestService>((ref) {
  return IngestService(
    fileService: ref.watch(fileServiceProvider),
    ocrService: ref.watch(ocrServiceProvider),
    pdfRasterizer: ref.watch(pdfRasterizerProvider),
    classifier: ref.watch(documentClassifierProvider),
    extractor: ref.watch(metadataExtractorProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    groupRepository: ref.watch(groupRepositoryProvider),
    documentRepository: ref.watch(documentRepositoryProvider),
    learningRepository: ref.watch(learningRepositoryProvider),
    fontLoader: _loadInter,
  );
});
