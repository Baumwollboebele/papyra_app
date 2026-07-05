import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/providers/settings_providers.dart';
import 'package:paperless/core/services/app_lock_service.dart';
import 'package:paperless/core/services/settings_store.dart';
import 'package:paperless/main.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, InMemorySettingsStore store) {
    useGermanLocale(tester);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStoreProvider.overrideWithValue(store),
          initialSettingsProvider.overrideWithValue(
            const AppSettings(onboardingCompleted: false),
          ),
          appLockServiceProvider.overrideWithValue(FakeAppLockService()),
          categoriesEmptyOverride,
          recentDocumentsEmptyOverride,
        ],
        child: const PapyraApp(),
      ),
    );
  }

  testWidgets('shows onboarding on first launch and can be completed', (
    tester,
  ) async {
    final store = InMemorySettingsStore();
    await pumpApp(tester, store);
    await tester.pumpAndSettle();

    // First slide.
    expect(find.text('Ordnung für deine Post'), findsOneWidget);

    // Advance through the slides.
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Alles bleibt auf deinem Gerät'), findsOneWidget);

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Schütze deine Dokumente'), findsOneWidget);

    // Finish.
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    // Landed in the shell; onboarding persisted.
    expect(find.text('Scannen'), findsOneWidget);
    expect((await store.load()).onboardingCompleted, isTrue);
  });

  testWidgets('skip completes onboarding immediately', (tester) async {
    final store = InMemorySettingsStore();
    await pumpApp(tester, store);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect((await store.load()).onboardingCompleted, isTrue);
  });
}
