// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Papyra';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonSkip => 'Ignorer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get commonSettings => 'Paramètres';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonOpenSettings => 'Ouvrir les paramètres';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get scanButton => 'Numériser';

  @override
  String get onbWelcomeTitle => 'De l\'ordre dans votre courrier';

  @override
  String get onbWelcomeBody =>
      'Numérisez factures, contrats et lettres – classés automatiquement et consultables en un instant.';

  @override
  String get onbPrivacyTitle => 'Tout reste sur votre appareil';

  @override
  String get onbPrivacyBody =>
      'Vos documents ne quittent jamais votre appareil. Aucun cloud, aucun compte, aucune publicité, aucun suivi.';

  @override
  String get onbLockTitle => 'Protégez vos documents';

  @override
  String get onbLockBody =>
      'Activez le verrouillage de l\'application avec Face ID ou l\'empreinte digitale. Facultatif – vous pouvez le modifier à tout moment dans les paramètres.';

  @override
  String get onbEnableLock => 'Activer le verrouillage';

  @override
  String get onbGetStarted => 'C\'est parti';

  @override
  String get onbLockUnavailable =>
      'Aucun verrouillage biométrique n\'est disponible sur cet appareil.';

  @override
  String get lockReason => 'Déverrouillez Papyra pour voir vos documents.';

  @override
  String get lockTitle => 'Papyra est verrouillé';

  @override
  String get lockUnlock => 'Déverrouiller';

  @override
  String get scanReviewTitle => 'Vérifier les pages';

  @override
  String get scanReorderHint => 'Maintenez et faites glisser pour réorganiser.';

  @override
  String get scanAddPage => 'Ajouter une page';

  @override
  String get scanProcessing => 'Traitement en cours …';

  @override
  String get scanConfirmTitle => 'Vérifier et enregistrer';

  @override
  String get scanLowConfidence => 'Catégorie incertaine – veuillez vérifier.';

  @override
  String get confidenceHigh => 'Reconnu avec certitude';

  @override
  String get confidenceMedium => 'Veuillez vérifier la catégorie';

  @override
  String get confidenceLow => 'Catégorie incertaine';

  @override
  String get altCategoriesLabel => 'Conviendrait mieux :';

  @override
  String scanSuggested(String category) {
    return 'Suggestion : $category';
  }

  @override
  String get scanSavedMessage => 'Document enregistré';

  @override
  String get ingestPreparing => 'Préparation des fichiers …';

  @override
  String ingestProgress(int current, int total) {
    return 'Document $current sur $total';
  }

  @override
  String get ingestDoneTitle => 'Importation terminée';

  @override
  String ingestDoneSummary(int saved, int skipped) {
    return '$saved enregistrés · $skipped ignorés';
  }

  @override
  String get ingestEmpty => 'Aucun fichier pris en charge trouvé.';

  @override
  String get importAction => 'Importer';

  @override
  String get scanErrorTitle => 'Une erreur s\'est produite';

  @override
  String get scanEmpty => 'Aucune page numérisée pour le moment.';

  @override
  String scanPagesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get fieldTitle => 'Titre';

  @override
  String get fieldCategory => 'Catégorie';

  @override
  String get fieldSender => 'Expéditeur';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldAmount => 'Montant';

  @override
  String get fieldTags => 'Étiquettes';

  @override
  String get fieldNoDate => 'Aucune date';

  @override
  String get fieldAddTag => 'Ajouter une étiquette';

  @override
  String get fieldOptional => 'facultatif';

  @override
  String get fieldGroup => 'Groupe';

  @override
  String get fieldDueDate => 'Échéance';

  @override
  String get navDue => 'Échéances';

  @override
  String get dueOverdue => 'En retard';

  @override
  String get dueUpcoming => 'À venir';

  @override
  String get duePaidSection => 'Payé';

  @override
  String get dueEmpty => 'Aucune échéance en attente.';

  @override
  String get dueMarkPaid => 'Marquer comme payé';

  @override
  String get dueMarkUnpaid => 'Marquer comme impayé';

  @override
  String get dueToday => 'À échéance aujourd\'hui';

  @override
  String dueInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return 'dans $_temp0';
  }

  @override
  String dueDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return 'il y a $_temp0';
  }

  @override
  String get calendarExport => 'Ajouter au calendrier';

  @override
  String calendarSummary(String title) {
    return 'Échéance : $title';
  }

  @override
  String get calendarError => 'Export vers le calendrier impossible.';

  @override
  String get setReminders => 'Rappels';

  @override
  String get setReminderEnabled => 'Rappels d\'échéance';

  @override
  String get setReminderEnabledSubtitle =>
      'Rappeler la date limite de paiement des factures';

  @override
  String setReminderLead(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours avant',
      one: '1 jour avant',
      zero: 'à échéance',
    );
    return 'Anticipation : $_temp0';
  }

  @override
  String get setReminderOnDue => 'Rappeler aussi le jour de l\'échéance';

  @override
  String get reminderPermissionDenied =>
      'Les notifications sont désactivées. Veuillez les autoriser dans les paramètres système.';

  @override
  String get groupNone => 'Aucun';

  @override
  String get groupAll => 'Tous';

  @override
  String get groupUngrouped => 'Sans groupe';

  @override
  String get groupNew => 'Nouveau groupe …';

  @override
  String get groupCreateTitle => 'Nouveau groupe';

  @override
  String get groupNameHint => 'p. ex. Électricité, Internet/Téléphonie';

  @override
  String get groupAutoFiled => 'Classé automatiquement';

  @override
  String get groupAdd => 'Ajouter un groupe';

  @override
  String get groupDeleteConfirm =>
      'Supprimer le groupe ? Les documents sont conservés et passent dans « Sans groupe ».';

  @override
  String get libCategories => 'Catégories';

  @override
  String get libRecentlyAdded => 'Ajoutés récemment';

  @override
  String get libSeeAll => 'Tout voir';

  @override
  String get libEmptyTitle => 'Aucun document';

  @override
  String get libEmptyBody =>
      'Appuyez sur « Numériser » pour ajouter votre premier document.';

  @override
  String get catEmpty => 'Aucun document dans cette catégorie.';

  @override
  String get sortLabel => 'Trier';

  @override
  String get sortNewest => 'Plus récents d\'abord';

  @override
  String get sortOldest => 'Plus anciens d\'abord';

  @override
  String get sortTitle => 'Titre (A–Z)';

  @override
  String get sortAmount => 'Montant (décroissant)';

  @override
  String get filterFavoritesOnly => 'Favoris uniquement';

  @override
  String get detailMetadata => 'Détails';

  @override
  String get detailExtractedText => 'Texte reconnu';

  @override
  String get detailNoText => 'Aucun texte reconnu.';

  @override
  String detailPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get actionShare => 'Partager en PDF';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionMove => 'Déplacer';

  @override
  String get actionTags => 'Étiquettes';

  @override
  String get actionFavorite => 'Ajouter aux favoris';

  @override
  String get actionUnfavorite => 'Retirer des favoris';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get deleteConfirmTitle => 'Supprimer le document ?';

  @override
  String get deleteConfirmBody =>
      'Le document et tous les fichiers associés seront définitivement supprimés de votre appareil.';

  @override
  String get moveTitle => 'Choisir une catégorie';

  @override
  String get editMetadataTitle => 'Modifier les métadonnées';

  @override
  String get shareError => 'Partage impossible.';

  @override
  String get searchHint => 'Rechercher des documents';

  @override
  String get searchRecent => 'Recherches récentes';

  @override
  String get searchStart =>
      'Recherchez dans les titres, expéditeurs, étiquettes et texte reconnu.';

  @override
  String get searchNoResults => 'Aucun résultat';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0';
  }

  @override
  String get filterAllCategories => 'Toutes les catégories';

  @override
  String get filterDateRange => 'Période';

  @override
  String get filterClear => 'Réinitialiser les filtres';

  @override
  String get setSecurity => 'Sécurité';

  @override
  String get setAppLock => 'Verrouillage de l\'application';

  @override
  String get setAppLockSubtitle =>
      'Déverrouiller à l\'ouverture avec Face ID ou l\'empreinte digitale';

  @override
  String get setAppLockUnavailable => 'Non disponible sur cet appareil';

  @override
  String get setAppearance => 'Apparence';

  @override
  String get setTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get setLanguage => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get setFiling => 'Reconnaissance et titres';

  @override
  String get setTitleTemplate => 'Modèle de titre';

  @override
  String get setTitleTemplateHint => 'Espaces réservés : sender, docType, date';

  @override
  String get setTitleTemplateReset => 'Rétablir la valeur par défaut';

  @override
  String get setAutoAccept =>
      'Enregistrer automatiquement les documents fiables';

  @override
  String get setAutoAcceptSubtitle =>
      'Ignorer la confirmation en cas de haute certitude';

  @override
  String get setData => 'Données';

  @override
  String get setCategories => 'Gérer les catégories';

  @override
  String get setCategoriesSubtitle => 'Ajouter, renommer, trier';

  @override
  String get setBackup => 'Créer une sauvegarde';

  @override
  String get setBackupSubtitle => 'Tout exporter dans un fichier ZIP';

  @override
  String get setRestore => 'Restaurer une sauvegarde';

  @override
  String get setRestoreSubtitle => 'Importer depuis un fichier ZIP';

  @override
  String get setAbout => 'À propos et confidentialité';

  @override
  String get backupCreating => 'Création de la sauvegarde …';

  @override
  String get backupError => 'Échec de la sauvegarde';

  @override
  String get restoreConfirmTitle => 'Restaurer ?';

  @override
  String get restoreConfirmBody =>
      'Tous les documents actuels seront remplacés par la sauvegarde. Cette action est irréversible.';

  @override
  String get restoring => 'Restauration en cours …';

  @override
  String get restoreDone => 'Restauration terminée';

  @override
  String get restoreError => 'Échec de la restauration';

  @override
  String get catManageTitle => 'Catégories';

  @override
  String get catAdd => 'Ajouter une catégorie';

  @override
  String get catNewTitle => 'Nouvelle catégorie';

  @override
  String get catEditTitle => 'Modifier la catégorie';

  @override
  String get catName => 'Nom';

  @override
  String get catIcon => 'Icône';

  @override
  String get catColor => 'Couleur';

  @override
  String get catReorderHint => 'Maintenez et faites glisser pour réorganiser.';

  @override
  String get catCannotDelete =>
      'Seules les catégories vides que vous avez créées peuvent être supprimées.';

  @override
  String get privacyHeadline =>
      'Vos documents ne quittent jamais votre appareil.';

  @override
  String get privacyBody =>
      'Papyra est 100 % hors ligne. Il n\'y a aucun serveur, aucun compte utilisateur et aucun cloud. Vos numérisations, le texte reconnu et toutes les métadonnées sont enregistrés exclusivement en local sur votre appareil.\n\nNous ne collectons aucune donnée, n\'utilisons aucun service d\'analyse ou de suivi et n\'affichons aucune publicité. L\'application ne demande aucune autorisation d\'accès à Internet – techniquement, vos documents ne peuvent même pas quitter votre appareil.\n\nLa reconnaissance de texte (OCR) et le classement automatique s\'effectuent entièrement sur votre appareil. Pour une sauvegarde, vous pouvez exporter vous-même vos données dans un fichier ZIP chiffrable ; vous seul décidez de l\'endroit où il est enregistré.\n\nLes rappels d\'échéance sont planifiés exclusivement en local sur votre appareil (notifications). Aucune donnée n\'est transmise à cette occasion.';

  @override
  String privacyVersion(String version) {
    return 'Version $version';
  }

  @override
  String get categoryRechnungen => 'Factures';

  @override
  String get categoryLohnGehalt => 'Salaires et rémunérations';

  @override
  String get categorySteuern => 'Impôts et fisc';

  @override
  String get categoryVertraege => 'Contrats';

  @override
  String get categoryVersicherungen => 'Assurances';

  @override
  String get categoryBank => 'Banque';

  @override
  String get categoryGesundheit => 'Santé';

  @override
  String get categoryBehoerden => 'Administrations';

  @override
  String get categorySonstiges => 'Divers';

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
      zero: 'Aucun document',
    );
    return '$_temp0';
  }
}
