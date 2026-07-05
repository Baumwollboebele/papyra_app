import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';
import 'package:paperless/core/database/repositories/document_repository.dart';
import 'package:paperless/core/database/repositories/group_repository.dart';
import 'package:paperless/core/database/repositories/learning_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test(
    'v2 → v3 migration adds learning table and keeps existing data',
    () async {
      final dir = Directory.systemTemp.createTempSync('migr');
      final file = File(p.join(dir.path, 'papyra.sqlite'));

      // 1. Create a database with real user data.
      var db = AppDatabase.forTesting(NativeDatabase(file));
      final rechnungen = (await CategoryRepository(
        db,
      ).findByKey(CategoryKeys.rechnungen))!;
      final groupId = await GroupRepository(
        db,
      ).getOrCreate(rechnungen.id, 'Strom');
      final docId = await DocumentRepository(db).insertDocument(
        DocumentDraft(
          title: 'Stromrechnung',
          categoryId: rechnungen.id,
          pdfPath: '/tmp/a.pdf',
          pageImagePaths: const ['/tmp/a-0.jpg'],
          sender: 'Stadtwerke München',
          groupId: groupId,
        ),
      );
      await db.close();

      // 2. Make the file look like a v2 database: no learning table, version 2.
      final raw = sqlite3.open(file.path);
      raw.execute('DROP TABLE sender_categories');
      raw.execute('PRAGMA user_version = 2');
      raw.close();

      // 3. Reopen — the v2 → v3 upgrade runs.
      db = AppDatabase.forTesting(NativeDatabase(file));
      final docs = await DocumentRepository(db).watchRecent().first;

      // Existing data survived the migration.
      expect(docs, hasLength(1));
      final detail = await DocumentRepository(db).getDetail(docId);
      expect(detail!.document.title, 'Stromrechnung');
      expect(detail.group?.name, 'Strom');

      // The new learning table exists and works.
      final learning = LearningRepository(db);
      await learning.recordChoice(
        'Stadtwerke München',
        CategoryKeys.rechnungen,
      );
      expect(
        await learning.lookup('Stadtwerke München'),
        CategoryKeys.rechnungen,
      );

      await db.close();
      dir.deleteSync(recursive: true);
    },
  );
}
