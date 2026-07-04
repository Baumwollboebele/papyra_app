import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/formatting/formatters.dart';
import 'core/providers/settings_providers.dart';
import 'core/router/app_router.dart';
import 'core/services/settings_store.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_lock_gate.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(kFormatLocale);

  // Load persisted settings before the first frame so theme and the onboarding
  // redirect are correct immediately. Everything here is local; no network.
  final store = SecureSettingsStore();
  final initialSettings = await store.load();

  runApp(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(store),
        initialSettingsProvider.overrideWithValue(initialSettings),
      ],
      child: const PaperVaultApp(),
    ),
  );
}

class PaperVaultApp extends ConsumerWidget {
  const PaperVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(
      settingsControllerProvider.select((s) => s.themeMode),
    );
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      routerConfig: router,
      builder: (context, child) =>
          AppLockGate(child: child ?? const SizedBox()),
    );
  }
}
