import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n_extension.dart';
import '../providers/database_providers.dart';

/// Lets the user file a document into a sub-group of [categoryId]: pick "None",
/// an existing group, or create a new one inline. Creating a group persists it
/// immediately and selects it.
class GroupPicker extends ConsumerWidget {
  const GroupPicker({
    required this.categoryId,
    required this.selectedGroupId,
    required this.onChanged,
    super.key,
  });

  final int categoryId;
  final int? selectedGroupId;
  final ValueChanged<int?> onChanged;

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final name = await promptGroupName(context);
    if (name == null || name.trim().isEmpty) return;
    final id = await ref
        .read(groupRepositoryProvider)
        .getOrCreate(categoryId, name.trim());
    onChanged(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groupsAsync = ref.watch(groupsWithCountsProvider(categoryId));

    return groupsAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (groups) => Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ChoiceChip(
            label: Text(l10n.groupNone),
            selected: selectedGroupId == null,
            onSelected: (_) => onChanged(null),
          ),
          for (final g in groups)
            ChoiceChip(
              label: Text(g.group.name),
              selected: selectedGroupId == g.group.id,
              onSelected: (_) => onChanged(g.group.id),
            ),
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: Text(l10n.groupNew),
            onPressed: () => _createGroup(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Small dialog prompting for a group name.
Future<String?> promptGroupName(BuildContext context, {String? initial}) {
  final controller = TextEditingController(text: initial ?? '');
  final l10n = context.l10n;
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.groupCreateTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: l10n.groupNameHint),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(l10n.commonSave),
        ),
      ],
    ),
  );
}
