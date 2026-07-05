import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeletons.dart';
import '../domain/ics_builder.dart';

/// "Fällig" — invoices with upcoming or overdue payment deadlines.
class DuePage extends ConsumerWidget {
  const DuePage({super.key});

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _togglePaid(WidgetRef ref, Document doc) async {
    final nowPaid = !doc.isPaid;
    await ref.read(documentRepositoryProvider).setPaid(doc.id, nowPaid);
    await applyReminder(
      service: ref.read(reminderServiceProvider),
      settings: ref.read(settingsControllerProvider),
      documentId: doc.id,
      title: doc.title,
      dueDate: doc.dueDate,
      isPaid: nowPaid,
    );
  }

  Future<void> _exportCalendar(
    BuildContext context,
    WidgetRef ref,
    Document doc,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ics = buildDueDateIcs(
        documentId: doc.id,
        title: doc.title,
        dueDate: doc.dueDate!,
      );
      final tmp = await getTemporaryDirectory();
      final file = File(p.join(tmp.path, 'papyra-faellig-${doc.id}.ics'));
      await file.writeAsString(ics);
      await ref
          .read(shareServiceProvider)
          .shareFile(file.path, subject: l10n.calendarSummary(doc.title));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.calendarError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dueAsync = ref.watch(dueDocumentsProvider);
    final today = _dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDue)),
      body: dueAsync.when(
        loading: () => const SkeletonList(),
        error: (_, _) => Center(child: Text(l10n.scanErrorTitle)),
        data: (docs) {
          final overdue = docs
              .where((d) => !d.isPaid && _dateOnly(d.dueDate!).isBefore(today))
              .toList();
          final upcoming = docs
              .where((d) => !d.isPaid && !_dateOnly(d.dueDate!).isBefore(today))
              .toList();
          final paid = docs.where((d) => d.isPaid).toList();

          if (overdue.isEmpty && upcoming.isEmpty && paid.isEmpty) {
            return EmptyState(
              icon: Icons.event_available,
              title: l10n.dueEmpty,
              message: l10n.setReminderEnabledSubtitle,
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              if (overdue.isNotEmpty)
                _Section(title: l10n.dueOverdue, color: Colors.red),
              for (final d in overdue)
                _DueTile(
                  doc: d,
                  today: today,
                  onTogglePaid: () => _togglePaid(ref, d),
                  onExport: () => _exportCalendar(context, ref, d),
                ),
              if (upcoming.isNotEmpty) _Section(title: l10n.dueUpcoming),
              for (final d in upcoming)
                _DueTile(
                  doc: d,
                  today: today,
                  onTogglePaid: () => _togglePaid(ref, d),
                  onExport: () => _exportCalendar(context, ref, d),
                ),
              if (paid.isNotEmpty) _Section(title: l10n.duePaidSection),
              for (final d in paid)
                _DueTile(
                  doc: d,
                  today: today,
                  onTogglePaid: () => _togglePaid(ref, d),
                  onExport: () => _exportCalendar(context, ref, d),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.color});
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: color ?? Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DueTile extends StatelessWidget {
  const _DueTile({
    required this.doc,
    required this.today,
    required this.onTogglePaid,
    required this.onExport,
  });

  final Document doc;
  final DateTime today;
  final VoidCallback onTogglePaid;
  final VoidCallback onExport;

  String _relative(BuildContext context) {
    final l10n = context.l10n;
    final due = DateTime(
      doc.dueDate!.year,
      doc.dueDate!.month,
      doc.dueDate!.day,
    );
    final diff = due.difference(today).inDays;
    if (diff == 0) return l10n.dueToday;
    if (diff > 0) return l10n.dueInDays(diff);
    return l10n.dueDaysAgo(-diff);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final overdue =
        !doc.isPaid &&
        DateTime(
          doc.dueDate!.year,
          doc.dueDate!.month,
          doc.dueDate!.day,
        ).isBefore(today);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => context.push(AppRoutes.document(doc.id)),
        title: Text(
          doc.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: doc.isPaid ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.event,
                size: 14,
                color: overdue
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${formatDate(doc.dueDate!)} · ${_relative(context)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: overdue ? theme.colorScheme.error : null,
                  fontWeight: overdue ? FontWeight.w600 : null,
                ),
              ),
              if (doc.amountCents != null) ...[
                const Spacer(),
                Text(
                  formatAmount(doc.amountCents!, currency: doc.currency),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) => v == 'paid' ? onTogglePaid() : onExport(),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'paid',
              child: Text(doc.isPaid ? l10n.dueMarkUnpaid : l10n.dueMarkPaid),
            ),
            PopupMenuItem(value: 'calendar', child: Text(l10n.calendarExport)),
          ],
        ),
      ),
    );
  }
}
