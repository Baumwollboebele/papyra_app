import 'package:drift/drift.dart';

/// Smart categories. Seeded with 9 defaults; users may add their own.
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable identifier used by the classifier (see [CategoryKeys]).
  /// Custom categories get a generated `custom_<id>` key.
  TextColumn get key => text().withLength(min: 1, max: 64).unique()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get iconName => text().withDefault(const Constant('folder'))();
  IntColumn get colorValue => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// User-defined sub-groups within a category (e.g. "Strom",
/// "Internet/Telefonie" inside Verträge). Documents are auto-filed into a group
/// when their sender matches one already in that group.
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// A saved document = generated PDF + metadata + OCR text.
class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 300)();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.restrict)();

  /// Optional sub-group within the category.
  IntColumn get groupId =>
      integer().nullable().references(Groups, #id, onDelete: KeyAction.setNull)();
  TextColumn get sender => text().nullable()();
  DateTimeColumn get documentDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get amountCents => integer().nullable()();
  TextColumn get currency =>
      text().withLength(max: 3).withDefault(const Constant('EUR'))();
  TextColumn get pdfPath => text()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get ocrText => text().withDefault(const Constant(''))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get pageCount => integer().withDefault(const Constant(1))();
}

/// Individual scanned page images backing a document.
class DocumentPages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get pageIndex => integer()();
  TextColumn get imagePath => text()();
}

/// Free-form tags.
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60).unique()();
}

/// m:n between documents and tags.
class DocumentTags extends Table {
  IntColumn get documentId =>
      integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {documentId, tagId};
}
