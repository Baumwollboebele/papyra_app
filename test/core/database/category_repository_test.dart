import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CategoryRepository(db);
  });

  tearDown(() => db.close());

  test('seeds the 9 default categories in order', () async {
    final all = await repo.getAll();
    expect(all.length, kDefaultCategories.length);
    expect(all.first.key, CategoryKeys.rechnungen);
    expect(all.last.key, CategoryKeys.sonstiges);
    expect(all.every((c) => c.isDefault), isTrue);
  });

  test('findByKey resolves the fallback category', () async {
    final sonstiges = await repo.findByKey(CategoryKeys.sonstiges);
    expect(sonstiges, isNotNull);
    expect(sonstiges!.name, 'Sonstiges');
  });

  test('addCustom appends with a generated key and next sort order', () async {
    final id = await repo.addCustom(
      name: 'Auto',
      iconName: 'directions_car',
      colorValue: 0xFF112233,
    );
    final created = await repo.getById(id);
    expect(created.key, 'custom_$id');
    expect(created.isDefault, isFalse);
    expect(created.sortOrder, kDefaultCategories.length);
  });

  test('rename updates the name', () async {
    final rechnungen = await repo.findByKey(CategoryKeys.rechnungen);
    await repo.rename(rechnungen!.id, 'Belege');
    expect((await repo.getById(rechnungen.id)).name, 'Belege');
  });

  test('reorder persists new sort order', () async {
    final all = await repo.getAll();
    final reversed = all.reversed.map((c) => c.id).toList();
    await repo.reorder(reversed);
    final after = await repo.getAll();
    expect(after.map((c) => c.id).toList(), reversed);
  });

  test('delete refuses default categories', () async {
    final rechnungen = await repo.findByKey(CategoryKeys.rechnungen);
    expect(await repo.delete(rechnungen!.id), isFalse);
    expect(await repo.getAll(), hasLength(kDefaultCategories.length));
  });

  test('delete removes an empty custom category', () async {
    final id = await repo.addCustom(
      name: 'Temp',
      iconName: 'folder',
      colorValue: 0xFF000000,
    );
    expect(await repo.delete(id), isTrue);
    expect(await repo.findByKey('custom_$id'), isNull);
  });
}
