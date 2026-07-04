import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';
import 'package:paperless/core/database/repositories/document_repository.dart';
import 'package:paperless/core/database/repositories/group_repository.dart';
import 'package:paperless/core/services/file_service.dart';
import 'package:paperless/core/services/ocr_service.dart';
import 'package:paperless/core/services/pdf_rasterizer.dart';
import 'package:paperless/features/scan/domain/classification/metadata_extractor.dart';
import 'package:paperless/features/scan/domain/classification/rule_based_classifier.dart';
import 'package:paperless/features/scan/domain/pipeline/ingest_models.dart';
import 'package:paperless/features/scan/domain/pipeline/ingest_service.dart';

/// OCR fake that returns the same German invoice text for every page.
class _FixedOcr implements OcrService {
  _FixedOcr(this.text);
  final String text;
  @override
  Future<String> recognizePage(String imagePath) async => text;
  @override
  Future<List<String>> recognizePages(List<String> paths) async => [
    for (final _ in paths) text,
  ];
  @override
  Future<void> dispose() async {}
}

Uint8List _png() {
  final image = img.Image(width: 200, height: 260);
  img.fill(image, color: img.ColorRgb8(210, 225, 220));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  late Directory docs;
  late Directory src;
  late AppDatabase db;
  late IngestService ingest;
  late DocumentRepository docsRepo;

  const invoiceText =
      'Stadtwerke München GmbH\nRechnung\nRechnungsnummer 1\n'
      'Rechnungsdatum: 12.03.2026\nGesamtbetrag 89,90 €';

  setUp(() {
    docs = Directory.systemTemp.createTempSync('ingest_docs');
    src = Directory.systemTemp.createTempSync('ingest_src');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    docsRepo = DocumentRepository(db);
    final files = FileService(documentsDirectory: () async => docs);
    ingest = IngestService(
      fileService: files,
      ocrService: _FixedOcr(invoiceText),
      pdfRasterizer: FakePdfRasterizer([_png()]),
      classifier: RuleBasedClassifier(),
      extractor: const MetadataExtractor(),
      categoryRepository: CategoryRepository(db),
      groupRepository: GroupRepository(db),
      documentRepository: docsRepo,
    );
  });

  tearDown(() {
    db.close();
    if (docs.existsSync()) docs.deleteSync(recursive: true);
    if (src.existsSync()) src.deleteSync(recursive: true);
  });

  String writeSrc(String name, List<int> bytes) {
    final f = File(p.join(src.path, name))..writeAsBytesSync(bytes);
    return f.path;
  }

  test('ingests an image file end-to-end (classify + persist)', () async {
    final path = writeSrc('scan.png', _png());
    final items = await ingest.buildItems([
      IngestFile(path: path, mimeType: 'image/png', name: 'scan.png'),
    ], IngestSource.importFile);
    expect(items, hasLength(1));

    final processed = await ingest.process(items.first);
    expect(processed.status, IngestStatus.ready);
    expect(processed.draft, isNotNull);
    // Classified as an invoice, sender + amount extracted.
    final cat = await CategoryRepository(
      db,
    ).getById(processed.draft!.categoryId);
    expect(cat.key, CategoryKeys.rechnungen);
    expect(processed.draft!.amountCents, 8990);

    final id = await ingest.persist(processed, processed.draft!);
    final detail = await docsRepo.getDetail(id);
    expect(detail, isNotNull);
    expect(File(detail!.document.pdfPath).existsSync(), isTrue); // built PDF
    expect(detail.document.ocrText, contains('Stadtwerke'));
  });

  test(
    'ingests a PDF file and preserves the original PDF (no re-render)',
    () async {
      // Minimal bytes that pass the %PDF header + /Font checks.
      final pdfBytes = Uint8List.fromList('%PDF-1.7\n/Font\n...'.codeUnits);
      final path = writeSrc('doc.pdf', pdfBytes);

      final items = await ingest.buildItems([
        IngestFile(path: path, mimeType: 'application/pdf', name: 'doc.pdf'),
      ], IngestSource.share);
      expect(items, hasLength(1));
      final item = items.first;
      expect(item.isPdf, isTrue);
      expect(item.originalPdfPath, isNotNull);
      expect(item.pageImagePaths, hasLength(1)); // rasterized by the fake

      final processed = await ingest.process(item);
      final id = await ingest.persist(processed, processed.draft!);
      final detail = await docsRepo.getDetail(id);
      // The stored PDF is the imported original (kept), and its bytes are intact.
      expect(detail!.document.pdfPath, item.originalPdfPath);
      expect(File(detail.document.pdfPath).readAsBytesSync(), pdfBytes);
    },
  );

  test('unsupported file becomes a failed item, not a crash', () async {
    final path = writeSrc('note.txt', 'hello'.codeUnits);
    final items = await ingest.buildItems([
      IngestFile(path: path, mimeType: 'text/plain', name: 'note.txt'),
    ], IngestSource.share);
    expect(items.single.status, IngestStatus.failed);
    expect(items.single.errorMessage, isNotNull);
  });
}
