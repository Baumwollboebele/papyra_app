import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';
import 'package:paperless/core/providers/database_providers.dart';

/// Pins the widget-test locale to German so tests that boot the full app assert
/// against the German UI regardless of the host machine's system locale. Call
/// before `pumpWidget`. Automatically reset at the end of the test.
void useGermanLocale(WidgetTester tester) {
  // MaterialApp resolves against the `locales` list, so set both the single
  // and the list test values to be safe.
  tester.platformDispatcher.localeTestValue = const Locale('de');
  tester.platformDispatcher.localesTestValue = const <Locale>[Locale('de')];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}

/// Overrides for the library home's drift *stream* providers with plain streams
/// that emit empty data, so booting the app in a widget test neither touches
/// path_provider nor leaves drift's stream-close timer pending at teardown.
///
/// Exposed as inferred-typed finals (the `Override` type is not part of the
/// public API surface), spread into a test's `overrides:` list.
final categoriesEmptyOverride = categoriesWithCountsProvider.overrideWith(
  (ref) => Stream.value(const <CategoryWithCount>[]),
);

final recentDocumentsEmptyOverride = recentDocumentsProvider.overrideWith(
  (ref) => Stream.value(const <Document>[]),
);
