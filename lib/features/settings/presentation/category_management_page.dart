import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/default_categories.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/widgets/skeletons.dart';
import 'category_editor_sheet.dart';

/// Add, rename, recolor, reorder and delete categories.
class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(categoriesProvider);
    final repo = ref.read(categoryRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catManageTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showCategoryEditor(context);
          if (result != null) {
            await repo.addCustom(
              name: result.name,
              iconName: result.iconName,
              colorValue: result.colorValue,
            );
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.catAdd),
      ),
      body: categoriesAsync.when(
        loading: () => const SkeletonList(),
        error: (_, _) => Center(child: Text(l10n.scanErrorTitle)),
        data: (categories) => ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          itemCount: categories.length,
          onReorderItem: (oldIndex, newIndex) {
            final ids = categories.map((c) => c.id).toList();
            final moved = ids.removeAt(oldIndex);
            ids.insert(newIndex, moved);
            repo.reorder(ids);
          },
          header: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.catReorderHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryRow(
              key: ValueKey(category.id),
              category: category,
              onEdit: () => _edit(context, ref, category),
              onDelete: () => _delete(context, ref, category),
            );
          },
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final repo = ref.read(categoryRepositoryProvider);
    final result = await showCategoryEditor(context, existing: category);
    if (result == null) return;
    await repo.rename(category.id, result.name);
    await repo.updateAppearance(
      category.id,
      iconName: result.iconName,
      colorValue: result.colorValue,
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final deleted = await ref
        .read(categoryRepositoryProvider)
        .delete(category.id);
    if (!deleted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.catCannotDelete)));
    }
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          child: Icon(categoryIcon(category.iconName)),
        ),
        title: Text(category.name),
        onTap: onEdit,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!category.isDefault)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
