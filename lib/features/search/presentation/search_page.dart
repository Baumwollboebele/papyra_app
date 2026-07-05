import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/repositories/document_repository.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../library/presentation/document_list_tile.dart';
import 'search_providers.dart';

/// Global full-text search with filters, highlighting and recent searches.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    ref.read(searchQueryProvider.notifier).set(value);
    ref.read(recentSearchesProvider.notifier).record(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(searchQueryProvider);
    final filters = ref.watch(searchFiltersProvider);
    final hasCriteria = query.trim().isNotEmpty || !filters.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('searchField'),
          controller: _controller,
          autofocus: false,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            suffixIcon: query.isEmpty
                ? const Icon(Icons.search)
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).set('');
                    },
                  ),
          ),
          onChanged: (value) =>
              ref.read(searchQueryProvider.notifier).set(value),
          onSubmitted: _submit,
        ),
      ),
      body: Column(
        children: [
          const _FilterBar(),
          Expanded(
            child: hasCriteria
                ? const _Results()
                : _RecentAndHint(
                    onPick: (q) {
                      _controller.text = q;
                      _submit(q);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filters = ref.watch(searchFiltersProvider);
    final categories = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          categories.maybeWhen(
            data: (cats) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownMenu<int?>(
                initialSelection: filters.categoryId,
                hintText: l10n.filterAllCategories,
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: null,
                    label: l10n.filterAllCategories,
                  ),
                  for (final c in cats)
                    DropdownMenuEntry(value: c.id, label: c.name),
                ],
                onSelected: (value) {
                  // "Alle Kategorien" (null) browses every document instead of
                  // clearing the search; a specific category filters to it.
                  ref
                      .read(searchFiltersProvider.notifier)
                      .set(
                        _copyFilters(
                          filters,
                          categoryId: value,
                          clearCategory: value == null,
                          showAll: value == null,
                        ),
                      );
                },
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          FilterChip(
            label: Text(l10n.filterFavoritesOnly),
            selected: filters.favoritesOnly,
            onSelected: (selected) {
              ref
                  .read(searchFiltersProvider.notifier)
                  .set(_copyFilters(filters, favoritesOnly: selected));
            },
          ),
          const SizedBox(width: 8),
          _DateRangeChip(filters: filters),
          if (!filters.isEmpty) ...[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.filter_alt_off, size: 18),
              label: Text(l10n.filterClear),
              onPressed: () => ref.read(searchFiltersProvider.notifier).clear(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateRangeChip extends ConsumerWidget {
  const _DateRangeChip({required this.filters});
  final SearchFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasRange = filters.dateFrom != null || filters.dateTo != null;
    final label = hasRange
        ? '${filters.dateFrom != null ? formatDate(filters.dateFrom!) : '…'} – '
              '${filters.dateTo != null ? formatDate(filters.dateTo!) : '…'}'
        : l10n.filterDateRange;
    return FilterChip(
      avatar: const Icon(Icons.event_outlined, size: 18),
      label: Text(label),
      selected: hasRange,
      onSelected: (_) async {
        final now = DateTime.now();
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(1990),
          lastDate: DateTime(now.year + 1),
        );
        if (range != null) {
          ref
              .read(searchFiltersProvider.notifier)
              .set(
                _copyFilters(filters, dateFrom: range.start, dateTo: range.end),
              );
        }
      },
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.scanErrorTitle)),
      data: (docs) {
        if (docs.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: l10n.searchNoResults,
            message: l10n.searchStart,
          );
        }
        final terms = query.trim().split(RegExp(r'\s+'));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                l10n.searchResultsCount(docs.length),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: docs.length,
                itemBuilder: (context, i) =>
                    DocumentListTile(document: docs[i], highlightTerms: terms),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecentAndHint extends ConsumerWidget {
  const _RecentAndHint({required this.onPick});
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recent = ref.watch(recentSearchesProvider);

    if (recent.isEmpty) {
      return EmptyState(
        icon: Icons.search,
        title: l10n.searchHint,
        message: l10n.searchStart,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.searchRecent,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () =>
                  ref.read(recentSearchesProvider.notifier).clear(),
              child: Text(l10n.filterClear),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final q in recent)
              ActionChip(
                avatar: const Icon(Icons.history, size: 18),
                label: Text(q),
                onPressed: () => onPick(q),
              ),
          ],
        ),
      ],
    );
  }
}

SearchFilters _copyFilters(
  SearchFilters f, {
  int? categoryId,
  bool clearCategory = false,
  bool? favoritesOnly,
  DateTime? dateFrom,
  DateTime? dateTo,
  bool? showAll,
}) {
  return SearchFilters(
    categoryId: clearCategory ? null : (categoryId ?? f.categoryId),
    favoritesOnly: favoritesOnly ?? f.favoritesOnly,
    dateFrom: dateFrom ?? f.dateFrom,
    dateTo: dateTo ?? f.dateTo,
    showAll: showAll ?? f.showAll,
  );
}
