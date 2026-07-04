import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Immutable app-wide settings. Persisted locally; never leaves the device.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.appLockEnabled = false,
    this.onboardingCompleted = false,
  });

  final ThemeMode themeMode;
  final bool appLockEnabled;
  final bool onboardingCompleted;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? appLockEnabled,
    bool? onboardingCompleted,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.appLockEnabled == appLockEnabled &&
      other.onboardingCompleted == onboardingCompleted;

  @override
  int get hashCode =>
      Object.hash(themeMode, appLockEnabled, onboardingCompleted);
}

/// Abstraction over settings persistence, so tests can use an in-memory store.
abstract interface class SettingsStore {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

/// Default implementation backed by [FlutterSecureStorage] (fully offline).
class SecureSettingsStore implements SettingsStore {
  SecureSettingsStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kTheme = 'settings.themeMode';
  static const _kAppLock = 'settings.appLockEnabled';
  static const _kOnboarding = 'settings.onboardingCompleted';

  @override
  Future<AppSettings> load() async {
    final theme = await _storage.read(key: _kTheme);
    final appLock = await _storage.read(key: _kAppLock);
    final onboarding = await _storage.read(key: _kOnboarding);
    return AppSettings(
      themeMode: _themeFromString(theme),
      appLockEnabled: appLock == 'true',
      onboardingCompleted: onboarding == 'true',
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _storage.write(key: _kTheme, value: settings.themeMode.name);
    await _storage.write(
      key: _kAppLock,
      value: settings.appLockEnabled.toString(),
    );
    await _storage.write(
      key: _kOnboarding,
      value: settings.onboardingCompleted.toString(),
    );
  }

  static ThemeMode _themeFromString(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

/// In-memory store for tests and previews.
class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([this._settings = const AppSettings()]);
  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async => _settings = settings;
}
