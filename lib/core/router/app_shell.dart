import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n_extension.dart';

/// Bottom-navigation shell hosting Library, Search and Settings, with a
/// prominent central "Scannen" action.
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'scan-fab',
        onPressed: () => _startScan(context),
        elevation: 2,
        icon: const Icon(Icons.document_scanner_outlined),
        label: Text(l10n.scanButton),
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
    // Wired to the scan flow in the scan feature task.
    context.push('/scan');
  }
}
