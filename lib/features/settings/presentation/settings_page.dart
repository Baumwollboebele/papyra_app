import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/settings_store.dart';
import '../../../core/services/share_service.dart';
import 'category_management_page.dart';
import 'privacy_page.dart';

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
