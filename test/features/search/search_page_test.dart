import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';
import 'package:paperless/core/database/repositories/document_repository.dart';
import 'package:paperless/core/providers/database_providers.dart';
import 'package:paperless/features/library/presentation/document_list_tile.dart';
import 'package:paperless/features/search/presentation/search_page.dart';
import 'package:paperless/features/search/presentation/search_providers.dart';
import 'package:paperless/l10n/app_localizations.dart';

Widget _wrap(AppDatabase db) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      // Override the only drift *stream* the page uses with a plain stream, so
      // disposing the tree doesn't leave drift's stream-close timer pending.
      categoriesProvider.overrideWith(
        (ref) => const Stream<List<Category>>.empty(),
      ),
      // Use the one-shot search() wrapped in a plain stream so the widget test
      // stays deterministic (the reactive drift stream is covered by the
      // document_repository watchSearch test).
      searchResultsProvider.overrideWith((ref) {
        final query = ref.watch(searchQueryProvider);
        final filters = ref.watch(searchFiltersProvider);
        if (query.trim().isEmpty && filters.isEmpty) {
          return Stream.value(const <Document>[]);
        }
        return Stream.fromFuture(
          ref.read(documentRepositoryProvider).search(query, filters: filters),
        );
      }),
    ],
    child: const MaterialApp(
      locale: Locale('de'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('de'), Locale('en')],
      home: SearchPage(),
    ),
  );
}

const _searchField = Key('searchField');

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final cats = CategoryRepository(db);
    final docs = DocumentRepository(db);
    final id = (await cats.findByKey(CategoryKeys.rechnungen))!.id;
    await docs.insertDocument(
      DocumentDraft(
        title: 'Stromrechnung',
        categoryId: id,
        pdfPath: '/tmp/a.pdf',
        pageImagePaths: const ['/tmp/a-0.jpg'],
        ocrText: 'Rechnung der Stadtwerke, Betrag 89,90 EUR',
      ),
    );
  });

  tearDown(() => db.close());

  testWidgets('shows the hint before any query', (tester) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pump();
    expect(find.textContaining('Suche in Titeln'), findsOneWidget);
  });

  Future<void> pumpFrames(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('typing a query shows matching results', (tester) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pump();
    await tester.enterText(find.byKey(_searchField), 'strom');
    await pumpFrames(tester);

    expect(find.byType(DocumentListTile), findsOneWidget);
    expect(find.textContaining('Treffer'), findsOneWidget);
  });

  testWidgets('a non-matching query shows the no-results state', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pump();
    await tester.enterText(find.byKey(_searchField), 'xyznichtvorhanden');
    await pumpFrames(tester);

    expect(find.text('Keine Treffer'), findsOneWidget);
    expect(find.byType(DocumentListTile), findsNothing);
  });
}
