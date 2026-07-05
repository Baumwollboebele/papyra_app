import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/services/settings_store.dart';
import '../../../core/services/share_service.dart';
import 'category_management_page.dart';
import 'privacy_page.dart';

/// Languages the app ships, keyed by locale code and shown in their own name
/// (autonyms). Autonyms are identical in every UI locale, so they are not part
/// of the translated string table. Keep in sync with `supportedLocales`.
const Map<String, String> kSupportedLanguages = {
  'de': 'Deutsch',
  'en': 'English',
  'fr': 'Français',
  'it': 'Italiano',
  'tr': 'Türkçe',
};

/// Result of the language picker; wraps a nullable code so "system default"
/// (null) is distinguishable from "dialog dismissed".
class _LanguageChoice {
  const _LanguageChoice(this.code);
  final String? code;
}

/// App settings: security, appearance, data (categories, backup) and about.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _busy = false;

  Future<void> _toggleAppLock(bool enabled) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(settingsControllerProvider.notifier);
    if (!enabled) {
      await controller.setAppLockEnabled(false);
      return;
    }
    final service = ref.read(appLockServiceProvider);
    if (!await service.isAvailable()) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.setAppLockUnavailable)),
      );
      return;
    }
    if (await service.authenticate(l10n.lockReason)) {
      await controller.setAppLockEnabled(true);
    }
  }

  Future<void> _createBackup() async {
    if (_busy) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final path = await ref.read(backupServiceProvider).createBackup();
      await ref
          .read(shareServiceProvider)
          .shareFile(path, subject: 'Papyra Backup');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    if (_busy) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(l10n.restoreConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonYes),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    const typeGroup = XTypeGroup(label: 'ZIP', extensions: ['zip']);
    final file = await openFile(acceptedTypeGroups: const [typeGroup]);
    if (file == null) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(backupServiceProvider)
          .restoreBackup(
            file.path,
            closeActiveDatabase: () async => ref.read(databaseProvider).close(),
          );
      // Reopen the database and refresh all data.
      ref.invalidate(databaseProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.restoreDone)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.restoreError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _toggleReminders(bool enabled) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(settingsControllerProvider.notifier);
    if (enabled) {
      final granted = await ref
          .read(reminderServiceProvider)
          .requestPermission();
      await controller.setReminderEnabled(true);
      if (!granted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.reminderPermissionDenied)),
        );
      }
    } else {
      await controller.setReminderEnabled(false);
    }
  }

  Future<void> _pickReminderLead() async {
    final l10n = context.l10n;
    final current = ref.read(settingsControllerProvider).reminderLeadDays;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.setReminders),
        children: [
          for (final days in const [0, 1, 2, 3, 5, 7, 14])
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(days),
              child: Row(
                children: [
                  Icon(
                    days == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.setReminderLead(days)),
                ],
              ),
            ),
        ],
      ),
    );
    if (result != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setReminderLeadDays(result);
    }
  }

  Future<void> _pickLanguage() async {
    final l10n = context.l10n;
    final current = ref.read(settingsControllerProvider).localeOverride;
    // Options: system default, then each shipped language in its own name.
    final entries = <MapEntry<String?, String>>[
      MapEntry(null, l10n.languageSystem),
      ...kSupportedLanguages.entries.map((e) => MapEntry(e.key, e.value)),
    ];
    final result = await showDialog<_LanguageChoice>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.setLanguage),
        children: [
          for (final entry in entries)
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(_LanguageChoice(entry.key)),
              child: Row(
                children: [
                  Icon(
                    entry.key == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(entry.value),
                ],
              ),
            ),
        ],
      ),
    );
    if (result != null) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setLocaleOverride(result.code);
    }
  }

  Future<void> _editTitleTemplate() async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: ref.read(settingsControllerProvider).titleTemplate,
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setTitleTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(hintText: l10n.setTitleTemplateHint),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => controller.text = kDefaultTitleTemplateSetting,
              child: Text(l10n.setTitleTemplateReset),
            ),
          ],
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
    if (result != null && result.trim().isNotEmpty) {
      await ref
          .read(settingsControllerProvider.notifier)
          .setTitleTemplate(result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _SectionHeader(l10n.setSecurity),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: Text(l10n.setAppLock),
                subtitle: Text(l10n.setAppLockSubtitle),
                value: settings.appLockEnabled,
                onChanged: _toggleAppLock,
              ),
              const Divider(height: 1),
              _SectionHeader(l10n.setAppearance),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(s.first),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.setLanguage),
                subtitle: Text(
                  kSupportedLanguages[settings.localeOverride] ??
                      l10n.languageSystem,
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _pickLanguage,
              ),
              const Divider(height: 1),
              _SectionHeader(l10n.setFiling),
              ListTile(
                leading: const Icon(Icons.title),
                title: Text(l10n.setTitleTemplate),
                subtitle: Text(settings.titleTemplate),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _editTitleTemplate,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.bolt_outlined),
                title: Text(l10n.setAutoAccept),
                subtitle: Text(l10n.setAutoAcceptSubtitle),
                value: settings.autoAcceptHighConfidence,
                onChanged: (v) => ref
                    .read(settingsControllerProvider.notifier)
                    .setAutoAcceptHighConfidence(v),
              ),
              const Divider(height: 1),
              _SectionHeader(l10n.setReminders),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(l10n.setReminderEnabled),
                subtitle: Text(l10n.setReminderEnabledSubtitle),
                value: settings.reminderEnabled,
                onChanged: _toggleReminders,
              ),
              if (settings.reminderEnabled) ...[
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(l10n.setReminderLead(settings.reminderLeadDays)),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _pickReminderLead,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.event_available_outlined),
                  title: Text(l10n.setReminderOnDue),
                  value: settings.reminderOnDueDate,
                  onChanged: (v) => ref
                      .read(settingsControllerProvider.notifier)
                      .setReminderOnDueDate(v),
                ),
              ],
              const Divider(height: 1),
              _SectionHeader(l10n.setData),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(l10n.setCategories),
                subtitle: Text(l10n.setCategoriesSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(const CategoryManagementPage()),
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: Text(l10n.setBackup),
                subtitle: Text(l10n.setBackupSubtitle),
                onTap: _createBackup,
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l10n.setRestore),
                subtitle: Text(l10n.setRestoreSubtitle),
                onTap: _restoreBackup,
              ),
              const Divider(height: 1),
              _SectionHeader(l10n.setAbout),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.setAbout),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(const PrivacyPage()),
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
