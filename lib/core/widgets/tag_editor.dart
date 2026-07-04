import 'package:flutter/material.dart';

/// Editable list of tags: chips with delete + an add field.
class TagEditor extends StatelessWidget {
  const TagEditor({
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    required this.hint,
    super.key,
  });

  final List<String> tags;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final tag in tags)
                InputChip(label: Text(tag), onDeleted: () => onRemove(tag)),
            ],
          ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
            ),
          ),
          onSubmitted: (_) => onAdd(),
        ),
      ],
    );
  }
}
