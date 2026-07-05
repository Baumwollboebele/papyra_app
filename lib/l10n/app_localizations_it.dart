// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Papyra';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonEdit => 'Modifica';

  @override
  String get commonDone => 'Fatto';

  @override
  String get commonNext => 'Avanti';

  @override
  String get commonBack => 'Indietro';

  @override
  String get commonSkip => 'Salta';

  @override
  String get commonRetry => 'Riprova';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonShare => 'Condividi';

  @override
  String get commonSearch => 'Cerca';

  @override
  String get commonSettings => 'Impostazioni';

  @override
  String get commonYes => 'Sì';

  @override
  String get commonNo => 'No';

  @override
  String get commonOpenSettings => 'Apri impostazioni';

  @override
  String get navLibrary => 'Archivio';

  @override
  String get navSearch => 'Ricerca';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get scanButton => 'Scansiona';

  @override
  String get onbWelcomeTitle => 'Ordine nella tua posta';

  @override
  String get onbWelcomeBody =>
      'Scansiona fatture, contratti e lettere – archiviati automaticamente e consultabili in un istante.';

  @override
  String get onbPrivacyTitle => 'Tutto resta sul tuo dispositivo';

  @override
  String get onbPrivacyBody =>
      'I tuoi documenti non lasciano mai il tuo dispositivo. Nessun cloud, nessun account, nessuna pubblicità, nessun tracciamento.';

  @override
  String get onbLockTitle => 'Proteggi i tuoi documenti';

  @override
  String get onbLockBody =>
      'Attiva il blocco dell\'app con Face ID o impronta digitale. Facoltativo – puoi modificarlo in qualsiasi momento nelle impostazioni.';

  @override
  String get onbEnableLock => 'Attiva il blocco app';

  @override
  String get onbGetStarted => 'Iniziamo';

  @override
  String get onbLockUnavailable =>
      'Su questo dispositivo non è disponibile alcun blocco biometrico.';

  @override
  String get lockReason => 'Sblocca Papyra per vedere i tuoi documenti.';

  @override
  String get lockTitle => 'Papyra è bloccato';

  @override
  String get lockUnlock => 'Sblocca';

  @override
  String get scanReviewTitle => 'Controlla le pagine';

  @override
  String get scanReorderHint => 'Tieni premuto e trascina per riordinare.';

  @override
  String get scanAddPage => 'Aggiungi pagina';

  @override
  String get scanProcessing => 'Elaborazione in corso …';

  @override
  String get scanConfirmTitle => 'Controlla e salva';

  @override
  String get scanLowConfidence => 'Categoria incerta – controlla.';

  @override
  String get confidenceHigh => 'Riconosciuto con certezza';

  @override
  String get confidenceMedium => 'Controlla la categoria';

  @override
  String get confidenceLow => 'Categoria incerta';

  @override
  String get altCategoriesLabel => 'Più adatta:';

  @override
  String scanSuggested(String category) {
    return 'Suggerimento: $category';
  }

  @override
  String get scanSavedMessage => 'Documento salvato';

  @override
  String get ingestPreparing => 'Preparazione dei file …';

  @override
  String ingestProgress(int current, int total) {
    return 'Documento $current di $total';
  }

  @override
  String get ingestDoneTitle => 'Importazione completata';

  @override
  String ingestDoneSummary(int saved, int skipped) {
    return '$saved salvati · $skipped ignorati';
  }

  @override
  String get ingestEmpty => 'Nessun file supportato trovato.';

  @override
  String get importAction => 'Importa';

  @override
  String get scanErrorTitle => 'Qualcosa è andato storto';

  @override
  String get scanEmpty => 'Ancora nessuna pagina scansionata.';

  @override
  String scanPagesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagine',
      one: '1 pagina',
    );
    return '$_temp0';
  }

  @override
  String get fieldTitle => 'Titolo';

  @override
  String get fieldCategory => 'Categoria';

  @override
  String get fieldSender => 'Mittente';

  @override
  String get fieldDate => 'Data';

  @override
  String get fieldAmount => 'Importo';

  @override
  String get fieldTags => 'Tag';

  @override
  String get fieldNoDate => 'Nessuna data';

  @override
  String get fieldAddTag => 'Aggiungi tag';

  @override
  String get fieldOptional => 'facoltativo';

  @override
  String get fieldGroup => 'Gruppo';

  @override
  String get fieldDueDate => 'Scadenza';

  @override
  String get navDue => 'Scadenze';

  @override
  String get dueOverdue => 'Scaduto';

  @override
  String get dueUpcoming => 'In arrivo';

  @override
  String get duePaidSection => 'Pagato';

  @override
  String get dueEmpty => 'Nessuna scadenza in sospeso.';

  @override
  String get dueMarkPaid => 'Segna come pagato';

  @override
  String get dueMarkUnpaid => 'Segna come non pagato';

  @override
  String get dueToday => 'In scadenza oggi';

  @override
  String dueInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return 'tra $_temp0';
  }

  @override
  String dueDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get calendarExport => 'Aggiungi al calendario';

  @override
  String calendarSummary(String title) {
    return 'Scadenza: $title';
  }

  @override
  String get calendarError => 'Esportazione nel calendario non riuscita.';

  @override
  String get setReminders => 'Promemoria';

  @override
  String get setReminderEnabled => 'Promemoria di scadenza';

  @override
  String get setReminderEnabledSubtitle =>
      'Ricorda la scadenza di pagamento delle fatture';

  @override
  String setReminderLead(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni prima',
      one: '1 giorno prima',
      zero: 'il giorno della scadenza',
    );
    return 'Anticipo: $_temp0';
  }

  @override
  String get setReminderOnDue => 'Ricorda anche il giorno della scadenza';

  @override
  String get reminderPermissionDenied =>
      'Le notifiche sono disattivate. Consentile nelle impostazioni di sistema.';

  @override
  String get groupNone => 'Nessuno';

  @override
  String get groupAll => 'Tutti';

  @override
  String get groupUngrouped => 'Senza gruppo';

  @override
  String get groupNew => 'Nuovo gruppo …';

  @override
  String get groupCreateTitle => 'Nuovo gruppo';

  @override
  String get groupNameHint => 'es. Elettricità, Internet/Telefonia';

  @override
  String get groupAutoFiled => 'Archiviato automaticamente';

  @override
  String get groupAdd => 'Aggiungi gruppo';

  @override
  String get groupDeleteConfirm =>
      'Eliminare il gruppo? I documenti vengono conservati e spostati in «Senza gruppo».';

  @override
  String get libCategories => 'Categorie';

  @override
  String get libRecentlyAdded => 'Aggiunti di recente';

  @override
  String get libSeeAll => 'Vedi tutti';

  @override
  String get libEmptyTitle => 'Ancora nessun documento';

  @override
  String get libEmptyBody =>
      'Tocca «Scansiona» per aggiungere il tuo primo documento.';

  @override
  String get catEmpty => 'Nessun documento in questa categoria.';

  @override
  String get sortLabel => 'Ordina';

  @override
  String get sortNewest => 'Prima i più recenti';

  @override
  String get sortOldest => 'Prima i più vecchi';

  @override
  String get sortTitle => 'Titolo (A–Z)';

  @override
  String get sortAmount => 'Importo (decrescente)';

  @override
  String get filterFavoritesOnly => 'Solo preferiti';

  @override
  String get detailMetadata => 'Dettagli';

  @override
  String get detailExtractedText => 'Testo riconosciuto';

  @override
  String get detailNoText => 'Nessun testo riconosciuto.';

  @override
  String detailPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get actionShare => 'Condividi come PDF';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionMove => 'Sposta';

  @override
  String get actionTags => 'Tag';

  @override
  String get actionFavorite => 'Aggiungi ai preferiti';

  @override
  String get actionUnfavorite => 'Rimuovi dai preferiti';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get deleteConfirmTitle => 'Eliminare il documento?';

  @override
  String get deleteConfirmBody =>
      'Il documento e tutti i file associati verranno eliminati definitivamente dal tuo dispositivo.';

  @override
  String get moveTitle => 'Scegli una categoria';

  @override
  String get editMetadataTitle => 'Modifica metadati';

  @override
  String get shareError => 'Condivisione non riuscita.';

  @override
  String get searchHint => 'Cerca documenti';

  @override
  String get searchRecent => 'Ricerche recenti';

  @override
  String get searchStart =>
      'Cerca in titoli, mittenti, tag e testo riconosciuto.';

  @override
  String get searchNoResults => 'Nessun risultato';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '1 risultato',
    );
    return '$_temp0';
  }

  @override
  String get filterAllCategories => 'Tutte le categorie';

  @override
  String get filterDateRange => 'Periodo';

  @override
  String get filterClear => 'Reimposta i filtri';

  @override
  String get setSecurity => 'Sicurezza';

  @override
  String get setAppLock => 'Blocco app';

  @override
  String get setAppLockSubtitle =>
      'Sblocca all\'apertura con Face ID o impronta digitale';

  @override
  String get setAppLockUnavailable => 'Non disponibile su questo dispositivo';

  @override
  String get setAppearance => 'Aspetto';

  @override
  String get setTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get setFiling => 'Riconoscimento e titoli';

  @override
  String get setTitleTemplate => 'Modello di titolo';

  @override
  String get setTitleTemplateHint => 'Segnaposto: sender, docType, date';

  @override
  String get setTitleTemplateReset => 'Ripristina predefinito';

  @override
  String get setAutoAccept => 'Salva automaticamente i documenti attendibili';

  @override
  String get setAutoAcceptSubtitle =>
      'Salta la conferma in caso di alta certezza';

  @override
  String get setData => 'Dati';

  @override
  String get setCategories => 'Gestisci categorie';

  @override
  String get setCategoriesSubtitle => 'Aggiungi, rinomina, ordina';

  @override
  String get setBackup => 'Crea backup';

  @override
  String get setBackupSubtitle => 'Esporta tutto in un file ZIP';

  @override
  String get setRestore => 'Ripristina backup';

  @override
  String get setRestoreSubtitle => 'Importa da un file ZIP';

  @override
  String get setAbout => 'Informazioni e privacy';

  @override
  String get backupCreating => 'Creazione del backup …';

  @override
  String get backupError => 'Backup non riuscito';

  @override
  String get restoreConfirmTitle => 'Ripristinare?';

  @override
  String get restoreConfirmBody =>
      'Tutti i documenti attuali verranno sostituiti dal backup. Questa operazione non può essere annullata.';

  @override
  String get restoring => 'Ripristino in corso …';

  @override
  String get restoreDone => 'Ripristino completato';

  @override
  String get restoreError => 'Ripristino non riuscito';

  @override
  String get catManageTitle => 'Categorie';

  @override
  String get catAdd => 'Aggiungi categoria';

  @override
  String get catNewTitle => 'Nuova categoria';

  @override
  String get catEditTitle => 'Modifica categoria';

  @override
  String get catName => 'Nome';

  @override
  String get catIcon => 'Icona';

  @override
  String get catColor => 'Colore';

  @override
  String get catReorderHint => 'Tieni premuto e trascina per riordinare.';

  @override
  String get catCannotDelete =>
      'Solo le categorie vuote create da te possono essere eliminate.';

  @override
  String get privacyHeadline =>
      'I tuoi documenti non lasciano mai il tuo dispositivo.';

  @override
  String get privacyBody =>
      'Papyra è 100% offline. Non esiste alcun server, alcun account utente e alcun cloud. Le tue scansioni, il testo riconosciuto e tutti i metadati vengono salvati esclusivamente in locale sul tuo dispositivo.\n\nNon raccogliamo dati, non utilizziamo servizi di analisi o tracciamento e non mostriamo pubblicità. L\'app non richiede alcuna autorizzazione a Internet – tecnicamente i tuoi documenti non possono nemmeno lasciare il tuo dispositivo.\n\nIl riconoscimento del testo (OCR) e l\'archiviazione automatica avvengono interamente sul tuo dispositivo. Per un backup puoi esportare tu stesso i tuoi dati in un file ZIP cifrabile; solo tu decidi dove salvarlo.\n\nI promemoria di scadenza vengono pianificati esclusivamente in locale sul tuo dispositivo (notifiche). Nessun dato viene trasmesso.';

  @override
  String privacyVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get categoryRechnungen => 'Fatture';

  @override
  String get categoryLohnGehalt => 'Stipendi e retribuzioni';

  @override
  String get categorySteuern => 'Tasse e fisco';

  @override
  String get categoryVertraege => 'Contratti';

  @override
  String get categoryVersicherungen => 'Assicurazioni';

  @override
  String get categoryBank => 'Banca';

  @override
  String get categoryGesundheit => 'Salute';

  @override
  String get categoryBehoerden => 'Enti pubblici';

  @override
  String get categorySonstiges => 'Altro';

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documenti',
      one: '1 documento',
      zero: 'Nessun documento',
    );
    return '$_temp0';
  }
}
