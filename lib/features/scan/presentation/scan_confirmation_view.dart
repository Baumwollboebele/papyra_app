import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/widgets/tag_editor.dart';
import '../domain/pipeline/scan_models.dart';
import 'scan_controller.dart';

/// Editable confirmation of the extracted metadata before saving.
class ScanConfirmationView extends ConsumerStatefulWidget {
  const ScanConfirmationView({required this.draft, super.key});

  final ConfirmationDraft draft;

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

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
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
    final controller = ref.read(scanControllerProvider.notifier);
    controller.updateDraft(
      widget.draft.copyWith(
        title: _title.text.trim().isEmpty ? 'Dokument' : _title.text.trim(),
        categoryId: _categoryId,
        sender: _sender.text.trim().isEmpty ? null : _sender.text.trim(),
        documentDate: _date,
        amountCents: parseAmountToCents(_amount.text),
        tags: _tags,
      ),
    );
    controller.save();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanConfirmTitle)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.scanErrorTitle)),
        data: (categories) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            if (widget.draft.lowConfidence)
              _LowConfidenceBanner(
                suggestion: _categoryNameFor(
                  categories,
                  widget.draft.suggestedCategoryId,
                ),
              ),
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
              onChanged: (v) => setState(() => _categoryId = v ?? _categoryId),
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

  String _categoryNameFor(List<Category> categories, int id) {
    return categories
        .firstWhere((c) => c.id == id, orElse: () => categories.first)
        .name;
  }
}

class _LowConfidenceBanner extends StatelessWidget {
  const _LowConfidenceBanner({required this.suggestion});
  final String suggestion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.scanLowConfidence,
                  style: TextStyle(
                    color: scheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.scanSuggested(suggestion),
                  style: TextStyle(color: scheme.onTertiaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
