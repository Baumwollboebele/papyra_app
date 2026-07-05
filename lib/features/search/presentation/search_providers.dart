import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/repositories/document_repository.dart';
import '../../../core/providers/database_providers.dart';

/// Current free-text query.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

/// Current filters (category, date range, favorites).
final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, SearchFilters>(
      SearchFiltersNotifier.new,
    );

class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();
  void set(SearchFilters filters) => state = filters;
  void clear() => state = const SearchFilters();
}

/// FTS results for the current query + filters, reactive: updates live as
/// documents are added/edited/removed. Empty when there is nothing to search
/// for (no query and no active filter).
final searchResultsProvider = StreamProvider<List<Document>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final filters = ref.watch(searchFiltersProvider);
  if (query.trim().isEmpty && filters.isEmpty) {
    return Stream.value(const []);
  }
  return ref
      .watch(documentRepositoryProvider)
      .watchSearch(query, filters: filters);
});

/// In-session recent searches (most recent first, capped).
final recentSearchesProvider = NotifierProvider<RecentSearches, List<String>>(
  RecentSearches.new,
);

class RecentSearches extends Notifier<List<String>> {
  static const _max = 8;

  @override
  List<String> build() => const [];

  void record(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final next = [q, ...state.where((e) => e.toLowerCase() != q.toLowerCase())];
    state = next.take(_max).toList();
  }

  void clear() => state = const [];
}
