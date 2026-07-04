import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/providers/settings_providers.dart';
import 'package:paperless/core/services/settings_store.dart';
import 'package:paperless/main.dart';

import 'support/harness.dart';

void main() {
  testWidgets('App boots into the shell once onboarding is complete', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStoreProvider.overrideWithValue(InMemorySettingsStore()),
          initialSettingsProvider.overrideWithValue(
            const AppSettings(onboardingCompleted: true),
          ),
          categoriesEmptyOverride,
          recentDocumentsEmptyOverride,
        ],
        child: const PapyraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Scannen'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
