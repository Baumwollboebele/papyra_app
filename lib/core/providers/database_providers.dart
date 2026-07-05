import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/repositories/category_repository.dart';
import '../database/repositories/document_repository.dart';
import '../database/repositories/group_repository.dart';
import '../database/repositories/learning_repository.dart';

export '../database/repositories/document_repository.dart' show DocumentSort;

/// The single app database. Overridden in tests with an in-memory instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() async {
    // Tolerate double-close (e.g. during backup restore).
    try {
      await db.close();
    } catch (_) {}
  });
  return db;
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseProvider));
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(ref.watch(databaseProvider));
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(ref.watch(databaseProvider));
});

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(ref.watch(databaseProvider));
});

/// Sub-groups of a category with document counts (reactive).
final groupsWithCountsProvider =
    StreamProvider.family<List<GroupWithCount>, int>((ref, categoryId) {
      return ref.watch(groupRepositoryProvider).watchWithCounts(categoryId);
    });

/// Count of ungrouped documents in a category (reactive).
final ungroupedCountProvider = StreamProvider.family<int, int>((
  ref,
  categoryId,
) {
  return ref.watch(groupRepositoryProvider).watchUngroupedCount(categoryId);
});

/// All categories (reactive), ordered by sortOrder.
final categoriesProvider = StreamProvider((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

/// Categories with document counts (reactive) — used by the library home.
final categoriesWithCountsProvider = StreamProvider<List<CategoryWithCount>>((
  ref,
) {
  return ref.watch(categoryRepositoryProvider).watchWithCounts();
});

/// Recently added documents (reactive) — used by the library home.
final recentDocumentsProvider = StreamProvider((ref) {
  return ref.watch(documentRepositoryProvider).watchRecent();
});

typedef CategoryDocsQuery = ({
  int categoryId,
  DocumentSort sort,
  int? groupId,
  bool ungroupedOnly,
});

/// Documents in a category (reactive), with sort and optional group filter.
final documentsByCategoryProvider =
    StreamProvider.family<List<Document>, CategoryDocsQuery>((ref, query) {
      return ref
          .watch(documentRepositoryProvider)
          .watchByCategory(
            query.categoryId,
            sort: query.sort,
            groupId: query.groupId,
            ungroupedOnly: query.ungroupedOnly,
          );
    });

/// A single document with its pages/tags (reactive): re-fetches whenever the
/// underlying document row changes (edit, favorite, move, tag).
final documentDetailProvider = FutureProvider.family<DocumentDetail?, int>((
  ref,
  id,
) async {
  // Depend on the row stream so edits trigger a refresh.
  ref.watch(_documentRowProvider(id));
  return ref.read(documentRepositoryProvider).getDetail(id);
});

final _documentRowProvider = StreamProvider.family<Document?, int>((ref, id) {
  return ref.watch(documentRepositoryProvider).watchDocument(id);
});
