// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'PaperVault';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonDone => 'Fertig';

  @override
  String get commonNext => 'Weiter';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonSkip => 'Überspringen';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonShare => 'Teilen';

  @override
  String get commonSearch => 'Suchen';

  @override
  String get commonSettings => 'Einstellungen';

  @override
  String get commonYes => 'Ja';

  @override
  String get commonNo => 'Nein';

  @override
  String get commonOpenSettings => 'Einstellungen öffnen';

  @override
  String get navLibrary => 'Ablage';

  @override
  String get navSearch => 'Suche';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get scanButton => 'Scannen';

  @override
  String get onbWelcomeTitle => 'Ordnung für deine Post';

  @override
  String get onbWelcomeBody =>
      'Scanne Rechnungen, Verträge und Briefe – automatisch einsortiert und blitzschnell durchsuchbar.';

  @override
  String get onbPrivacyTitle => 'Alles bleibt auf deinem Gerät';

  @override
  String get onbPrivacyBody =>
      'Deine Dokumente verlassen nie dein Gerät. Keine Cloud, keine Konten, keine Werbung, kein Tracking.';

  @override
  String get onbLockTitle => 'Schütze deine Dokumente';

  @override
  String get onbLockBody =>
      'Aktiviere die App-Sperre mit Face ID oder Fingerabdruck. Optional – du kannst das jederzeit in den Einstellungen ändern.';

  @override
  String get onbEnableLock => 'App-Sperre aktivieren';

  @override
  String get onbGetStarted => 'Los geht\'s';

  @override
  String get onbLockUnavailable =>
      'Auf diesem Gerät ist keine biometrische Sperre verfügbar.';

  @override
  String get lockReason => 'Entsperre PaperVault, um deine Dokumente zu sehen.';

  @override
  String get lockTitle => 'PaperVault ist gesperrt';

  @override
  String get lockUnlock => 'Entsperren';

  @override
  String get scanReviewTitle => 'Seiten prüfen';

  @override
  String get scanReorderHint => 'Zum Sortieren gedrückt halten und ziehen.';

  @override
  String get scanAddPage => 'Seite hinzufügen';

  @override
  String get scanProcessing => 'Wird verarbeitet …';

  @override
  String get scanConfirmTitle => 'Prüfen & speichern';

  @override
  String get scanLowConfidence => 'Kategorie unsicher – bitte prüfen.';

  @override
  String scanSuggested(String category) {
    return 'Vorschlag: $category';
  }

  @override
  String get scanSavedMessage => 'Dokument gespeichert';

  @override
  String get scanErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get scanEmpty => 'Noch keine Seiten gescannt.';

  @override
  String scanPagesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldCategory => 'Kategorie';

  @override
  String get fieldSender => 'Absender';

  @override
  String get fieldDate => 'Datum';

  @override
  String get fieldAmount => 'Betrag';

  @override
  String get fieldTags => 'Schlagwörter';

  @override
  String get fieldNoDate => 'Kein Datum';

  @override
  String get fieldAddTag => 'Schlagwort hinzufügen';

  @override
  String get fieldOptional => 'optional';

  @override
  String get libCategories => 'Kategorien';

  @override
  String get libRecentlyAdded => 'Zuletzt hinzugefügt';

  @override
  String get libSeeAll => 'Alle ansehen';

  @override
  String get libEmptyTitle => 'Noch keine Dokumente';

  @override
  String get libEmptyBody =>
      'Tippe auf „Scannen“, um dein erstes Dokument hinzuzufügen.';

  @override
  String get catEmpty => 'Keine Dokumente in dieser Kategorie.';

  @override
  String get sortLabel => 'Sortieren';

  @override
  String get sortNewest => 'Neueste zuerst';

  @override
  String get sortOldest => 'Älteste zuerst';

  @override
  String get sortTitle => 'Titel (A–Z)';

  @override
  String get sortAmount => 'Betrag (absteigend)';

  @override
  String get filterFavoritesOnly => 'Nur Favoriten';

  @override
  String get detailMetadata => 'Details';

  @override
  String get detailExtractedText => 'Erkannter Text';

  @override
  String get detailNoText => 'Kein Text erkannt.';

  @override
  String detailPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get actionShare => 'Als PDF teilen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionMove => 'Verschieben';

  @override
  String get actionTags => 'Schlagwörter';

  @override
  String get actionFavorite => 'Zu Favoriten';

  @override
  String get actionUnfavorite => 'Aus Favoriten entfernen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get deleteConfirmTitle => 'Dokument löschen?';

  @override
  String get deleteConfirmBody =>
      'Das Dokument und alle zugehörigen Dateien werden dauerhaft von deinem Gerät gelöscht.';

  @override
  String get moveTitle => 'Kategorie wählen';

  @override
  String get editMetadataTitle => 'Metadaten bearbeiten';

  @override
  String get shareError => 'Teilen nicht möglich.';

  @override
  String get searchHint => 'Dokumente durchsuchen';

  @override
  String get searchRecent => 'Letzte Suchen';

  @override
  String get searchStart =>
      'Suche in Titeln, Absendern, Schlagwörtern und erkanntem Text.';

  @override
  String get searchNoResults => 'Keine Treffer';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Treffer',
      one: '1 Treffer',
    );
    return '$_temp0';
  }

  @override
  String get filterAllCategories => 'Alle Kategorien';

  @override
  String get filterDateRange => 'Zeitraum';

  @override
  String get filterClear => 'Filter zurücksetzen';

  @override
  String get setSecurity => 'Sicherheit';

  @override
  String get setAppLock => 'App-Sperre';

  @override
  String get setAppLockSubtitle =>
      'Beim Öffnen mit Face ID oder Fingerabdruck entsperren';

  @override
  String get setAppLockUnavailable => 'Auf diesem Gerät nicht verfügbar';

  @override
  String get setAppearance => 'Darstellung';

  @override
  String get setTheme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get setData => 'Daten';

  @override
  String get setCategories => 'Kategorien verwalten';

  @override
  String get setCategoriesSubtitle => 'Hinzufügen, umbenennen, sortieren';

  @override
  String get setBackup => 'Sicherung erstellen';

  @override
  String get setBackupSubtitle => 'Alles in eine ZIP-Datei exportieren';

  @override
  String get setRestore => 'Sicherung wiederherstellen';

  @override
  String get setRestoreSubtitle => 'Aus einer ZIP-Datei importieren';

  @override
  String get setAbout => 'Über & Datenschutz';

  @override
  String get backupCreating => 'Sicherung wird erstellt …';

  @override
  String get backupError => 'Sicherung fehlgeschlagen';

  @override
  String get restoreConfirmTitle => 'Wiederherstellen?';

  @override
  String get restoreConfirmBody =>
      'Alle aktuellen Dokumente werden durch die Sicherung ersetzt. Dieser Schritt kann nicht rückgängig gemacht werden.';

  @override
  String get restoring => 'Wird wiederhergestellt …';

  @override
  String get restoreDone => 'Wiederherstellung abgeschlossen';

  @override
  String get restoreError => 'Wiederherstellung fehlgeschlagen';

  @override
  String get catManageTitle => 'Kategorien';

  @override
  String get catAdd => 'Kategorie hinzufügen';

  @override
  String get catNewTitle => 'Neue Kategorie';

  @override
  String get catEditTitle => 'Kategorie bearbeiten';

  @override
  String get catName => 'Name';

  @override
  String get catIcon => 'Symbol';

  @override
  String get catColor => 'Farbe';

  @override
  String get catReorderHint => 'Zum Sortieren gedrückt halten und ziehen.';

  @override
  String get catCannotDelete =>
      'Nur leere, selbst erstellte Kategorien können gelöscht werden.';

  @override
  String get privacyHeadline => 'Deine Dokumente verlassen nie dein Gerät.';

  @override
  String get privacyBody =>
      'PaperVault ist zu 100 % offline. Es gibt keinen Server, kein Benutzerkonto und keine Cloud. Deine Scans, der erkannte Text und alle Metadaten werden ausschließlich lokal auf deinem Gerät gespeichert.\n\nWir sammeln keine Daten, verwenden keine Analyse- oder Tracking-Dienste und zeigen keine Werbung. Die App fordert keine Internet-Berechtigung an – deine Dokumente können dein Gerät technisch gar nicht verlassen.\n\nDie Texterkennung (OCR) und die automatische Einsortierung laufen vollständig auf deinem Gerät. Für eine Sicherung kannst du deine Daten selbst als verschlüsselbare ZIP-Datei exportieren; wohin sie gespeichert wird, entscheidest ausschließlich du.';

  @override
  String privacyVersion(String version) {
    return 'Version $version';
  }

  @override
  String get categoryRechnungen => 'Rechnungen';

  @override
  String get categoryLohnGehalt => 'Lohn & Gehalt';

  @override
  String get categorySteuern => 'Steuern & Finanzamt';

  @override
  String get categoryVertraege => 'Verträge';

  @override
  String get categoryVersicherungen => 'Versicherungen';

  @override
  String get categoryBank => 'Bank';

  @override
  String get categoryGesundheit => 'Gesundheit';

  @override
  String get categoryBehoerden => 'Behörden';

  @override
  String get categorySonstiges => 'Sonstiges';

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dokumente',
      one: '1 Dokument',
      zero: 'Keine Dokumente',
    );
    return '$_temp0';
  }
}
