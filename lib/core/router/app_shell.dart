import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../features/scan/domain/pipeline/ingest_models.dart';
import '../../features/scan/presentation/ingest_flow_page.dart';
import '../l10n/l10n_extension.dart';
import 'app_routes.dart';

/// Bottom-navigation shell hosting Library, Due, Search and Settings, with a
/// prominent "Scannen" action and an "Importieren" action beside it.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'import-fab',
            tooltip: l10n.importAction,
            elevation: 2,
            onPressed: () => _startImport(context),
            child: const Icon(Icons.file_open_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'scan-fab',
            onPressed: () => _startScan(context),
            elevation: 2,
            icon: const Icon(Icons.document_scanner_outlined),
            label: Text(l10n.scanButton),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: l10n.navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: l10n.navDue,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }

  void _startScan(BuildContext context) {
    context.push(AppRoutes.scan);
  }

  /// Picks existing PDFs/images from device storage and routes them through the
  /// same ingest queue as the scanner and the share sheet.
  Future<void> _startImport(BuildContext context) async {
    const typeGroup = XTypeGroup(
      label: 'PDF & Bilder',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final files = await openFiles(acceptedTypeGroups: const [typeGroup]);
    if (files.isEmpty || !context.mounted) return;
    final ingestFiles = [
      for (final f in files)
        IngestFile(
          path: f.path,
          mimeType: f.mimeType,
          name: f.name.isNotEmpty ? f.name : p.basename(f.path),
        ),
    ];
    if (!context.mounted) return;
    context.push(
      AppRoutes.ingest,
      extra: IngestRequest(files: ingestFiles, source: IngestSource.importFile),
    );
  }
}
