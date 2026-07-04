import 'package:drift/drift.dart';

import '../app_database.dart';

/// A sub-group together with how many documents it holds.
class GroupWithCount {
  const GroupWithCount(this.group, this.documentCount);
  final Group group;
  final int documentCount;
}

/// Reads/writes for [Groups] (sub-categories) plus the auto-file lookup.
class GroupRepository {
  GroupRepository(this._db);

  final AppDatabase _db;

  /// Groups of a category with document counts, ordered by sortOrder then name.
  Stream<List<GroupWithCount>> watchWithCounts(int categoryId) {
    final rows = _db.customSelect(
      '''
      SELECT g.*, (
        SELECT COUNT(*) FROM documents d WHERE d.group_id = g.id
      ) AS doc_count
      FROM groups g
      WHERE g.category_id = ?
      ORDER BY g.sort_order ASC, g.name COLLATE NOCASE ASC
      ''',
      variables: [Variable.withInt(categoryId)],
      readsFrom: {_db.groups, _db.documents},
    );
    return rows.watch().map(
      (list) => list
          .map(
            (row) => GroupWithCount(
              _db.groups.map(row.data),
              row.read<int>('doc_count'),
            ),
          )
          .toList(),
    );
  }

  /// Number of documents in the category that are not in any group.
  Stream<int> watchUngroupedCount(int categoryId) {
    final rows = _db.customSelect(
      'SELECT COUNT(*) AS c FROM documents '
      'WHERE category_id = ? AND group_id IS NULL',
      variables: [Variable.withInt(categoryId)],
      readsFrom: {_db.documents},
    );
    return rows.watch().map((list) => list.first.read<int>('c'));
  }

  Future<List<Group>> getByCategory(int categoryId) {
    return (_db.select(_db.groups)
          ..where((g) => g.categoryId.equals(categoryId))
          ..orderBy([
            (g) => OrderingTerm(expression: g.sortOrder),
            (g) => OrderingTerm.asc(g.name),
          ]))
        .get();
  }

  Future<int> create(int categoryId, String name) async {
    final maxOrder = await _db
        .customSelect(
          'SELECT COALESCE(MAX(sort_order), -1) AS m FROM groups WHERE category_id = ?',
          variables: [Variable.withInt(categoryId)],
        )
        .getSingle();
    return _db
        .into(_db.groups)
        .insert(
          GroupsCompanion.insert(
            categoryId: categoryId,
            name: name.trim(),
            sortOrder: Value(maxOrder.read<int>('m') + 1),
          ),
        );
  }

  /// Returns the id of an existing group with [name] in the category (case
  /// insensitive), or creates one.
  Future<int> getOrCreate(int categoryId, String name) async {
    final trimmed = name.trim();
    final existing =
        await (_db.select(_db.groups)..where(
              (g) =>
                  g.categoryId.equals(categoryId) &
                  g.name.lower().equals(trimmed.toLowerCase()),
            ))
            .getSingleOrNull();
    if (existing != null) return existing.id;
    return create(categoryId, trimmed);
  }

  Future<void> rename(int id, String name) {
    return (_db.update(_db.groups)..where((g) => g.id.equals(id))).write(
      GroupsCompanion(name: Value(name.trim())),
    );
  }

  Future<void> delete(int id) {
    // Documents' group_id is set to NULL via the foreign key action.
    return (_db.delete(_db.groups)..where((g) => g.id.equals(id))).go();
  }

  /// Suggests a group for a newly scanned document: the most recent group in
  /// [categoryId] that already contains a document from the same [sender].
  /// Returns null when there is no match (unknown sender / no groups yet).
  Future<int?> suggestGroupId(int categoryId, String? sender) async {
    if (sender == null || sender.trim().isEmpty) return null;
    final row = await _db
        .customSelect(
          '''
          SELECT d.group_id AS gid FROM documents d
          WHERE d.category_id = ?
            AND d.group_id IS NOT NULL
            AND lower(d.sender) = lower(?)
          ORDER BY d.created_at DESC
          LIMIT 1
          ''',
          variables: [
            Variable.withInt(categoryId),
            Variable.withString(sender.trim()),
          ],
          readsFrom: {_db.documents},
        )
        .getSingleOrNull();
    return row?.read<int?>('gid');
  }
}
