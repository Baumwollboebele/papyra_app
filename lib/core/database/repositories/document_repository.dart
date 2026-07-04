import 'package:drift/drift.dart';

import '../app_database.dart';

/// Everything needed to persist a freshly scanned document.
class DocumentDraft {
  const DocumentDraft({
    required this.title,
    required this.categoryId,
    required this.pdfPath,
    required this.pageImagePaths,
    this.thumbnailPath,
    this.sender,
    this.documentDate,
    this.amountCents,
    this.currency = 'EUR',
    this.ocrText = '',
    this.tags = const [],
  });

  final String title;
  final int categoryId;
  final String pdfPath;
  final List<String> pageImagePaths;
  final String? thumbnailPath;
  final String? sender;
  final DateTime? documentDate;
  final int? amountCents;
  final String currency;
  final String ocrText;
  final List<String> tags;
}

/// A document with everything the detail screen needs.
class DocumentDetail {
  const DocumentDetail({
    required this.document,
    required this.category,
    required this.pages,
    required this.tags,
  });

  final Document document;
  final Category category;
  final List<DocumentPage> pages;
  final List<Tag> tags;
}

/// Filesystem paths owned by a document, returned on delete for cleanup.
class DocumentFiles {
  const DocumentFiles({
    required this.pdfPath,
    required this.thumbnailPath,
    required this.pageImagePaths,
  });

  final String pdfPath;
  final String? thumbnailPath;
  final List<String> pageImagePaths;

  Iterable<String> get all => [pdfPath, ?thumbnailPath, ...pageImagePaths];
}

enum DocumentSort { newestFirst, oldestFirst, titleAsc, amountDesc }

/// Filters for full-text search.
class SearchFilters {
  const SearchFilters({
    this.categoryId,
    this.dateFrom,
    this.dateTo,
    this.favoritesOnly = false,
  });

  final int? categoryId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool favoritesOnly;

  bool get isEmpty =>
      categoryId == null &&
      dateFrom == null &&
      dateTo == null &&
      !favoritesOnly;
}

/// All reads/writes for documents, pages and tags, plus FTS synchronization.
class DocumentRepository {
  DocumentRepository(this._db);

  final AppDatabase _db;

  // --- Reads -----------------------------------------------------------------

