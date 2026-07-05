import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/services/settings_store.dart';

void main() {
  group('AppSettings.copyWith localeOverride', () {
    test('defaults to following the system language (null)', () {
      expect(const AppSettings().localeOverride, isNull);
    });

    test('leaves localeOverride untouched when not passed', () {
      const settings = AppSettings(localeOverride: 'fr');
      // Changing an unrelated field must preserve the chosen language.
      expect(settings.copyWith(appLockEnabled: true).localeOverride, 'fr');
    });

    test('sets a new language code', () {
      expect(
        const AppSettings().copyWith(localeOverride: 'tr').localeOverride,
        'tr',
      );
    });

    test('clears back to the system language when passed null', () {
      const settings = AppSettings(localeOverride: 'it');
      expect(settings.copyWith(localeOverride: null).localeOverride, isNull);
    });
  });

  test('InMemorySettingsStore round-trips localeOverride', () async {
    final store = InMemorySettingsStore();
    await store.save(const AppSettings(localeOverride: 'en'));
    expect((await store.load()).localeOverride, 'en');
  });
}
