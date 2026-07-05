// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Papyra';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDone => 'Done';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonClose => 'Close';

  @override
  String get commonShare => 'Share';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get scanButton => 'Scan';

  @override
  String get onbWelcomeTitle => 'Order for your mail';

  @override
  String get onbWelcomeBody =>
      'Scan invoices, contracts and letters – automatically filed and instantly searchable.';

  @override
  String get onbPrivacyTitle => 'Everything stays on your device';

  @override
  String get onbPrivacyBody =>
      'Your documents never leave your device. No cloud, no accounts, no ads, no tracking.';

  @override
  String get onbLockTitle => 'Protect your documents';

  @override
  String get onbLockBody =>
      'Enable the app lock with Face ID or fingerprint. Optional – you can change this anytime in settings.';

  @override
  String get onbEnableLock => 'Enable app lock';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onbLockUnavailable =>
      'No biometric lock is available on this device.';

  @override
  String get lockReason => 'Unlock Papyra to view your documents.';

  @override
  String get lockTitle => 'Papyra is locked';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get scanReviewTitle => 'Review pages';

  @override
  String get scanReorderHint => 'Press and hold to reorder.';

  @override
  String get scanAddPage => 'Add page';

  @override
  String get scanProcessing => 'Processing …';

  @override
  String get scanConfirmTitle => 'Review & save';

  @override
  String get scanLowConfidence => 'Category uncertain – please check.';

  @override
  String get confidenceHigh => 'Recognized confidently';

  @override
  String get confidenceMedium => 'Please check the category';

  @override
  String get confidenceLow => 'Category uncertain';

  @override
  String get altCategoriesLabel => 'Better fit:';

  @override
  String scanSuggested(String category) {
    return 'Suggestion: $category';
  }

  @override
  String get scanSavedMessage => 'Document saved';

  @override
  String get ingestPreparing => 'Preparing files …';

  @override
  String ingestProgress(int current, int total) {
    return 'Document $current of $total';
  }

  @override
  String get ingestDoneTitle => 'Import complete';

  @override
  String ingestDoneSummary(int saved, int skipped) {
    return '$saved saved · $skipped skipped';
  }

  @override
  String get ingestEmpty => 'No supported files found.';

  @override
  String get importAction => 'Import';

  @override
  String get scanErrorTitle => 'Something went wrong';

  @override
  String get scanEmpty => 'No pages scanned yet.';

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
  String get fieldTitle => 'Title';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldSender => 'Sender';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldNoDate => 'No date';

  @override
  String get fieldAddTag => 'Add tag';

  @override
  String get fieldOptional => 'optional';

  @override
  String get fieldGroup => 'Group';

  @override
  String get fieldDueDate => 'Due on';

  @override
  String get navDue => 'Due';

  @override
  String get dueOverdue => 'Overdue';

  @override
  String get dueUpcoming => 'Upcoming';

  @override
  String get duePaidSection => 'Paid';

  @override
  String get dueEmpty => 'No open due dates.';

  @override
  String get dueMarkPaid => 'Mark as paid';

  @override
  String get dueMarkUnpaid => 'Mark as unpaid';

  @override
  String get dueToday => 'Due today';

  @override
  String dueInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'in $_temp0';
  }

  @override
  String dueDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get calendarExport => 'Add to calendar';

  @override
  String calendarSummary(String title) {
    return 'Due: $title';
  }

  @override
  String get calendarError => 'Calendar export failed.';

  @override
  String get setReminders => 'Reminders';

  @override
  String get setReminderEnabled => 'Due-date reminders';

  @override
  String get setReminderEnabledSubtitle =>
      'Remind me about invoice payment deadlines';

  @override
  String setReminderLead(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days before',
      one: '1 day before',
      zero: 'on the due date',
    );
    return 'Lead time: $_temp0';
  }

  @override
  String get setReminderOnDue => 'Also remind on the due date';

  @override
  String get reminderPermissionDenied =>
      'Notifications are disabled. Please allow them in system settings.';

  @override
  String get groupNone => 'None';

  @override
  String get groupAll => 'All';

  @override
  String get groupUngrouped => 'Ungrouped';

  @override
  String get groupNew => 'New group …';

  @override
  String get groupCreateTitle => 'New group';

  @override
  String get groupNameHint => 'e.g. Electricity, Internet/Phone';

  @override
  String get groupAutoFiled => 'Filed automatically';

  @override
  String get groupAdd => 'Add group';

  @override
  String get groupDeleteConfirm =>
      'Delete group? The documents are kept and moved to “Ungrouped”.';

  @override
  String get libCategories => 'Categories';

  @override
  String get libRecentlyAdded => 'Recently added';

  @override
  String get libSeeAll => 'See all';

  @override
  String get libEmptyTitle => 'No documents yet';

  @override
  String get libEmptyBody => 'Tap “Scan” to add your first document.';

  @override
  String get catEmpty => 'No documents in this category.';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortTitle => 'Title (A–Z)';

  @override
  String get sortAmount => 'Amount (descending)';

  @override
  String get filterFavoritesOnly => 'Favorites only';

  @override
  String get detailMetadata => 'Details';

  @override
  String get detailExtractedText => 'Recognized text';

  @override
  String get detailNoText => 'No text recognized.';

  @override
  String detailPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get actionShare => 'Share as PDF';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionMove => 'Move';

  @override
  String get actionTags => 'Tags';

  @override
  String get actionFavorite => 'Add to favorites';

  @override
  String get actionUnfavorite => 'Remove from favorites';

  @override
  String get actionDelete => 'Delete';

  @override
  String get deleteConfirmTitle => 'Delete document?';

  @override
  String get deleteConfirmBody =>
      'The document and all its files will be permanently deleted from your device.';

  @override
  String get moveTitle => 'Choose a category';

  @override
  String get editMetadataTitle => 'Edit metadata';

  @override
  String get shareError => 'Unable to share.';

  @override
  String get searchHint => 'Search documents';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchStart => 'Search titles, senders, tags and recognized text.';

  @override
  String get searchNoResults => 'No results';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get filterAllCategories => 'All categories';

  @override
  String get filterDateRange => 'Date range';

  @override
  String get filterClear => 'Clear filters';

  @override
  String get setSecurity => 'Security';

  @override
  String get setAppLock => 'App lock';

  @override
  String get setAppLockSubtitle => 'Unlock with Face ID or fingerprint on open';

  @override
  String get setAppLockUnavailable => 'Not available on this device';

  @override
  String get setAppearance => 'Appearance';

  @override
  String get setTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get setFiling => 'Recognition & titles';

  @override
  String get setTitleTemplate => 'Title template';

  @override
  String get setTitleTemplateHint => 'Placeholders: sender, docType, date';

  @override
  String get setTitleTemplateReset => 'Restore default';

  @override
  String get setAutoAccept => 'Auto-save confident documents';

  @override
  String get setAutoAcceptSubtitle =>
      'Skip confirmation when confidence is high';

  @override
  String get setData => 'Data';

  @override
  String get setCategories => 'Manage categories';

  @override
  String get setCategoriesSubtitle => 'Add, rename, reorder';

  @override
  String get setBackup => 'Create backup';

  @override
  String get setBackupSubtitle => 'Export everything to a ZIP file';

  @override
  String get setRestore => 'Restore backup';

  @override
  String get setRestoreSubtitle => 'Import from a ZIP file';

  @override
  String get setAbout => 'About & privacy';

  @override
  String get backupCreating => 'Creating backup …';

  @override
  String get backupError => 'Backup failed';

  @override
  String get restoreConfirmTitle => 'Restore?';

  @override
  String get restoreConfirmBody =>
      'All current documents will be replaced by the backup. This cannot be undone.';

  @override
  String get restoring => 'Restoring …';

  @override
  String get restoreDone => 'Restore complete';

  @override
  String get restoreError => 'Restore failed';

  @override
  String get catManageTitle => 'Categories';

  @override
  String get catAdd => 'Add category';

  @override
  String get catNewTitle => 'New category';

  @override
  String get catEditTitle => 'Edit category';

  @override
  String get catName => 'Name';

  @override
  String get catIcon => 'Icon';

  @override
  String get catColor => 'Color';

  @override
  String get catReorderHint => 'Press and hold to reorder.';

  @override
  String get catCannotDelete => 'Only empty, custom categories can be deleted.';

  @override
  String get privacyHeadline => 'Your documents never leave your device.';

  @override
  String get privacyBody =>
      'Papyra is 100% offline. There is no server, no account and no cloud. Your scans, the recognized text and all metadata are stored only locally on your device.\n\nWe collect no data, use no analytics or tracking, and show no ads. The app requests no internet permission — technically your documents cannot leave your device.\n\nText recognition (OCR) and automatic filing run entirely on your device. For a backup you can export your data yourself as a ZIP file; where it is saved is entirely up to you.\n\nDue-date reminders are scheduled entirely locally on your device (notifications). No data is transmitted.';

  @override
  String privacyVersion(String version) {
    return 'Version $version';
  }

  @override
  String get categoryRechnungen => 'Invoices';

  @override
  String get categoryLohnGehalt => 'Salary & Wages';

  @override
  String get categorySteuern => 'Taxes';

  @override
  String get categoryVertraege => 'Contracts';

  @override
  String get categoryVersicherungen => 'Insurance';

  @override
  String get categoryBank => 'Bank';

  @override
  String get categoryGesundheit => 'Health';

  @override
  String get categoryBehoerden => 'Authorities';

  @override
  String get categorySonstiges => 'Other';

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
      zero: 'No documents',
    );
    return '$_temp0';
  }
}
