import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Immutable app-wide settings. Persisted locally; never leaves the device.
/// Default title template. Mirrors `kDefaultTitleTemplate` in the scan domain
/// (kept here too so this core file needn't import a feature module).
const String kDefaultTitleTemplateSetting = '{sender} – {docType} – {date}';

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.appLockEnabled = false,
    this.onboardingCompleted = false,
    this.titleTemplate = kDefaultTitleTemplateSetting,
    this.autoAcceptHighConfidence = false,
    this.reminderEnabled = true,
    this.reminderLeadDays = 3,
    this.reminderOnDueDate = false,
  });

  final ThemeMode themeMode;
  final bool appLockEnabled;
  final bool onboardingCompleted;

  /// Template for auto-generated document titles ({sender}/{docType}/{date}).
  final String titleTemplate;

  /// Save high-confidence documents without showing the confirmation screen.
  final bool autoAcceptHighConfidence;

  /// Whether invoice due-date reminders are scheduled.
  final bool reminderEnabled;

  /// Days before the due date to remind (0 = on the due date only).
  final int reminderLeadDays;

  /// Also remind on the due date itself.
  final bool reminderOnDueDate;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? appLockEnabled,
    bool? onboardingCompleted,
    String? titleTemplate,
    bool? autoAcceptHighConfidence,
    bool? reminderEnabled,
    int? reminderLeadDays,
    bool? reminderOnDueDate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      autoAcceptHighConfidence:
          autoAcceptHighConfidence ?? this.autoAcceptHighConfidence,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
      reminderOnDueDate: reminderOnDueDate ?? this.reminderOnDueDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.appLockEnabled == appLockEnabled &&
      other.onboardingCompleted == onboardingCompleted &&
      other.titleTemplate == titleTemplate &&
      other.autoAcceptHighConfidence == autoAcceptHighConfidence &&
      other.reminderEnabled == reminderEnabled &&
      other.reminderLeadDays == reminderLeadDays &&
      other.reminderOnDueDate == reminderOnDueDate;

  @override
  int get hashCode => Object.hash(
    themeMode,
    appLockEnabled,
    onboardingCompleted,
    titleTemplate,
    autoAcceptHighConfidence,
    reminderEnabled,
    reminderLeadDays,
    reminderOnDueDate,
  );
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
  static const _kTitleTemplate = 'settings.titleTemplate';
  static const _kAutoAccept = 'settings.autoAcceptHighConfidence';
  static const _kReminderEnabled = 'settings.reminderEnabled';
  static const _kReminderLeadDays = 'settings.reminderLeadDays';
  static const _kReminderOnDueDate = 'settings.reminderOnDueDate';

  @override
  Future<AppSettings> load() async {
    final theme = await _storage.read(key: _kTheme);
    final appLock = await _storage.read(key: _kAppLock);
    final onboarding = await _storage.read(key: _kOnboarding);
    final template = await _storage.read(key: _kTitleTemplate);
    final autoAccept = await _storage.read(key: _kAutoAccept);
    final reminderEnabled = await _storage.read(key: _kReminderEnabled);
    final leadDays = await _storage.read(key: _kReminderLeadDays);
    final onDueDate = await _storage.read(key: _kReminderOnDueDate);
    return AppSettings(
      themeMode: _themeFromString(theme),
      appLockEnabled: appLock == 'true',
      onboardingCompleted: onboarding == 'true',
      titleTemplate: (template == null || template.trim().isEmpty)
          ? kDefaultTitleTemplateSetting
          : template,
      autoAcceptHighConfidence: autoAccept == 'true',
      reminderEnabled: reminderEnabled != 'false',
      reminderLeadDays: int.tryParse(leadDays ?? '') ?? 3,
      reminderOnDueDate: onDueDate == 'true',
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
    await _storage.write(key: _kTitleTemplate, value: settings.titleTemplate);
    await _storage.write(
      key: _kAutoAccept,
      value: settings.autoAcceptHighConfidence.toString(),
    );
    await _storage.write(
      key: _kReminderEnabled,
      value: settings.reminderEnabled.toString(),
    );
    await _storage.write(
      key: _kReminderLeadDays,
      value: settings.reminderLeadDays.toString(),
    );
    await _storage.write(
      key: _kReminderOnDueDate,
      value: settings.reminderOnDueDate.toString(),
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
