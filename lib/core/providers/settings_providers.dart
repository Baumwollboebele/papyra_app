import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_store.dart';

/// The persistence backend. Overridden in main() with a [SecureSettingsStore]
/// and in tests with an [InMemorySettingsStore].
final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => throw UnimplementedError('settingsStoreProvider must be overridden'),
);

/// The settings loaded at startup, injected via override so the controller has
/// a synchronous initial value (no loading flash on first frame).
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings(),
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

/// Holds current settings and writes changes through to the store.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> _persist(AppSettings next) async {
    state = next;
    await ref.read(settingsStoreProvider).save(next);
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  Future<void> setAppLockEnabled(bool enabled) =>
      _persist(state.copyWith(appLockEnabled: enabled));

  Future<void> completeOnboarding() =>
      _persist(state.copyWith(onboardingCompleted: true));

  Future<void> setTitleTemplate(String template) =>
      _persist(state.copyWith(titleTemplate: template));

  Future<void> setAutoAcceptHighConfidence(bool value) =>
      _persist(state.copyWith(autoAcceptHighConfidence: value));

  Future<void> setReminderEnabled(bool value) =>
      _persist(state.copyWith(reminderEnabled: value));

  Future<void> setReminderLeadDays(int days) =>
      _persist(state.copyWith(reminderLeadDays: days));

  Future<void> setReminderOnDueDate(bool value) =>
      _persist(state.copyWith(reminderOnDueDate: value));

  /// Sets the UI language ('de', 'en', 'fr', 'it', 'tr'), or null to follow
  /// the device language.
  Future<void> setLocaleOverride(String? code) =>
      _persist(state.copyWith(localeOverride: code));
}
