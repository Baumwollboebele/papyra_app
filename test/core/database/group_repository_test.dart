import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';
import 'package:paperless/core/database/repositories/document_repository.dart';
import 'package:paperless/core/database/repositories/group_repository.dart';

void main() {
  late AppDatabase db;
  late GroupRepository groups;
  late DocumentRepository docs;
  late int vertraege;
  late int rechnungen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    groups = GroupRepository(db);
    docs = DocumentRepository(db);
    final cats = CategoryRepository(db);
    vertraege = (await cats.findByKey(CategoryKeys.vertraege))!.id;
    rechnungen = (await cats.findByKey(CategoryKeys.rechnungen))!.id;
  });

  tearDown(() => db.close());

  Future<int> insert({
    required int categoryId,
    String sender = 'Stadtwerke München GmbH',
    int? groupId,
    String title = 'Doc',
  }) {
    return docs.insertDocument(
      DocumentDraft(
        title: title,
        categoryId: categoryId,
        pdfPath: '/tmp/$title.pdf',
        pageImagePaths: const ['/tmp/p.jpg'],
        sender: sender,
        groupId: groupId,
      ),
    );
  }

  test('getOrCreate is idempotent (case-insensitive)', () async {
    final a = await groups.getOrCreate(vertraege, 'Strom');
    final b = await groups.getOrCreate(vertraege, 'strom');
    expect(a, b);
    expect(await groups.getByCategory(vertraege), hasLength(1));
  });

  test('groups are scoped to their category', () async {
    await groups.getOrCreate(vertraege, 'Strom');
    await groups.getOrCreate(rechnungen, 'Strom');
    expect(await groups.getByCategory(vertraege), hasLength(1));
    expect(await groups.getByCategory(rechnungen), hasLength(1));
  });

  test('watchWithCounts reports document counts per group', () async {
    final strom = await groups.getOrCreate(vertraege, 'Strom');
    await insert(categoryId: vertraege, groupId: strom);
    await insert(categoryId: vertraege, groupId: strom);
    final list = await groups.watchWithCounts(vertraege).first;
    expect(list, hasLength(1));
    expect(list.single.documentCount, 2);
  });

  test('watchByCategory filters by group and ungrouped', () async {
    final strom = await groups.getOrCreate(vertraege, 'Strom');
    await insert(categoryId: vertraege, groupId: strom, title: 'inGroup');
    await insert(categoryId: vertraege, title: 'noGroup');

    final inGroup = await docs
        .watchByCategory(vertraege, groupId: strom)
        .first;
    expect(inGroup.map((d) => d.title), ['inGroup']);

    final ungrouped = await docs
        .watchByCategory(vertraege, ungroupedOnly: true)
        .first;
    expect(ungrouped.map((d) => d.title), ['noGroup']);

    final all = await docs.watchByCategory(vertraege).first;
    expect(all, hasLength(2));
  });

  group('auto-file suggestion by sender', () {
    test('suggests the group a known sender already lives in', () async {
      final strom = await groups.getOrCreate(vertraege, 'Strom');
      await insert(
        categoryId: vertraege,
        sender: 'Stadtwerke München GmbH',
        groupId: strom,
      );
      final suggested = await groups.suggestGroupId(
        vertraege,
        'stadtwerke münchen gmbh', // case-insensitive
      );
      expect(suggested, strom);
    });

    test('returns null for an unknown sender', () async {
      final strom = await groups.getOrCreate(vertraege, 'Strom');
      await insert(categoryId: vertraege, sender: 'Bekannt', groupId: strom);
      expect(await groups.suggestGroupId(vertraege, 'Neuer Absender'), isNull);
      expect(await groups.suggestGroupId(vertraege, null), isNull);
    });

    test('does not suggest across categories', () async {
      final strom = await groups.getOrCreate(vertraege, 'Strom');
      await insert(categoryId: vertraege, sender: 'EnBW', groupId: strom);
      expect(await groups.suggestGroupId(rechnungen, 'EnBW'), isNull);
    });
  });

  test('deleting a group ungroups its documents (keeps the documents)',
      () async {
    final strom = await groups.getOrCreate(vertraege, 'Strom');
    final id = await insert(categoryId: vertraege, groupId: strom);
    await groups.delete(strom);
    final detail = await docs.getDetail(id);
    expect(detail, isNotNull);
    expect(detail!.document.groupId, isNull);
    expect(detail.group, isNull);
  });

  test('moving to another category clears the group', () async {
    final strom = await groups.getOrCreate(vertraege, 'Strom');
    final id = await insert(categoryId: vertraege, groupId: strom);
    await docs.moveToCategory(id, rechnungen);
    final detail = await docs.getDetail(id);
    expect(detail!.document.categoryId, rechnungen);
    expect(detail.document.groupId, isNull);
  });
}
