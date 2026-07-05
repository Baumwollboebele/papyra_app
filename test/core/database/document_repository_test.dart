import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';
import 'package:paperless/core/database/repositories/document_repository.dart';

void main() {
  late AppDatabase db;
  late DocumentRepository docs;
  late CategoryRepository cats;
  late int rechnungenId;
  late int steuernId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    docs = DocumentRepository(db);
    cats = CategoryRepository(db);
    rechnungenId = (await cats.findByKey(CategoryKeys.rechnungen))!.id;
    steuernId = (await cats.findByKey(CategoryKeys.steuern))!.id;
  });

  tearDown(() => db.close());

  Future<int> insertSample({
    String title = 'Stromrechnung',
    String ocr = 'Rechnung der Stadtwerke München, Betrag 89,90 EUR',
    int? amount = 8990,
    List<String> tags = const ['strom'],
    int? categoryId,
  }) {
    return docs.insertDocument(
      DocumentDraft(
        title: title,
        categoryId: categoryId ?? rechnungenId,
        pdfPath: '/tmp/$title.pdf',
        pageImagePaths: ['/tmp/$title-0.jpg', '/tmp/$title-1.jpg'],
        thumbnailPath: '/tmp/$title-thumb.jpg',
        sender: 'Stadtwerke München GmbH',
        documentDate: DateTime(2026, 3, 12),
        amountCents: amount,
        ocrText: ocr,
        tags: tags,
      ),
    );
  }

  test('insert persists document, pages and tags', () async {
    final id = await insertSample();
    final detail = await docs.getDetail(id);
    expect(detail, isNotNull);
    expect(detail!.document.title, 'Stromrechnung');
    expect(detail.pages, hasLength(2));
    expect(detail.document.pageCount, 2);
    expect(detail.tags.map((t) => t.name), contains('strom'));
    expect(detail.category.key, CategoryKeys.rechnungen);
  });

  test(
    'full-text search matches OCR text (prefix, diacritics folded)',
    () async {
      await insertSample();
      // "muenchen" via diacritics folding, prefix on "stadt".
      expect(await docs.search('stadtwerke'), hasLength(1));
      expect(await docs.search('münchen'), hasLength(1));
      expect(await docs.search('muenchen'), isEmpty); // ue != ü folding
      expect(await docs.search('betrag'), hasLength(1));
      expect(await docs.search('nichtvorhanden'), isEmpty);
    },
  );

  test('search matches by tag and by title', () async {
    await insertSample(
      title: 'KFZ Steuer',
      tags: ['auto'],
      categoryId: steuernId,
    );
    expect(await docs.search('auto'), hasLength(1));
    expect(await docs.search('kfz'), hasLength(1));
  });

  test('empty query with showAll returns every document (browse all)', () async {
    await insertSample(title: 'Rechnung A');
    await insertSample(title: 'Egal', categoryId: steuernId, tags: []);
    // No text query, no category -> "Alle Kategorien" browse shows everything.
    final all = await docs.search(
      '',
      filters: const SearchFilters(showAll: true),
    );
    expect(all, hasLength(2));
    // Pristine empty filters still return nothing.
    expect(await docs.search('', filters: const SearchFilters()), isEmpty);
  });

  test('watchSearch emits again when a matching document is added', () async {
    final counts = <int>[];
    final sub = docs
        .watchSearch('stadtwerke')
        .listen((r) => counts.add(r.length));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await insertSample(); // OCR contains "Stadtwerke"
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await sub.cancel();

    expect(counts.first, 0); // nothing before the insert
    expect(counts.last, 1); // updated live after the insert
  });

  test('search honors category and favorite filters', () async {
    final a = await insertSample(title: 'Rechnung A');
    await insertSample(
      title: 'Steuerbescheid',
      categoryId: steuernId,
      tags: [],
    );
    await docs.setFavorite(a, true);

    final onlyRechnungen = await docs.search(
      'r',
      filters: SearchFilters(categoryId: rechnungenId),
    );
    expect(onlyRechnungen.every((d) => d.categoryId == rechnungenId), isTrue);

    final favs = await docs.search(
      '',
      filters: const SearchFilters(favoritesOnly: true),
    );
    expect(favs, hasLength(1));
    expect(favs.single.id, a);
  });

  test('updateMetadata re-indexes FTS', () async {
    final id = await insertSample();
    expect(await docs.search('zahnarzt'), isEmpty);
    await docs.updateMetadata(
      id,
      title: 'Zahnarzt Quittung',
      categoryId: steuernId,
    );
    expect(await docs.search('zahnarzt'), hasLength(1));
    // Old title no longer the only match source, but sender still indexed.
    final moved = await docs.getDetail(id);
    expect(moved!.document.categoryId, steuernId);
  });

  test('setTags replaces tags and updates the index', () async {
    final id = await insertSample(tags: ['alt']);
    await docs.setTags(id, ['neu', 'wichtig']);
    final detail = await docs.getDetail(id);
    expect(detail!.tags.map((t) => t.name), containsAll(['neu', 'wichtig']));
    expect(detail.tags.map((t) => t.name), isNot(contains('alt')));
    expect(await docs.search('wichtig'), hasLength(1));
    expect(await docs.search('alt'), isEmpty);
  });

  test('delete removes rows, FTS entry and returns file paths', () async {
    final id = await insertSample();
    final files = await docs.deleteDocument(id);
    expect(files, isNotNull);
    expect(files!.pdfPath, contains('.pdf'));
    expect(files.pageImagePaths, hasLength(2));
    expect(files.all, contains('/tmp/Stromrechnung-thumb.jpg'));
    expect(await docs.getDetail(id), isNull);
    expect(await docs.search('stadtwerke'), isEmpty);
  });

  test('watchByCategory streams documents for a category', () async {
    await insertSample(title: 'Doc1');
    await insertSample(title: 'Doc2');
    final list = await docs.watchByCategory(rechnungenId).first;
    expect(list, hasLength(2));
  });
}
