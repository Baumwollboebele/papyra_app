import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeletons.dart';
import 'document_list_tile.dart';

/// Sortable, filterable list of documents within a category.
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({required this.categoryId, super.key});

  final int categoryId;

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  DocumentSort _sort = DocumentSort.newestFirst;
  bool _favoritesOnly = false;

  String _sortLabel(BuildContext context, DocumentSort sort) {
    final l10n = context.l10n;
    return switch (sort) {
      DocumentSort.newestFirst => l10n.sortNewest,
      DocumentSort.oldestFirst => l10n.sortOldest,
      DocumentSort.titleAsc => l10n.sortTitle,
      DocumentSort.amountDesc => l10n.sortAmount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoryName = ref
        .watch(categoriesProvider)
        .maybeWhen(
          data: (cats) => cats
              .where((c) => c.id == widget.categoryId)
              .map((c) => c.name)
              .firstOrNull,
          orElse: () => null,
        );
    final docsAsync = ref.watch(
      documentsByCategoryProvider((categoryId: widget.categoryId, sort: _sort)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName ?? l10n.libCategories),
        actions: [
          IconButton(
            tooltip: l10n.filterFavoritesOnly,
            isSelected: _favoritesOnly,
            icon: const Icon(Icons.star_outline),
            selectedIcon: const Icon(Icons.star),
            onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
          ),
          PopupMenuButton<DocumentSort>(
            tooltip: l10n.sortLabel,
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => [
              for (final sort in DocumentSort.values)
                PopupMenuItem(
                  value: sort,
                  child: Text(_sortLabel(context, sort)),
                ),
            ],
          ),
        ],
      ),
      body: docsAsync.when(
        loading: () => const SkeletonList(),
        error: (_, _) => Center(child: Text(l10n.scanErrorTitle)),
        data: (docs) {
          final filtered = _favoritesOnly
              ? docs.where((d) => d.isFavorite).toList()
              : docs;
          if (filtered.isEmpty) {
            return EmptyState(
              icon: Icons.folder_open,
              title: l10n.catEmpty,
              message: l10n.libEmptyBody,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: filtered.length,
            itemBuilder: (context, i) =>
                DocumentListTile(document: filtered[i]),
          );
        },
      ),
    );
  }
}
