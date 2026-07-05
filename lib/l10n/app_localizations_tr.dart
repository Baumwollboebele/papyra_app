// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Papyra';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonDone => 'Bitti';

  @override
  String get commonNext => 'İleri';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonSkip => 'Atla';

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonShare => 'Paylaş';

  @override
  String get commonSearch => 'Ara';

  @override
  String get commonSettings => 'Ayarlar';

  @override
  String get commonYes => 'Evet';

  @override
  String get commonNo => 'Hayır';

  @override
  String get commonOpenSettings => 'Ayarları aç';

  @override
  String get navLibrary => 'Arşiv';

  @override
  String get navSearch => 'Arama';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get scanButton => 'Tara';

  @override
  String get onbWelcomeTitle => 'Postanız için düzen';

  @override
  String get onbWelcomeBody =>
      'Faturaları, sözleşmeleri ve mektupları tarayın – otomatik olarak dosyalanır ve anında aranabilir.';

  @override
  String get onbPrivacyTitle => 'Her şey cihazınızda kalır';

  @override
  String get onbPrivacyBody =>
      'Belgeleriniz cihazınızdan asla çıkmaz. Bulut yok, hesap yok, reklam yok, takip yok.';

  @override
  String get onbLockTitle => 'Belgelerinizi koruyun';

  @override
  String get onbLockBody =>
      'Uygulama kilidini Face ID veya parmak iziyle etkinleştirin. İsteğe bağlı – bunu istediğiniz zaman ayarlardan değiştirebilirsiniz.';

  @override
  String get onbEnableLock => 'Uygulama kilidini etkinleştir';

  @override
  String get onbGetStarted => 'Başlayalım';

  @override
  String get onbLockUnavailable =>
      'Bu cihazda biyometrik kilit kullanılamıyor.';

  @override
  String get lockReason => 'Belgelerinizi görmek için Papyra kilidini açın.';

  @override
  String get lockTitle => 'Papyra kilitli';

  @override
  String get lockUnlock => 'Kilidi aç';

  @override
  String get scanReviewTitle => 'Sayfaları gözden geçir';

  @override
  String get scanReorderHint =>
      'Yeniden sıralamak için basılı tutup sürükleyin.';

  @override
  String get scanAddPage => 'Sayfa ekle';

  @override
  String get scanProcessing => 'İşleniyor …';

  @override
  String get scanConfirmTitle => 'Gözden geçir ve kaydet';

  @override
  String get scanLowConfidence => 'Kategori belirsiz – lütfen kontrol edin.';

  @override
  String get confidenceHigh => 'Güvenle tanındı';

  @override
  String get confidenceMedium => 'Lütfen kategoriyi kontrol edin';

  @override
  String get confidenceLow => 'Kategori belirsiz';

  @override
  String get altCategoriesLabel => 'Daha uygun:';

  @override
  String scanSuggested(String category) {
    return 'Öneri: $category';
  }

  @override
  String get scanSavedMessage => 'Belge kaydedildi';

  @override
  String get ingestPreparing => 'Dosyalar hazırlanıyor …';

  @override
  String ingestProgress(int current, int total) {
    return 'Belge $current / $total';
  }

  @override
  String get ingestDoneTitle => 'İçe aktarma tamamlandı';

  @override
  String ingestDoneSummary(int saved, int skipped) {
    return '$saved kaydedildi · $skipped atlandı';
  }

  @override
  String get ingestEmpty => 'Desteklenen dosya bulunamadı.';

  @override
  String get importAction => 'İçe aktar';

  @override
  String get scanErrorTitle => 'Bir şeyler ters gitti';

  @override
  String get scanEmpty => 'Henüz taranmış sayfa yok.';

  @override
  String scanPagesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sayfa',
      one: '1 sayfa',
    );
    return '$_temp0';
  }

  @override
  String get fieldTitle => 'Başlık';

  @override
  String get fieldCategory => 'Kategori';

  @override
  String get fieldSender => 'Gönderen';

  @override
  String get fieldDate => 'Tarih';

  @override
  String get fieldAmount => 'Tutar';

  @override
  String get fieldTags => 'Etiketler';

  @override
  String get fieldNoDate => 'Tarih yok';

  @override
  String get fieldAddTag => 'Etiket ekle';

  @override
  String get fieldOptional => 'isteğe bağlı';

  @override
  String get fieldGroup => 'Grup';

  @override
  String get fieldDueDate => 'Son ödeme tarihi';

  @override
  String get navDue => 'Vadeler';

  @override
  String get dueOverdue => 'Gecikmiş';

  @override
  String get dueUpcoming => 'Yaklaşan';

  @override
  String get duePaidSection => 'Ödendi';

  @override
  String get dueEmpty => 'Bekleyen vade yok.';

  @override
  String get dueMarkPaid => 'Ödendi olarak işaretle';

  @override
  String get dueMarkUnpaid => 'Ödenmedi olarak işaretle';

  @override
  String get dueToday => 'Bugün vadesi doluyor';

  @override
  String dueInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün',
      one: '1 gün',
    );
    return '$_temp0 içinde';
  }

  @override
  String dueDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün',
      one: '1 gün',
    );
    return '$_temp0 önce';
  }

  @override
  String get calendarExport => 'Takvime ekle';

  @override
  String calendarSummary(String title) {
    return 'Vade: $title';
  }

  @override
  String get calendarError => 'Takvime aktarma başarısız.';

  @override
  String get setReminders => 'Hatırlatıcılar';

  @override
  String get setReminderEnabled => 'Vade hatırlatıcıları';

  @override
  String get setReminderEnabledSubtitle =>
      'Faturalarda ödeme süresini hatırlat';

  @override
  String setReminderLead(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün önce',
      one: '1 gün önce',
      zero: 'vade günü',
    );
    return 'Ön süre: $_temp0';
  }

  @override
  String get setReminderOnDue => 'Vade gününde de hatırlat';

  @override
  String get reminderPermissionDenied =>
      'Bildirimler kapalı. Lütfen sistem ayarlarından izin verin.';

  @override
  String get groupNone => 'Yok';

  @override
  String get groupAll => 'Tümü';

  @override
  String get groupUngrouped => 'Grupsuz';

  @override
  String get groupNew => 'Yeni grup …';

  @override
  String get groupCreateTitle => 'Yeni grup';

  @override
  String get groupNameHint => 'ör. Elektrik, İnternet/Telefon';

  @override
  String get groupAutoFiled => 'Otomatik dosyalandı';

  @override
  String get groupAdd => 'Grup ekle';

  @override
  String get groupDeleteConfirm =>
      'Grup silinsin mi? Belgeler korunur ve «Grupsuz» bölümüne taşınır.';

  @override
  String get libCategories => 'Kategoriler';

  @override
  String get libRecentlyAdded => 'Son eklenenler';

  @override
  String get libSeeAll => 'Tümünü gör';

  @override
  String get libEmptyTitle => 'Henüz belge yok';

  @override
  String get libEmptyBody => 'İlk belgenizi eklemek için «Tara»ya dokunun.';

  @override
  String get catEmpty => 'Bu kategoride belge yok.';

  @override
  String get sortLabel => 'Sırala';

  @override
  String get sortNewest => 'Önce en yeni';

  @override
  String get sortOldest => 'Önce en eski';

  @override
  String get sortTitle => 'Başlık (A–Z)';

  @override
  String get sortAmount => 'Tutar (azalan)';

  @override
  String get filterFavoritesOnly => 'Yalnızca favoriler';

  @override
  String get detailMetadata => 'Ayrıntılar';

  @override
  String get detailExtractedText => 'Tanınan metin';

  @override
  String get detailNoText => 'Metin tanınmadı.';

  @override
  String detailPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get actionShare => 'PDF olarak paylaş';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionMove => 'Taşı';

  @override
  String get actionTags => 'Etiketler';

  @override
  String get actionFavorite => 'Favorilere ekle';

  @override
  String get actionUnfavorite => 'Favorilerden çıkar';

  @override
  String get actionDelete => 'Sil';

  @override
  String get deleteConfirmTitle => 'Belge silinsin mi?';

  @override
  String get deleteConfirmBody =>
      'Belge ve ilişkili tüm dosyalar cihazınızdan kalıcı olarak silinecek.';

  @override
  String get moveTitle => 'Kategori seç';

  @override
  String get editMetadataTitle => 'Meta verileri düzenle';

  @override
  String get shareError => 'Paylaşma başarısız.';

  @override
  String get searchHint => 'Belgelerde ara';

  @override
  String get searchRecent => 'Son aramalar';

  @override
  String get searchStart =>
      'Başlıklarda, gönderenlerde, etiketlerde ve tanınan metinde arayın.';

  @override
  String get searchNoResults => 'Sonuç yok';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sonuç',
      one: '1 sonuç',
    );
    return '$_temp0';
  }

  @override
  String get filterAllCategories => 'Tüm kategoriler';

  @override
  String get filterDateRange => 'Tarih aralığı';

  @override
  String get filterClear => 'Filtreleri temizle';

  @override
  String get setSecurity => 'Güvenlik';

  @override
  String get setAppLock => 'Uygulama kilidi';

  @override
  String get setAppLockSubtitle =>
      'Açılışta Face ID veya parmak iziyle kilidi aç';

  @override
  String get setAppLockUnavailable => 'Bu cihazda kullanılamıyor';

  @override
  String get setAppearance => 'Görünüm';

  @override
  String get setTheme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get setFiling => 'Tanıma ve başlıklar';

  @override
  String get setTitleTemplate => 'Başlık şablonu';

  @override
  String get setTitleTemplateHint => 'Yer tutucular: sender, docType, date';

  @override
  String get setTitleTemplateReset => 'Varsayılana döndür';

  @override
  String get setAutoAccept => 'Güvenilir belgeleri otomatik kaydet';

  @override
  String get setAutoAcceptSubtitle => 'Yüksek kesinlikte onayı atla';

  @override
  String get setData => 'Veriler';

  @override
  String get setCategories => 'Kategorileri yönet';

  @override
  String get setCategoriesSubtitle => 'Ekle, yeniden adlandır, sırala';

  @override
  String get setBackup => 'Yedek oluştur';

  @override
  String get setBackupSubtitle => 'Her şeyi bir ZIP dosyasına aktar';

  @override
  String get setRestore => 'Yedeği geri yükle';

  @override
  String get setRestoreSubtitle => 'Bir ZIP dosyasından içe aktar';

  @override
  String get setAbout => 'Hakkında ve gizlilik';

  @override
  String get backupCreating => 'Yedek oluşturuluyor …';

  @override
  String get backupError => 'Yedekleme başarısız';

  @override
  String get restoreConfirmTitle => 'Geri yüklensin mi?';

  @override
  String get restoreConfirmBody =>
      'Mevcut tüm belgeler yedekle değiştirilecek. Bu işlem geri alınamaz.';

  @override
  String get restoring => 'Geri yükleniyor …';

  @override
  String get restoreDone => 'Geri yükleme tamamlandı';

  @override
  String get restoreError => 'Geri yükleme başarısız';

  @override
  String get catManageTitle => 'Kategoriler';

  @override
  String get catAdd => 'Kategori ekle';

  @override
  String get catNewTitle => 'Yeni kategori';

  @override
  String get catEditTitle => 'Kategoriyi düzenle';

  @override
  String get catName => 'Ad';

  @override
  String get catIcon => 'Simge';

  @override
  String get catColor => 'Renk';

  @override
  String get catReorderHint =>
      'Yeniden sıralamak için basılı tutup sürükleyin.';

  @override
  String get catCannotDelete =>
      'Yalnızca kendi oluşturduğunuz boş kategoriler silinebilir.';

  @override
  String get privacyHeadline => 'Belgeleriniz cihazınızdan asla çıkmaz.';

  @override
  String get privacyBody =>
      'Papyra %100 çevrimdışıdır. Hiçbir sunucu, kullanıcı hesabı veya bulut yoktur. Taramalarınız, tanınan metin ve tüm meta veriler yalnızca cihazınızda yerel olarak saklanır.\n\nHiçbir veri toplamıyor, analiz veya takip hizmeti kullanmıyor ve reklam göstermiyoruz. Uygulama internet izni istemez – teknik olarak belgeleriniz cihazınızdan çıkamaz bile.\n\nMetin tanıma (OCR) ve otomatik dosyalama tamamen cihazınızda gerçekleşir. Yedekleme için verilerinizi kendiniz şifrelenebilir bir ZIP dosyası olarak dışa aktarabilirsiniz; nereye kaydedileceğine yalnızca siz karar verirsiniz.\n\nVade hatırlatıcıları yalnızca cihazınızda yerel olarak planlanır (bildirimler). Bu sırada hiçbir veri aktarılmaz.';

  @override
  String privacyVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get categoryRechnungen => 'Faturalar';

  @override
  String get categoryLohnGehalt => 'Maaş ve ücret';

  @override
  String get categorySteuern => 'Vergi ve maliye';

  @override
  String get categoryVertraege => 'Sözleşmeler';

  @override
  String get categoryVersicherungen => 'Sigortalar';

  @override
  String get categoryBank => 'Banka';

  @override
  String get categoryGesundheit => 'Sağlık';

  @override
  String get categoryBehoerden => 'Resmî kurumlar';

  @override
  String get categorySonstiges => 'Diğer';

  @override
  String documentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count belge',
      one: '1 belge',
      zero: 'Belge yok',
    );
    return '$_temp0';
  }
}
