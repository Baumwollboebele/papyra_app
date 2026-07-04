import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/group_picker.dart';
import '../../../core/widgets/skeletons.dart';
import 'document_list_tile.dart';

/// Sortable, filterable list of documents within a category, with sub-groups.
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({required this.categoryId, super.key});

  final int categoryId;

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  DocumentSort _sort = DocumentSort.newestFirst;
  bool _favoritesOnly = false;

  // Group filter: null groupId + !ungrouped = all; ungrouped = only ungrouped;
  // otherwise the selected group id.
  int? _groupId;
  bool _ungrouped = false;

  String _sortLabel(BuildContext context, DocumentSort sort) {
    final l10n = context.l10n;
    return switch (sort) {
      DocumentSort.newestFirst => l10n.sortNewest,
      DocumentSort.oldestFirst => l10n.sortOldest,
      DocumentSort.titleAsc => l10n.sortTitle,
      DocumentSort.amountDesc => l10n.sortAmount,
    };
  }

  Future<void> _addGroup() async {
    final name = await promptGroupName(context);
    if (name == null || name.trim().isEmpty) return;
    await ref
        .read(groupRepositoryProvider)
        .getOrCreate(widget.categoryId, name.trim());
  }

  Future<void> _deleteGroup(int id) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.groupDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(groupRepositoryProvider).delete(id);
      if (_groupId == id) setState(() => _groupId = null);
    }
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
      documentsByCategoryProvider((
        categoryId: widget.categoryId,
        sort: _sort,
        groupId: _groupId,
        ungroupedOnly: _ungrouped,
      )),
    );
    final groupNames = ref
        .watch(groupsWithCountsProvider(widget.categoryId))
        .maybeWhen(
          data: (gs) => {for (final g in gs) g.group.id: g.group.name},
          orElse: () => <int, String>{},
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
      body: Column(
        children: [
          _GroupFilterBar(
            categoryId: widget.categoryId,
            selectedGroupId: _groupId,
            ungrouped: _ungrouped,
            onSelectAll: () => setState(() {
              _groupId = null;
              _ungrouped = false;
            }),
            onSelectUngrouped: () => setState(() {
              _groupId = null;
              _ungrouped = true;
            }),
            onSelectGroup: (id) => setState(() {
              _groupId = id;
              _ungrouped = false;
            }),
            onAddGroup: _addGroup,
            onDeleteGroup: _deleteGroup,
          ),
          Expanded(
            child: docsAsync.when(
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => DocumentListTile(
                    document: filtered[i],
                    groupName: filtered[i].groupId == null
                        ? null
                        : groupNames[filtered[i].groupId],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupFilterBar extends ConsumerWidget {
  const _GroupFilterBar({
    required this.categoryId,
    required this.selectedGroupId,
    required this.ungrouped,
    required this.onSelectAll,
    required this.onSelectUngrouped,
    required this.onSelectGroup,
    required this.onAddGroup,
    required this.onDeleteGroup,
  });

  final int categoryId;
  final int? selectedGroupId;
  final bool ungrouped;
  final VoidCallback onSelectAll;
  final VoidCallback onSelectUngrouped;
  final ValueChanged<int> onSelectGroup;
  final VoidCallback onAddGroup;
  final ValueChanged<int> onDeleteGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groupsAsync = ref.watch(groupsWithCountsProvider(categoryId));
    final ungroupedCount = ref
        .watch(ungroupedCountProvider(categoryId))
        .maybeWhen(data: (c) => c, orElse: () => 0);

    final groups = groupsAsync.maybeWhen(
      data: (g) => g,
      orElse: () => const [],
    );
    // Only show the bar once there is something to group by.
    if (groups.isEmpty && ungroupedCount == 0) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextButton.icon(
            onPressed: onAddGroup,
            icon: const Icon(Icons.create_new_folder_outlined, size: 20),
            label: Text(l10n.groupAdd),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(l10n.groupAll),
            selected: selectedGroupId == null && !ungrouped,
            onSelected: (_) => onSelectAll(),
          ),
          const SizedBox(width: 8),
          for (final g in groups) ...[
            GestureDetector(
              onLongPress: () => onDeleteGroup(g.group.id),
              child: ChoiceChip(
                label: Text('${g.group.name} · ${g.documentCount}'),
                selected: selectedGroupId == g.group.id,
                onSelected: (_) => onSelectGroup(g.group.id),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (ungroupedCount > 0) ...[
            ChoiceChip(
              label: Text('${l10n.groupUngrouped} · $ungroupedCount'),
              selected: ungrouped,
              onSelected: (_) => onSelectUngrouped(),
            ),
            const SizedBox(width: 8),
          ],
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: Text(l10n.groupAdd),
            onPressed: onAddGroup,
          ),
        ],
      ),
    );
  }
}
