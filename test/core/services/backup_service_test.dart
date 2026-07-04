import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:paperless/core/services/backup_service.dart';

void main() {
  late Directory docs;
  late Directory temp;
  late BackupService service;

  setUp(() {
    docs = Directory.systemTemp.createTempSync('pv_docs');
    temp = Directory.systemTemp.createTempSync('pv_temp');
    service = BackupService(
      documentsDirectory: () async => docs,
      temporaryDirectory: () async => temp,
    );

    // Seed a fake database file and media files.
    File(p.join(docs.path, 'papyra.sqlite')).writeAsBytesSync([1, 2, 3, 4]);
    for (final rel in ['pages/a.jpg', 'thumbnails/a.jpg', 'pdfs/a.pdf']) {
      final f = File(p.join(docs.path, 'papyra', rel));
      f.parent.createSync(recursive: true);
      f.writeAsStringSync('content-$rel');
    }
  });

  tearDown(() {
    if (docs.existsSync()) docs.deleteSync(recursive: true);
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });

  test(
    'createBackup produces a zip containing db, media and manifest',
    () async {
      final zipPath = await service.createBackup();
      expect(File(zipPath).existsSync(), isTrue);
      expect(p.extension(zipPath), '.zip');
      expect(File(zipPath).lengthSync(), greaterThan(0));
    },
  );

  test('restore reconstructs the database and media files', () async {
    final zipPath = await service.createBackup();

    // Simulate data loss.
    Directory(p.join(docs.path, 'papyra')).deleteSync(recursive: true);
    File(p.join(docs.path, 'papyra.sqlite')).deleteSync();

    var closed = false;
    await service.restoreBackup(
      zipPath,
      closeActiveDatabase: () async => closed = true,
    );

    expect(closed, isTrue);
    expect(File(p.join(docs.path, 'papyra.sqlite')).readAsBytesSync(), [
      1,
      2,
      3,
      4,
    ]);
    expect(
      File(p.join(docs.path, 'papyra', 'pages', 'a.jpg')).readAsStringSync(),
      'content-pages/a.jpg',
    );
    expect(
      File(p.join(docs.path, 'papyra', 'pdfs', 'a.pdf')).existsSync(),
      isTrue,
    );
  });

  test('restore rejects a file that is not a valid backup', () async {
    final bogus = File(p.join(temp.path, 'bogus.zip'))
      ..writeAsBytesSync([9, 9, 9]);
    expect(
      () => service.restoreBackup(bogus.path, closeActiveDatabase: () async {}),
      throwsA(isA<BackupException>()),
    );
  });
}
