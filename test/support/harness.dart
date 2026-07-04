import 'package:paperless/core/database/app_database.dart';
import 'package:paperless/core/database/repositories/category_repository.dart';
import 'package:paperless/core/providers/database_providers.dart';

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
