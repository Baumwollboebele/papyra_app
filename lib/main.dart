import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/formatting/formatters.dart';
import 'core/providers/settings_providers.dart';
import 'core/router/app_router.dart';
import 'core/services/settings_store.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_lock_gate.dart';
import 'features/scan/presentation/share_intent_listener.dart';
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
      child: const PapyraApp(),
    ),
  );
}

class PapyraApp extends ConsumerWidget {
  const PapyraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(
      settingsControllerProvider.select((s) => s.themeMode),
    );
    final localeOverride = ref.watch(
      settingsControllerProvider.select((s) => s.localeOverride),
    );
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Null = follow the device language; a value pins the UI to the language
      // the user picked in Settings.
      locale: localeOverride == null ? null : Locale(localeOverride),
      // Follow the device language when it is one we ship (de, en, fr, it, tr);
      // otherwise fall back to English rather than the first listed locale.
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale != null) {
          for (final locale in supported) {
            if (locale.languageCode == deviceLocale.languageCode) return locale;
          }
        }
        return const Locale('en');
      },
      routerConfig: router,
      builder: (context, child) => ShareIntentListener(
        child: AppLockGate(child: child ?? const SizedBox()),
      ),
    );
  }
}