  Stream<List<Document>> watchRecent({int limit = 10}) {
    return (_db.select(_db.documents)
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)])
          ..limit(limit))
        .watch();
  }

  Stream<List<Document>> watchByCategory(
    int categoryId, {
    DocumentSort sort = DocumentSort.newestFirst,
  }) {
    final query = _db.select(_db.documents)
      ..where((d) => d.categoryId.equals(categoryId))
      ..orderBy([_orderingFor(sort)]);
    return query.watch();
  }

  Stream<Document?> watchDocument(int id) {
    return (_db.select(
      _db.documents,
    )..where((d) => d.id.equals(id))).watchSingleOrNull();
  }

  OrderingTerm Function($DocumentsTable) _orderingFor(DocumentSort sort) {
    switch (sort) {
      case DocumentSort.newestFirst:
        return (d) =>
            OrderingTerm.desc(coalesce([d.documentDate, d.createdAt]));
      case DocumentSort.oldestFirst:
        return (d) => OrderingTerm.asc(coalesce([d.documentDate, d.createdAt]));
      case DocumentSort.titleAsc:
        return (d) => OrderingTerm.asc(d.title);
      case DocumentSort.amountDesc:
        return (d) => OrderingTerm.desc(d.amountCents);
    }
  }

  Future<DocumentDetail?> getDetail(int id) async {
    final document = await (_db.select(
      _db.documents,
    )..where((d) => d.id.equals(id))).getSingleOrNull();
    if (document == null) return null;
    final category = await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(document.categoryId))).getSingle();
    final pages =
        await (_db.select(_db.documentPages)
              ..where((pg) => pg.documentId.equals(id))
              ..orderBy([(pg) => OrderingTerm(expression: pg.pageIndex)]))
            .get();
    final tags = await _tagsFor(id);
    return DocumentDetail(
      document: document,
      category: category,
      pages: pages,
      tags: tags,
    );
  }

  Future<List<Tag>> _tagsFor(int documentId) async {
    final query =
        _db.select(_db.tags).join([
            innerJoin(
              _db.documentTags,
              _db.documentTags.tagId.equalsExp(_db.tags.id),
            ),
          ])
          ..where(_db.documentTags.documentId.equals(documentId))
          ..orderBy([OrderingTerm.asc(_db.tags.name)]);
    final rows = await query.get();
    return rows.map((r) => r.readTable(_db.tags)).toList();
  }

  // --- Writes ----------------------------------------------------------------

  /// Persists a scanned document with its pages and tags, then indexes it.
  /// Returns the new document id.
  Future<int> insertDocument(DocumentDraft draft) {
    return _db.transaction(() async {
      final id = await _db
          .into(_db.documents)
          .insert(
            DocumentsCompanion.insert(
              title: draft.title,
              categoryId: draft.categoryId,
              sender: Value(draft.sender),
              documentDate: Value(draft.documentDate),
              createdAt: DateTime.now(),
              amountCents: Value(draft.amountCents),
              currency: Value(draft.currency),
              pdfPath: draft.pdfPath,
              thumbnailPath: Value(draft.thumbnailPath),
              ocrText: Value(draft.ocrText),
              pageCount: Value(draft.pageImagePaths.length),
            ),
          );
      for (var i = 0; i < draft.pageImagePaths.length; i++) {
        await _db
            .into(_db.documentPages)
            .insert(
              DocumentPagesCompanion.insert(
                documentId: id,
                pageIndex: i,
                imagePath: draft.pageImagePaths[i],
              ),
            );
      }
      for (final name in draft.tags) {
        final tagId = await _getOrCreateTag(name);
        await _db
            .into(_db.documentTags)
            .insert(
              DocumentTagsCompanion.insert(documentId: id, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await _reindex(id);
      return id;
    });
  }

  Future<void> updateMetadata(
    int id, {
    required String title,
    required int categoryId,
    String? sender,
    DateTime? documentDate,
    int? amountCents,
    String? currency,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(
        DocumentsCompanion(
          title: Value(title),
          categoryId: Value(categoryId),
          sender: Value(sender),
          documentDate: Value(documentDate),
          amountCents: Value(amountCents),
          currency: currency == null ? const Value.absent() : Value(currency),
        ),
      );
      await _reindex(id);
    });
  }

  Future<void> moveToCategory(int id, int categoryId) {
    return (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(
      DocumentsCompanion(categoryId: Value(categoryId)),
    );
  }

  Future<void> setFavorite(int id, bool value) {
    return (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(
      DocumentsCompanion(isFavorite: Value(value)),
    );
  }

  Future<void> setTags(int id, List<String> tagNames) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.documentTags,
      )..where((t) => t.documentId.equals(id))).go();
      for (final name in tagNames) {
        final tagId = await _getOrCreateTag(name);
        await _db
            .into(_db.documentTags)
            .insert(
              DocumentTagsCompanion.insert(documentId: id, tagId: tagId),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await _reindex(id);
    });
  }

  /// Removes the document and its rows, returns file paths for cleanup.
  Future<DocumentFiles?> deleteDocument(int id) async {
    return _db.transaction(() async {
      final document = await (_db.select(
        _db.documents,
      )..where((d) => d.id.equals(id))).getSingleOrNull();
      if (document == null) return null;
      final pages = await (_db.select(
        _db.documentPages,
      )..where((pg) => pg.documentId.equals(id))).get();
      await (_db.delete(_db.documents)..where((d) => d.id.equals(id))).go();
      await _deleteFtsRow(id);
      return DocumentFiles(
        pdfPath: document.pdfPath,
        thumbnailPath: document.thumbnailPath,
        pageImagePaths: pages.map((pg) => pg.imagePath).toList(),
      );
    });
  }

  Future<int> _getOrCreateTag(String rawName) async {
    final name = rawName.trim();
    final existing = await (_db.select(
      _db.tags,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.tags).insert(TagsCompanion.insert(name: name));
  }

  // --- FTS synchronization ---------------------------------------------------

  Future<void> _reindex(int id) async {
    final document = await (_db.select(
      _db.documents,
    )..where((d) => d.id.equals(id))).getSingleOrNull();
    if (document == null) return;
    final tags = await _tagsFor(id);
    final tagText = tags.map((t) => t.name).join(' ');
    await _deleteFtsRow(id);
    await _db.customInsert(
      'INSERT INTO documents_fts(rowid, title, sender, ocr_text, tags) '
      'VALUES(?, ?, ?, ?, ?)',
      variables: [
        Variable.withInt(id),
        Variable.withString(document.title),
        Variable.withString(document.sender ?? ''),
        Variable.withString(document.ocrText),
        Variable.withString(tagText),
      ],
    );
  }

  Future<void> _deleteFtsRow(int id) {
    return _db.customStatement('DELETE FROM documents_fts WHERE rowid = ?', [
      id,
    ]);
  }

  // --- Search ----------------------------------------------------------------

  /// Full-text search with optional [filters]. Ranked by BM25.
  Future<List<Document>> search(
    String rawQuery, {
    SearchFilters filters = const SearchFilters(),
  }) async {
    final match = _toFtsQuery(rawQuery);
    if (match == null) {
      // No usable query terms: fall back to filter-only browsing.
      return _searchFiltersOnly(filters);
    }

    final where = StringBuffer('documents_fts MATCH ?');
    final vars = <Variable>[Variable.withString(match)];
    _appendFilters(where, vars, filters, tableAlias: 'd');

    final rows = await _db
        .customSelect(
          '''
      SELECT d.* FROM documents_fts f
      JOIN documents d ON d.id = f.rowid
      WHERE $where
      ORDER BY bm25(documents_fts), d.created_at DESC
      ''',
          variables: vars,
          readsFrom: {_db.documents},
        )
        .get();
    return rows.map((r) => _db.documents.map(r.data)).toList();
  }

  Future<List<Document>> _searchFiltersOnly(SearchFilters filters) async {
    if (filters.isEmpty) return [];
    final where = StringBuffer('1 = 1');
    final vars = <Variable>[];
    _appendFilters(where, vars, filters, tableAlias: 'd');
    final rows = await _db
        .customSelect(
          'SELECT d.* FROM documents d WHERE $where ORDER BY d.created_at DESC',
          variables: vars,
          readsFrom: {_db.documents},
        )
        .get();
    return rows.map((r) => _db.documents.map(r.data)).toList();
  }

  void _appendFilters(
    StringBuffer where,
    List<Variable> vars,
    SearchFilters filters, {
    required String tableAlias,
  }) {
    if (filters.categoryId != null) {
      where.write(' AND $tableAlias.category_id = ?');
      vars.add(Variable.withInt(filters.categoryId!));
    }
    if (filters.favoritesOnly) {
      where.write(' AND $tableAlias.is_favorite = 1');
    }
    if (filters.dateFrom != null) {
      where.write(' AND $tableAlias.document_date >= ?');
      vars.add(
        Variable.withInt(filters.dateFrom!.millisecondsSinceEpoch ~/ 1000),
      );
    }
    if (filters.dateTo != null) {
      where.write(' AND $tableAlias.document_date <= ?');
      vars.add(
        Variable.withInt(filters.dateTo!.millisecondsSinceEpoch ~/ 1000),
      );
    }
  }

  /// Turns free user input into a safe FTS5 prefix query, or null if there are
  /// no usable terms. Each token is quoted (quotes doubled) and prefix-matched.
  static String? _toFtsQuery(String raw) {
    final tokens = raw
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;
    return tokens
        .map((t) {
          final escaped = t.replaceAll('"', '""');
          return '"$escaped"*';
        })
        .join(' ');
  }
}
