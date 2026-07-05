import 'package:drift/drift.dart';

import 'connection.dart';
import 'default_categories.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The single SQLite database for Papyra.
///
/// Full-text search uses an FTS5 virtual table (`documents_fts`) that is kept
/// in sync from the repository layer (see DocumentRepository). Categories are
/// seeded on first open.
@DriftDatabase(
  tables: [
    Categories,
    Groups,
    Documents,
    DocumentPages,
    Tags,
    DocumentTags,
    SenderCategories,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppConnection());

  /// For tests: pass `NativeDatabase.memory()`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createFtsTable();
      await _seedCategories();
    },
    onUpgrade: (m, from, to) async {
      // v2: sub-groups within categories.
      if (from < 2) {
        await m.createTable(groups);
        await m.addColumn(documents, documents.groupId);
      }
      // v3: local sender -> category learning.
      if (from < 3) {
        await m.createTable(senderCategories);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Defensive: ensure defaults exist even if a prior create was partial.
      if (details.wasCreated) return;
      final count = await (selectOnly(
        categories,
      )..addColumns([categories.id.count()])).getSingle();
      if ((count.read(categories.id.count()) ?? 0) == 0) {
        await _seedCategories();
      }
    },
  );

  Future<void> _createFtsTable() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS documents_fts USING fts5(
        title,
        sender,
        ocr_text,
        tags,
        tokenize = 'unicode61 remove_diacritics 2'
      );
    ''');
  }

  Future<void> _seedCategories() async {
    await batch((b) {
      b.insertAllOnConflictUpdate(categories, [
        for (final c in kDefaultCategories)
          CategoriesCompanion.insert(
            key: c.key,
            name: c.defaultName,
            iconName: Value(c.iconName),
            colorValue: c.color.toARGB32(),
            isDefault: const Value(true),
            sortOrder: Value(c.sortOrder),
          ),
      ]);
    });
  }
}
