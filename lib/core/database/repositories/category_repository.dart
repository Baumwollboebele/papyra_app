import 'package:drift/drift.dart';

import '../app_database.dart';

/// A category together with how many documents it holds.
class CategoryWithCount {
  const CategoryWithCount(this.category, this.documentCount);

  final Category category;
  final int documentCount;
}

/// All reads/writes for [Categories]. UI depends on this, never on drift.
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<Category>> watchAll() {
    return (_db.select(
      _db.categories,
    )..orderBy([(c) => OrderingTerm(expression: c.sortOrder)])).watch();
  }

  Future<List<Category>> getAll() {
    return (_db.select(
      _db.categories,
    )..orderBy([(c) => OrderingTerm(expression: c.sortOrder)])).get();
  }

  Future<Category?> findByKey(String key) {
    return (_db.select(
      _db.categories,
    )..where((c) => c.key.equals(key))).getSingleOrNull();
  }

  Future<Category> getById(int id) {
    return (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(id))).getSingle();
  }

  /// Categories with document counts, ordered by [Categories.sortOrder].
  Stream<List<CategoryWithCount>> watchWithCounts() {
    final rows = _db.customSelect(
      '''
      SELECT c.*, (
        SELECT COUNT(*) FROM documents d WHERE d.category_id = c.id
      ) AS doc_count
      FROM categories c
      ORDER BY c.sort_order ASC
      ''',
      readsFrom: {_db.categories, _db.documents},
    );
    return rows.watch().map((list) {
      return list
          .map(
            (row) => CategoryWithCount(
              _db.categories.map(row.data),
              row.read<int>('doc_count'),
            ),
          )
          .toList();
    });
  }

  /// Creates a custom category. The stable [Categories.key] is derived from the
  /// row id (`custom_<id>`) so it never collides with default keys.
  Future<int> addCustom({
    required String name,
    required String iconName,
    required int colorValue,
  }) async {
    return _db.transaction(() async {
      final maxOrder = await _db
          .customSelect(
            'SELECT COALESCE(MAX(sort_order), -1) AS m FROM categories',
          )
          .getSingle();
      final nextOrder = maxOrder.read<int>('m') + 1;
      final id = await _db
          .into(_db.categories)
          .insert(
            CategoriesCompanion.insert(
              key: 'pending',
              name: name,
              iconName: Value(iconName),
              colorValue: colorValue,
              isDefault: const Value(false),
              sortOrder: Value(nextOrder),
            ),
          );
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(key: Value('custom_$id')),
      );
      return id;
    });
  }

  Future<void> rename(int id, String name) {
    return (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(name: Value(name)),
    );
  }

  Future<void> updateAppearance(
    int id, {
    required String iconName,
    required int colorValue,
  }) {
    return (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        iconName: Value(iconName),
        colorValue: Value(colorValue),
      ),
    );
  }

  /// Persists a new ordering. [orderedIds] is the full list top-to-bottom.
  Future<void> reorder(List<int> orderedIds) {
    return _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.categories)
              ..where((c) => c.id.equals(orderedIds[i])))
            .write(CategoriesCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// Number of documents currently filed under [categoryId].
  Future<int> documentCount(int categoryId) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM documents WHERE category_id = ?',
          variables: [Variable.withInt(categoryId)],
          readsFrom: {_db.documents},
        )
        .getSingle();
    return row.read<int>('c');
  }

  /// Deletes a category. Only allowed when empty and not a default.
  /// Returns false if the category still holds documents.
  Future<bool> delete(int id) async {
    final category = await getById(id);
    if (category.isDefault) return false;
    if (await documentCount(id) > 0) return false;
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    return true;
  }
}
