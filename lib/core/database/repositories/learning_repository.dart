import '../../../features/scan/domain/classification/text_normalizer.dart';
import '../app_database.dart';

/// On-device learning of sender → category mappings. When the user confirms a
/// document, the sender's normalized text is remembered so future documents
/// from the same sender are classified into that category. Purely local.
class LearningRepository {
  LearningRepository(this._db);
  final AppDatabase _db;

  /// Remembers that [sender] belongs to [categoryKey]. No-op for empty senders.
  Future<void> recordChoice(String? sender, String categoryKey) async {
    final norm = _norm(sender);
    if (norm == null) return;
    await _db
        .into(_db.senderCategories)
        .insertOnConflictUpdate(
          SenderCategoriesCompanion.insert(
            senderNorm: norm,
            categoryKey: categoryKey,
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// The learned category key for [sender], or null.
  Future<String?> lookup(String? sender) async {
    final norm = _norm(sender);
    if (norm == null) return null;
    final row = await (_db.select(
      _db.senderCategories,
    )..where((t) => t.senderNorm.equals(norm))).getSingleOrNull();
    return row?.categoryKey;
  }

  /// Removes any learned mapping for [sender].
  Future<void> forget(String? sender) async {
    final norm = _norm(sender);
    if (norm == null) return;
    await (_db.delete(
      _db.senderCategories,
    )..where((t) => t.senderNorm.equals(norm))).go();
  }

  String? _norm(String? sender) {
    if (sender == null) return null;
    final norm = normalizeForMatching(sender).trim();
    return norm.isEmpty ? null : norm;
  }
}
