import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// The product name shown in the UI. Single source of truth for renaming.
  ///
  /// In de, this message translates to:
  /// **'Papyra'**
  String get appName;

  /// No description provided for @commonSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get commonEdit;

  /// No description provided for @commonDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get commonDone;

  /// No description provided for @commonNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get commonBack;

  /// No description provided for @commonSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get commonSkip;

  /// No description provided for @commonRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get commonClose;

  /// No description provided for @commonShare.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get commonShare;

  /// No description provided for @commonSearch.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get commonSearch;

  /// No description provided for @commonSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get commonSettings;

  /// No description provided for @commonYes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get commonNo;

  /// No description provided for @commonOpenSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen öffnen'**
  String get commonOpenSettings;

  /// No description provided for @navLibrary.
  ///
  /// In de, this message translates to:
  /// **'Ablage'**
  String get navLibrary;

  /// No description provided for @navSearch.
  ///
  /// In de, this message translates to:
  /// **'Suche'**
  String get navSearch;

  /// No description provided for @navSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get navSettings;

  /// No description provided for @scanButton.
  ///
  /// In de, this message translates to:
  /// **'Scannen'**
  String get scanButton;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In de, this message translates to:
  /// **'Ordnung für deine Post'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In de, this message translates to:
  /// **'Scanne Rechnungen, Verträge und Briefe – automatisch einsortiert und blitzschnell durchsuchbar.'**
  String get onbWelcomeBody;

  /// No description provided for @onbPrivacyTitle.
  ///
  /// In de, this message translates to:
  /// **'Alles bleibt auf deinem Gerät'**
  String get onbPrivacyTitle;

  /// No description provided for @onbPrivacyBody.
  ///
  /// In de, this message translates to:
  /// **'Deine Dokumente verlassen nie dein Gerät. Keine Cloud, keine Konten, keine Werbung, kein Tracking.'**
  String get onbPrivacyBody;

  /// No description provided for @onbLockTitle.
  ///
  /// In de, this message translates to:
  /// **'Schütze deine Dokumente'**
  String get onbLockTitle;

  /// No description provided for @onbLockBody.
  ///
  /// In de, this message translates to:
  /// **'Aktiviere die App-Sperre mit Face ID oder Fingerabdruck. Optional – du kannst das jederzeit in den Einstellungen ändern.'**
  String get onbLockBody;

  /// No description provided for @onbEnableLock.
  ///
  /// In de, this message translates to:
  /// **'App-Sperre aktivieren'**
  String get onbEnableLock;

  /// No description provided for @onbGetStarted.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get onbGetStarted;

  /// No description provided for @onbLockUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Auf diesem Gerät ist keine biometrische Sperre verfügbar.'**
  String get onbLockUnavailable;

  /// No description provided for @lockReason.
  ///
  /// In de, this message translates to:
  /// **'Entsperre Papyra, um deine Dokumente zu sehen.'**
  String get lockReason;

  /// No description provided for @lockTitle.
  ///
  /// In de, this message translates to:
  /// **'Papyra ist gesperrt'**
  String get lockTitle;

  /// No description provided for @lockUnlock.
  ///
  /// In de, this message translates to:
  /// **'Entsperren'**
  String get lockUnlock;

  /// No description provided for @scanReviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Seiten prüfen'**
  String get scanReviewTitle;

  /// No description provided for @scanReorderHint.
  ///
  /// In de, this message translates to:
  /// **'Zum Sortieren gedrückt halten und ziehen.'**
  String get scanReorderHint;

  /// No description provided for @scanAddPage.
  ///
  /// In de, this message translates to:
  /// **'Seite hinzufügen'**
  String get scanAddPage;

  /// No description provided for @scanProcessing.
  ///
  /// In de, this message translates to:
  /// **'Wird verarbeitet …'**
  String get scanProcessing;

  /// No description provided for @scanConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Prüfen & speichern'**
  String get scanConfirmTitle;

  /// No description provided for @scanLowConfidence.
  ///
  /// In de, this message translates to:
  /// **'Kategorie unsicher – bitte prüfen.'**
  String get scanLowConfidence;

  /// No description provided for @scanSuggested.
  ///
  /// In de, this message translates to:
  /// **'Vorschlag: {category}'**
  String scanSuggested(String category);

  /// No description provided for @scanSavedMessage.
  ///
  /// In de, this message translates to:
  /// **'Dokument gespeichert'**
  String get scanSavedMessage;

  /// No description provided for @scanErrorTitle.
  ///
  /// In de, this message translates to:
  /// **'Etwas ist schiefgelaufen'**
  String get scanErrorTitle;

  /// No description provided for @scanEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Seiten gescannt.'**
  String get scanEmpty;

  /// No description provided for @scanPagesLabel.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Seite} other{{count} Seiten}}'**
  String scanPagesLabel(int count);

  /// No description provided for @fieldTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get fieldTitle;

  /// No description provided for @fieldCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get fieldCategory;

  /// No description provided for @fieldSender.
  ///
  /// In de, this message translates to:
  /// **'Absender'**
  String get fieldSender;

  /// No description provided for @fieldDate.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get fieldDate;

  /// No description provided for @fieldAmount.
  ///
  /// In de, this message translates to:
  /// **'Betrag'**
  String get fieldAmount;

  /// No description provided for @fieldTags.
  ///
  /// In de, this message translates to:
  /// **'Schlagwörter'**
  String get fieldTags;

  /// No description provided for @fieldNoDate.
  ///
  /// In de, this message translates to:
  /// **'Kein Datum'**
  String get fieldNoDate;

  /// No description provided for @fieldAddTag.
  ///
  /// In de, this message translates to:
  /// **'Schlagwort hinzufügen'**
  String get fieldAddTag;

  /// No description provided for @fieldOptional.
  ///
  /// In de, this message translates to:
  /// **'optional'**
  String get fieldOptional;

  /// No description provided for @fieldGroup.
  ///
  /// In de, this message translates to:
  /// **'Gruppe'**
  String get fieldGroup;

  /// No description provided for @groupNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get groupNone;

  /// No description provided for @groupAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get groupAll;

  /// No description provided for @groupUngrouped.
  ///
  /// In de, this message translates to:
  /// **'Ohne Gruppe'**
  String get groupUngrouped;

  /// No description provided for @groupNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Gruppe …'**
  String get groupNew;

  /// No description provided for @groupCreateTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Gruppe'**
  String get groupCreateTitle;

  /// No description provided for @groupNameHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Strom, Internet/Telefonie'**
  String get groupNameHint;

  /// No description provided for @groupAutoFiled.
  ///
  /// In de, this message translates to:
  /// **'Automatisch einsortiert'**
  String get groupAutoFiled;

  /// No description provided for @groupAdd.
  ///
  /// In de, this message translates to:
  /// **'Gruppe hinzufügen'**
  String get groupAdd;

  /// No description provided for @groupDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'Gruppe löschen? Die Dokumente bleiben erhalten und werden zu „Ohne Gruppe“.'**
  String get groupDeleteConfirm;

  /// No description provided for @libCategories.
  ///
  /// In de, this message translates to:
  /// **'Kategorien'**
  String get libCategories;

  /// No description provided for @libRecentlyAdded.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt hinzugefügt'**
  String get libRecentlyAdded;

  /// No description provided for @libSeeAll.
  ///
  /// In de, this message translates to:
  /// **'Alle ansehen'**
  String get libSeeAll;

  /// No description provided for @libEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Dokumente'**
  String get libEmptyTitle;

  /// No description provided for @libEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf „Scannen“, um dein erstes Dokument hinzuzufügen.'**
  String get libEmptyBody;

  /// No description provided for @catEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Dokumente in dieser Kategorie.'**
  String get catEmpty;

  /// No description provided for @sortLabel.
  ///
  /// In de, this message translates to:
  /// **'Sortieren'**
  String get sortLabel;

  /// No description provided for @sortNewest.
  ///
  /// In de, this message translates to:
  /// **'Neueste zuerst'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In de, this message translates to:
  /// **'Älteste zuerst'**
  String get sortOldest;

  /// No description provided for @sortTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel (A–Z)'**
  String get sortTitle;

  /// No description provided for @sortAmount.
  ///
  /// In de, this message translates to:
  /// **'Betrag (absteigend)'**
  String get sortAmount;

  /// No description provided for @filterFavoritesOnly.
  ///
  /// In de, this message translates to:
  /// **'Nur Favoriten'**
  String get filterFavoritesOnly;

  /// No description provided for @detailMetadata.
  ///
  /// In de, this message translates to:
  /// **'Details'**
  String get detailMetadata;

  /// No description provided for @detailExtractedText.
  ///
  /// In de, this message translates to:
  /// **'Erkannter Text'**
  String get detailExtractedText;

  /// No description provided for @detailNoText.
  ///
  /// In de, this message translates to:
  /// **'Kein Text erkannt.'**
  String get detailNoText;

  /// No description provided for @detailPageIndicator.
  ///
  /// In de, this message translates to:
  /// **'{current} / {total}'**
  String detailPageIndicator(int current, int total);

  /// No description provided for @actionShare.
  ///
  /// In de, this message translates to:
  /// **'Als PDF teilen'**
  String get actionShare;

  /// No description provided for @actionEdit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get actionEdit;

  /// No description provided for @actionMove.
  ///
  /// In de, this message translates to:
  /// **'Verschieben'**
  String get actionMove;

  /// No description provided for @actionTags.
  ///
  /// In de, this message translates to:
  /// **'Schlagwörter'**
  String get actionTags;

  /// No description provided for @actionFavorite.
  ///
  /// In de, this message translates to:
  /// **'Zu Favoriten'**
  String get actionFavorite;

  /// No description provided for @actionUnfavorite.
  ///
  /// In de, this message translates to:
  /// **'Aus Favoriten entfernen'**
  String get actionUnfavorite;

  /// No description provided for @actionDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get actionDelete;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Dokument löschen?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Das Dokument und alle zugehörigen Dateien werden dauerhaft von deinem Gerät gelöscht.'**
  String get deleteConfirmBody;

  /// No description provided for @moveTitle.
  ///
  /// In de, this message translates to:
  /// **'Kategorie wählen'**
  String get moveTitle;

  /// No description provided for @editMetadataTitle.
  ///
  /// In de, this message translates to:
  /// **'Metadaten bearbeiten'**
  String get editMetadataTitle;

  /// No description provided for @shareError.
  ///
  /// In de, this message translates to:
  /// **'Teilen nicht möglich.'**
  String get shareError;

  /// No description provided for @searchHint.
  ///
  /// In de, this message translates to:
  /// **'Dokumente durchsuchen'**
  String get searchHint;

  /// No description provided for @searchRecent.
  ///
  /// In de, this message translates to:
  /// **'Letzte Suchen'**
  String get searchRecent;

  /// No description provided for @searchStart.
  ///
  /// In de, this message translates to:
  /// **'Suche in Titeln, Absendern, Schlagwörtern und erkanntem Text.'**
  String get searchStart;

  /// No description provided for @searchNoResults.
  ///
  /// In de, this message translates to:
  /// **'Keine Treffer'**
  String get searchNoResults;

  /// No description provided for @searchResultsCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Treffer} other{{count} Treffer}}'**
  String searchResultsCount(int count);

  /// No description provided for @filterAllCategories.
  ///
  /// In de, this message translates to:
  /// **'Alle Kategorien'**
  String get filterAllCategories;

  /// No description provided for @filterDateRange.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum'**
  String get filterDateRange;

  /// No description provided for @filterClear.
  ///
  /// In de, this message translates to:
  /// **'Filter zurücksetzen'**
  String get filterClear;

  /// No description provided for @setSecurity.
  ///
  /// In de, this message translates to:
  /// **'Sicherheit'**
  String get setSecurity;

  /// No description provided for @setAppLock.
  ///
  /// In de, this message translates to:
  /// **'App-Sperre'**
  String get setAppLock;

  /// No description provided for @setAppLockSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Beim Öffnen mit Face ID oder Fingerabdruck entsperren'**
  String get setAppLockSubtitle;

  /// No description provided for @setAppLockUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Auf diesem Gerät nicht verfügbar'**
  String get setAppLockUnavailable;

  /// No description provided for @setAppearance.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get setAppearance;

  /// No description provided for @setTheme.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get setTheme;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @setData.
  ///
  /// In de, this message translates to:
  /// **'Daten'**
  String get setData;

  /// No description provided for @setCategories.
  ///
  /// In de, this message translates to:
  /// **'Kategorien verwalten'**
  String get setCategories;

  /// No description provided for @setCategoriesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen, umbenennen, sortieren'**
  String get setCategoriesSubtitle;

  /// No description provided for @setBackup.
  ///
  /// In de, this message translates to:
  /// **'Sicherung erstellen'**
  String get setBackup;

  /// No description provided for @setBackupSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alles in eine ZIP-Datei exportieren'**
  String get setBackupSubtitle;

  /// No description provided for @setRestore.
  ///
  /// In de, this message translates to:
  /// **'Sicherung wiederherstellen'**
  String get setRestore;

  /// No description provided for @setRestoreSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Aus einer ZIP-Datei importieren'**
  String get setRestoreSubtitle;

  /// No description provided for @setAbout.
  ///
  /// In de, this message translates to:
  /// **'Über & Datenschutz'**
  String get setAbout;

  /// No description provided for @backupCreating.
  ///
  /// In de, this message translates to:
  /// **'Sicherung wird erstellt …'**
  String get backupCreating;

  /// No description provided for @backupError.
  ///
  /// In de, this message translates to:
  /// **'Sicherung fehlgeschlagen'**
  String get backupError;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Alle aktuellen Dokumente werden durch die Sicherung ersetzt. Dieser Schritt kann nicht rückgängig gemacht werden.'**
  String get restoreConfirmBody;

  /// No description provided for @restoring.
  ///
  /// In de, this message translates to:
  /// **'Wird wiederhergestellt …'**
  String get restoring;

  /// No description provided for @restoreDone.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellung abgeschlossen'**
  String get restoreDone;

  /// No description provided for @restoreError.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellung fehlgeschlagen'**
  String get restoreError;

  /// No description provided for @catManageTitle.
  ///
  /// In de, this message translates to:
  /// **'Kategorien'**
  String get catManageTitle;

  /// No description provided for @catAdd.
  ///
  /// In de, this message translates to:
  /// **'Kategorie hinzufügen'**
  String get catAdd;

  /// No description provided for @catNewTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Kategorie'**
  String get catNewTitle;

  /// No description provided for @catEditTitle.
  ///
  /// In de, this message translates to:
  /// **'Kategorie bearbeiten'**
  String get catEditTitle;

  /// No description provided for @catName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get catName;

  /// No description provided for @catIcon.
  ///
  /// In de, this message translates to:
  /// **'Symbol'**
  String get catIcon;

  /// No description provided for @catColor.
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get catColor;

  /// No description provided for @catReorderHint.
  ///
  /// In de, this message translates to:
  /// **'Zum Sortieren gedrückt halten und ziehen.'**
  String get catReorderHint;

  /// No description provided for @catCannotDelete.
  ///
  /// In de, this message translates to:
  /// **'Nur leere, selbst erstellte Kategorien können gelöscht werden.'**
  String get catCannotDelete;

  /// No description provided for @privacyHeadline.
  ///
  /// In de, this message translates to:
  /// **'Deine Dokumente verlassen nie dein Gerät.'**
  String get privacyHeadline;

  /// No description provided for @privacyBody.
  ///
  /// In de, this message translates to:
  /// **'Papyra ist zu 100 % offline. Es gibt keinen Server, kein Benutzerkonto und keine Cloud. Deine Scans, der erkannte Text und alle Metadaten werden ausschließlich lokal auf deinem Gerät gespeichert.\n\nWir sammeln keine Daten, verwenden keine Analyse- oder Tracking-Dienste und zeigen keine Werbung. Die App fordert keine Internet-Berechtigung an – deine Dokumente können dein Gerät technisch gar nicht verlassen.\n\nDie Texterkennung (OCR) und die automatische Einsortierung laufen vollständig auf deinem Gerät. Für eine Sicherung kannst du deine Daten selbst als verschlüsselbare ZIP-Datei exportieren; wohin sie gespeichert wird, entscheidest ausschließlich du.'**
  String get privacyBody;

  /// No description provided for @privacyVersion.
  ///
  /// In de, this message translates to:
  /// **'Version {version}'**
  String privacyVersion(String version);

  /// No description provided for @categoryRechnungen.
  ///
  /// In de, this message translates to:
  /// **'Rechnungen'**
  String get categoryRechnungen;

  /// No description provided for @categoryLohnGehalt.
  ///
  /// In de, this message translates to:
  /// **'Lohn & Gehalt'**
  String get categoryLohnGehalt;

  /// No description provided for @categorySteuern.
  ///
  /// In de, this message translates to:
  /// **'Steuern & Finanzamt'**
  String get categorySteuern;

  /// No description provided for @categoryVertraege.
  ///
  /// In de, this message translates to:
  /// **'Verträge'**
  String get categoryVertraege;

  /// No description provided for @categoryVersicherungen.
  ///
  /// In de, this message translates to:
  /// **'Versicherungen'**
  String get categoryVersicherungen;

  /// No description provided for @categoryBank.
  ///
  /// In de, this message translates to:
  /// **'Bank'**
  String get categoryBank;

  /// No description provided for @categoryGesundheit.
  ///
  /// In de, this message translates to:
  /// **'Gesundheit'**
  String get categoryGesundheit;

  /// No description provided for @categoryBehoerden.
  ///
  /// In de, this message translates to:
  /// **'Behörden'**
  String get categoryBehoerden;

  /// No description provided for @categorySonstiges.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get categorySonstiges;

  /// No description provided for @documentsCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine Dokumente} =1{1 Dokument} other{{count} Dokumente}}'**
  String documentsCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
