import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';
import 'package:paperless/core/database/repositories/group_repository.dart';
import 'package:paperless/core/providers/database_providers.dart';
import 'package:paperless/core/services/file_service.dart';
import 'package:paperless/core/services/ocr_service.dart';
import 'package:paperless/core/services/pdf_rasterizer.dart';
import 'package:paperless/features/scan/domain/pipeline/ingest_models.dart';
import 'package:paperless/features/scan/presentation/ingest_flow_page.dart';
import 'package:paperless/l10n/app_localizations.dart';

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

  setUp(() {
    docs = Directory.systemTemp.createTempSync('flow_docs');
    src = Directory.systemTemp.createTempSync('flow_src');
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() {
    db.close();
    if (docs.existsSync()) docs.deleteSync(recursive: true);
    if (src.existsSync()) src.deleteSync(recursive: true);
  });

  IngestFile image(String name) {
    final path = p.join(src.path, name);
    File(path).writeAsBytesSync(_png());
    return IngestFile(path: path, mimeType: 'image/png', name: name);
  }

  Widget wrap(IngestRequest request) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        fileServiceProvider.overrideWithValue(
          FileService(documentsDirectory: () async => docs),
        ),
        ocrServiceProvider.overrideWithValue(_FixedOcr()),
        pdfRasterizerProvider.overrideWithValue(FakePdfRasterizer([_png()])),
        // Plain (non-drift) streams so widget teardown leaves no timer pending.
        categoriesProvider.overrideWith(
          (ref) => Stream.fromFuture(CategoryRepository(db).getAll()),
        ),
        groupsWithCountsProvider.overrideWith(
          (ref, id) => Stream.value(const <GroupWithCount>[]),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('de'), Locale('en')],
        home: IngestFlowPage(request: request),
      ),
    );
  }

  testWidgets('shows a per-document queue and finishes via skip', (
    tester,
  ) async {
    // The flow does real file IO + drift work; runAsync lets it complete.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        wrap(
          IngestRequest(
            files: [image('a.png'), image('b.png')],
            source: IngestSource.share,
          ),
        ),
      );
      await tester.pump(); // fire the post-frame start()
      await Future<void>.delayed(const Duration(milliseconds: 800));
      await tester.pump(); // render the first confirmation

      expect(find.textContaining('von 2'), findsOneWidget);
      expect(find.text('Speichern'), findsOneWidget);

      await tester.tap(find.text('Überspringen'));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await tester.pump();
      expect(find.textContaining('von 2'), findsOneWidget);

      await tester.tap(find.text('Überspringen'));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await tester.pump();

      expect(find.text('Import abgeschlossen'), findsOneWidget);
      expect(find.textContaining('übersprungen'), findsOneWidget);
    });
  });
}
