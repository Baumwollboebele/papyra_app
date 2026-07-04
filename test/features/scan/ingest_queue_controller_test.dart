import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/providers/database_providers.dart';
import 'package:paperless/core/services/file_service.dart';
import 'package:paperless/core/services/ocr_service.dart';
import 'package:paperless/core/services/pdf_rasterizer.dart';
import 'package:paperless/features/scan/domain/pipeline/ingest_models.dart';
import 'package:paperless/features/scan/presentation/ingest_controller.dart';

class _FixedOcr implements OcrService {
  @override
  Future<String> recognizePage(String path) async => 'Rechnung 89,90 €';
  @override
  Future<List<String>> recognizePages(List<String> paths) async => [
    for (final _ in paths) 'Rechnung 89,90 €',
  ];
  @override
  Future<void> dispose() async {}
}

Uint8List _png() {
  final image = img.Image(width: 120, height: 160);
  img.fill(image, color: img.ColorRgb8(230, 230, 230));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  late Directory docs;
  late Directory src;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    docs = Directory.systemTemp.createTempSync('q_docs');
    src = Directory.systemTemp.createTempSync('q_src');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        fileServiceProvider.overrideWithValue(
          FileService(documentsDirectory: () async => docs),
        ),
        ocrServiceProvider.overrideWithValue(_FixedOcr()),
        pdfRasterizerProvider.overrideWithValue(FakePdfRasterizer([_png()])),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
    if (docs.existsSync()) docs.deleteSync(recursive: true);
    if (src.existsSync()) src.deleteSync(recursive: true);
  });

  IngestFile image(String name) {
    final path = p.join(src.path, name);
    File(path).writeAsBytesSync(_png());
    return IngestFile(path: path, mimeType: 'image/png', name: name);
  }

  IngestQueueController ctrl() =>
      container.read(ingestQueueControllerProvider.notifier);
  IngestQueueState snap() => container.read(ingestQueueControllerProvider);

  test('confirms a two-item queue, saving both', () async {
    await ctrl().start([image('a.png'), image('b.png')], IngestSource.share);
    expect(snap().phase, IngestQueuePhase.confirm);
    expect(snap().total, 2);
    expect(snap().currentIndex, 0);

    await ctrl().confirmCurrent(snap().current!.draft!);
    expect(snap().currentIndex, 1);
    expect(snap().phase, IngestQueuePhase.confirm);

    await ctrl().confirmCurrent(snap().current!.draft!);
    expect(snap().phase, IngestQueuePhase.done);
    expect(snap().savedCount, 2);

    final recent = await container
        .read(documentRepositoryProvider)
        .watchRecent()
        .first;
    expect(recent, hasLength(2));
  });

  test('skipping discards an item without saving it', () async {
    await ctrl().start([image('a.png'), image('b.png')], IngestSource.share);
    await ctrl().skipCurrent();
    await ctrl().confirmCurrent(snap().current!.draft!);
    expect(snap().phase, IngestQueuePhase.done);
    expect(snap().savedCount, 1);
    expect(snap().skippedCount, 1);
  });

  test('unsupported files are marked failed and auto-skipped', () async {
    final txt = p.join(src.path, 'note.txt');
    File(txt).writeAsStringSync('hi');
    await ctrl().start([
      IngestFile(path: txt, mimeType: 'text/plain', name: 'note.txt'),
      image('a.png'),
    ], IngestSource.share);
    expect(snap().phase, IngestQueuePhase.confirm);
    expect(snap().current!.displayName, 'a.png');
    await ctrl().confirmCurrent(snap().current!.draft!);
    expect(snap().phase, IngestQueuePhase.done);
    expect(snap().savedCount, 1);
    expect(snap().failedCount, 1);
  });
}
