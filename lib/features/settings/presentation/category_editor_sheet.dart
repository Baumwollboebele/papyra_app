import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/default_categories.dart';
import '../../../core/l10n/l10n_extension.dart';

/// Result of the category editor.
class CategoryEditResult {
  const CategoryEditResult({
    required this.name,
    required this.iconName,
    required this.colorValue,
  });
  final String name;
  final String iconName;
  final int colorValue;
}

/// Bottom sheet to create or edit a category (name, icon, color).
Future<CategoryEditResult?> showCategoryEditor(
  BuildContext context, {
  Category? existing,
}) {
  return showModalBottomSheet<CategoryEditResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _CategoryEditor(existing: existing),
    ),
  );
}

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({this.existing});
  final Category? existing;

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  late final TextEditingController _name;
  late String _iconName;
  late int _colorValue;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _iconName = widget.existing?.iconName ?? kSelectableIconNames.first;
    _colorValue =
        widget.existing?.colorValue ?? kSelectableColors.first.toARGB32();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      CategoryEditResult(
        name: name,
        iconName: _iconName,
        colorValue: _colorValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = Color(_colorValue);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null ? l10n.catNewTitle : l10n.catEditTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.catName),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          Text(l10n.catIcon, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final icon in kSelectableIconNames)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _iconName = icon),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _iconName == icon
                          ? color.withValues(alpha: 0.18)
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _iconName == icon ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(categoryIcon(icon), color: color),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.catColor, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final c in kSelectableColors)
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => _colorValue = c.toARGB32()),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _colorValue == c.toARGB32()
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _colorValue == c.toARGB32()
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
