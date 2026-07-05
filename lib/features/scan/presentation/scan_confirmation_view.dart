import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/widgets/group_picker.dart';
import '../../../core/widgets/tag_editor.dart';
import '../domain/classification/scoring.dart';
import '../domain/pipeline/scan_models.dart';

/// Editable confirmation of the extracted metadata before saving. Reused by the
/// camera scan flow and the share/import ingest queue via [onConfirm].
class ScanConfirmationView extends ConsumerStatefulWidget {
  const ScanConfirmationView({
    required this.draft,
    required this.onConfirm,
    this.progressLabel,
    this.onSkip,
    super.key,
  });

  final ConfirmationDraft draft;

  /// Called with the edited draft when the user taps save.
  final void Function(ConfirmationDraft draft) onConfirm;

  /// Optional "2 von 3" label shown in the app bar for multi-item queues.
  final String? progressLabel;

  /// When provided, shows a "skip this document" action (used by the queue).
  final VoidCallback? onSkip;

  @override
  ConsumerState<ScanConfirmationView> createState() =>
      _ScanConfirmationViewState();
}

class _ScanConfirmationViewState extends ConsumerState<ScanConfirmationView> {
  late final TextEditingController _title;
  late final TextEditingController _sender;
  late final TextEditingController _amount;
  late final TextEditingController _tagInput;

  late int _categoryId;
  DateTime? _date;
  late List<String> _tags;
  int? _groupId;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _groupId = d.groupId;
    _title = TextEditingController(text: d.title);
    _sender = TextEditingController(text: d.sender ?? '');
    _amount = TextEditingController(
      text: d.amountCents == null
          ? ''
          : formatAmount(d.amountCents!, currency: d.currency),
    );
    _tagInput = TextEditingController();
    _categoryId = d.categoryId;
    _date = d.documentDate;
    _tags = [...d.tags];
  }

  @override
  void dispose() {
    _title.dispose();
    _sender.dispose();
    _amount.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _addTag() {
    final value = _tagInput.text.trim();
    if (value.isEmpty || _tags.contains(value)) return;
    setState(() {
      _tags.add(value);
      _tagInput.clear();
    });
  }

  void _save() {
    widget.onConfirm(
      widget.draft.copyWith(
        title: _title.text.trim().isEmpty ? 'Dokument' : _title.text.trim(),
        categoryId: _categoryId,
        sender: _sender.text.trim().isEmpty ? null : _sender.text.trim(),
        documentDate: _date,
        amountCents: parseAmountToCents(_amount.text),
        tags: _tags,
        groupId: _groupId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanConfirmTitle),
        actions: [
          if (widget.onSkip != null)
            TextButton(onPressed: widget.onSkip, child: Text(l10n.commonSkip)),
        ],
        bottom: widget.progressLabel == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.progressLabel!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.scanErrorTitle)),
        data: (categories) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _ConfidenceBadge(level: widget.draft.level),
            const SizedBox(height: 12),
            _label(l10n.fieldTitle),
            TextField(controller: _title),
            const SizedBox(height: 16),
            _label(l10n.fieldCategory),
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() {
                if (v != null && v != _categoryId) {
                  _categoryId = v;
                  _groupId = null; // groups are per-category
                }
              }),
            ),
            if (widget.draft.level != ConfidenceLevel.high)
              _AlternativeCategories(
                categories: categories,
                alternativeIds: widget.draft.alternativeCategoryIds,
                selectedId: _categoryId,
                onSelect: (id) => setState(() {
                  _categoryId = id;
                  _groupId = null;
                }),
              ),
            const SizedBox(height: 16),
            _label(l10n.fieldGroup),
            GroupPicker(
              categoryId: _categoryId,
              selectedGroupId: _groupId,
              onChanged: (id) => setState(() => _groupId = id),
            ),
            const SizedBox(height: 16),
            _label('${l10n.fieldSender} (${l10n.fieldOptional})'),
            TextField(controller: _sender),
            const SizedBox(height: 16),
            _label(l10n.fieldDate),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(
                _date == null ? l10n.fieldNoDate : formatDate(_date!),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                alignment: Alignment.centerLeft,
              ),
            ),
            const SizedBox(height: 16),
            _label('${l10n.fieldAmount} (${l10n.fieldOptional})'),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: '0,00 €'),
            ),
            const SizedBox(height: 16),
            _label(l10n.fieldTags),
            TagEditor(
              tags: _tags,
              controller: _tagInput,
              onAdd: _addTag,
              onRemove: (t) => setState(() => _tags.remove(t)),
              hint: l10n.fieldAddTag,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.commonSave),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 4),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}

/// Visual confidence indicator for the classification.
class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.level});
  final ConfidenceLevel level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final (bg, fg, icon, text) = switch (level) {
      ConfidenceLevel.high => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_circle_outline,
        l10n.confidenceHigh,
      ),
      ConfidenceLevel.medium => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.info_outline,
        l10n.confidenceMedium,
      ),
      ConfidenceLevel.low => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.help_outline,
        l10n.confidenceLow,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// One-tap chips offering the next best category guesses.
class _AlternativeCategories extends StatelessWidget {
  const _AlternativeCategories({
    required this.categories,
    required this.alternativeIds,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Category> categories;
  final List<int> alternativeIds;
  final int selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = [
      for (final id in alternativeIds)
        if (id != selectedId) categories.where((c) => c.id == id).firstOrNull,
    ].whereType<Category>().toList();
    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l10n.altCategoriesLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          for (final c in chips)
            ActionChip(label: Text(c.name), onPressed: () => onSelect(c.id)),
        ],
      ),
    );
  }
}
