import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/core/database/repositories/learning_repository.dart';

void main() {
  late AppDatabase db;
  late LearningRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = LearningRepository(db);
  });
  tearDown(() => db.close());

  test('records and looks up a sender → category mapping', () async {
    await repo.recordChoice('Stadtwerke München GmbH', CategoryKeys.vertraege);
    expect(
      await repo.lookup('Stadtwerke München GmbH'),
      CategoryKeys.vertraege,
    );
  });

  test('lookup is normalized (case + umlaut folding)', () async {
    await repo.recordChoice('Stadtwerke München', CategoryKeys.rechnungen);
    expect(await repo.lookup('STADTWERKE MUENCHEN'), CategoryKeys.rechnungen);
  });

  test('a later choice overwrites the mapping', () async {
    await repo.recordChoice('Allianz', CategoryKeys.rechnungen);
    await repo.recordChoice('Allianz', CategoryKeys.versicherungen);
    expect(await repo.lookup('Allianz'), CategoryKeys.versicherungen);
  });

  test('empty / null senders are ignored', () async {
    await repo.recordChoice(null, CategoryKeys.rechnungen);
    await repo.recordChoice('   ', CategoryKeys.rechnungen);
    expect(await repo.lookup(null), isNull);
    expect(await repo.lookup('Unbekannt'), isNull);
  });

  test('forget removes a mapping', () async {
    await repo.recordChoice('DKB', CategoryKeys.bank);
    await repo.forget('DKB');
    expect(await repo.lookup('DKB'), isNull);
  });
}
