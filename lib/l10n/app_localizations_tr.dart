// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get aboutFlauncher => 'GoodTV Launcher Hakkında';

  @override
  String get addCategory => 'Kategori ekle';

  @override
  String get addSection => 'Bölüm ekle';

  @override
  String get alphabetical => 'Alfabetik';

  @override
  String get appCardHighlightAnimation => 'Uygulama kartı vurgulama animasyonu';

  @override
  String get showFocusBorders => 'Odak kenarlıklarını göster';

  @override
  String get appInfo => 'Uygulama bilgisi';

  @override
  String get appKeyClick => 'Tuşa basıldığında tıklama sesi';

  @override
  String get appearanceSettings => 'Görünüm';

  @override
  String get backgroundBlur => 'Arka plan bulanıklığı';

  @override
  String get dockBlur => 'Dock bulanıklığı';

  @override
  String get dockDarkBackground => 'Koyu dock arka planı';

  @override
  String get dockShadow => 'Dock gölgesi';

  @override
  String get applications => 'Uygulamalar';

  @override
  String get autoHideAppBar => 'Durum çubuğunu otomatik gizle';

  @override
  String get backButtonAction => 'Geri tuşu eylemi';

  @override
  String get category => 'Kategori';

  @override
  String get categories => 'Kategoriler';

  @override
  String get columnCount => 'Sütun sayısı';

  @override
  String get date => 'Tarih';

  @override
  String get dateAndTimeFormat => 'Tarih ve saat biçimi';

  @override
  String get delete => 'Sil';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Hiçbir şey yapma';

  @override
  String get dialogOptionBackButtonActionShowScreensaver =>
      'Ekran koruyucuyu göster';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Saati göster';

  @override
  String get dialogTextNoFileExplorer =>
      'Resim seçebilmek için lütfen bir dosya yöneticisi yükleyin.';

  @override
  String get dialogTitleBackButtonAction => 'Geri tuşu eylemini seçin';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Kategori)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Biçimlendirilmiş tarih: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Biçimlendirilmiş saat: $timeString';
  }

  @override
  String get gradient => 'Gradyan';

  @override
  String get favoriteApps => 'Favori Uygulamalar';

  @override
  String get grid => 'Izgara';

  @override
  String get height => 'Yükseklik';

  @override
  String get hide => 'Gizle';

  @override
  String get hiddenApplications => 'Gizli Uygulamalar';

  @override
  String get launcherSections => 'Bölümler';

  @override
  String get layout => 'Düzen';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get manual => 'Manuel';

  @override
  String get modifySection => 'Bölümü düzenle';

  @override
  String get mustNotBeEmpty => 'Boş olmamalıdır';

  @override
  String get name => 'Ad';

  @override
  String get newSection => 'Yeni bölüm';

  @override
  String get noDateFormatSpecified => 'Tarih biçimi belirtilmedi';

  @override
  String get noTimeFormatSpecified => 'Saat biçimi belirtilmedi';

  @override
  String get allApplications => 'Tüm Uygulamalar';

  @override
  String get nonTvApplications => 'TV Olmayan Uygulamalar';

  @override
  String get open => 'Aç';

  @override
  String get orSelectFormatSpecifiers => 'Veya biçim belirteçlerini seçin';

  @override
  String get picture => 'Resim';

  @override
  String removeFrom(String name) {
    return '$name içinden kaldır';
  }

  @override
  String get renameCategory => 'Kategoriyi yeniden adlandır';

  @override
  String get reorder => 'Yeniden sırala';

  @override
  String get row => 'Satır';

  @override
  String get rowHeight => 'Satır yüksekliği';

  @override
  String get save => 'Kaydet';

  @override
  String get spacer => 'Boşluk';

  @override
  String get spacerMaxHeightRequirement =>
      '0\'dan büyük ve 500\'e eşit veya küçük olmalıdır';

  @override
  String get statusBar => 'Durum çubuğu';

  @override
  String get settings => 'Ayarlar';

  @override
  String get show => 'Göster';

  @override
  String get showCategoryTitles => 'Kategori başlıklarını göster';

  @override
  String get sort => 'Sırala';

  @override
  String get systemSettings => 'Sistem ayarları';

  @override
  String get updateCheck => 'Güncellemeleri denetle';

  @override
  String get updateNoUpdateTitle => 'Güncelleme yok';

  @override
  String updateNoUpdateBody(String currentVersion) {
    return 'Zaten en son sürümü ($currentVersion) kullanıyorsunuz.';
  }

  @override
  String get updateAvailableTitle => 'Güncelleme mevcut';

  @override
  String updateAvailableBody(String latestVersion, String currentVersion) {
    return '$latestVersion sürümü mevcut (geçerli: $currentVersion).';
  }

  @override
  String get updateDownloadButton => 'İndir';

  @override
  String get updateReadyToInstallTitle => 'Yüklemeye hazır';

  @override
  String updateReadyToInstallBody(String latestVersion) {
    return '$latestVersion sürümünün APK\'si indirildi. Yükleme şimdi başlatılsın mı?';
  }

  @override
  String get updateInstallButton => 'Yükle';

  @override
  String get updateInstallPermissionTitle => 'Yükleyici izni gerekli';

  @override
  String get updateInstallPermissionBody =>
      'GoodTV Launcher\'ın bilinmeyen uygulamaları yüklemesine izin verin, ardından güncellemeyi yeniden deneyin.';

  @override
  String get updateOpenPermissionSettingsButton => 'İzin ayarlarını aç';

  @override
  String get updateErrorGeneric =>
      'Güncelleme denetimi başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String textAboutDialog(String repoUrl) {
    return 'GoodTV Launcher; Android TV, Google TV ve Fire TV için ücretsiz, açık kaynaklı bir başlatıcıdır. Good Tools tarafından Arc Launcher, LTvLauncher ve FLauncher temel alınarak geliştirilmiştir.\n\nÖzgün kaynak kodu: $repoUrl';
  }

  @override
  String get textEmptyCategory => 'Bu kategori boş.';

  @override
  String get time => 'Saat';

  @override
  String get titleStatusBarSettingsPage =>
      'Durum çubuğunda gösterilecekleri seçin';

  @override
  String get tvApplications => 'TV Uygulamaları';

  @override
  String get type => 'Tür';

  @override
  String get typeInTheDateFormat => 'Tarih biçimini yazın';

  @override
  String get typeInTheHourFormat => 'Saat biçimini yazın';

  @override
  String get uninstall => 'Kaldır';

  @override
  String get wallpaper => 'Duvar kağıdı';

  @override
  String get withEllipsisAddTo => 'Şuna ekle...';

  @override
  String get timeBasedWallpaper => 'Zamana dayalı duvar kağıdı';

  @override
  String get pickDayWallpaper => 'Gündüz duvar kağıdını seç';

  @override
  String get pickNightWallpaper => 'Gece duvar kağıdını seç';

  @override
  String get video => 'Video';

  @override
  String get pickDayVideoWallpaper => 'Gündüz videosunu seç';

  @override
  String get pickNightVideoWallpaper => 'Gece videosunu seç';

  @override
  String get watchNextSectionTitle => 'Sıradaki İzlenecek';

  @override
  String get showWatchNextSection => 'Sıradaki İzlenecek Bölümünü Göster';

  @override
  String get watchNextPermissionTitle => 'Sıradaki İzlenecek izni gerekli';

  @override
  String get watchNextPermissionBody =>
      'İzlemeye devam et öğelerinizi göstermek için TV listelerine erişime izin verin.';

  @override
  String get watchNextGrantPermission => 'İzin ver';

  @override
  String get watchNextCheckPermission => 'Tekrar denetle';

  @override
  String get interface => 'Arayüz';

  @override
  String get system => 'Sistem';

  @override
  String get accentColor => 'Vurgu rengi';

  @override
  String get miscellaneous => 'Çeşitli';

  @override
  String get brightnessScheduler => 'Parlaklık zamanlayıcı';

  @override
  String get screensaverSettings => 'Ekran koruyucu ayarları';

  @override
  String get screensaverClockStyle => 'Ekran koruyucu saat stili';

  @override
  String get wifiUsagePeriod => 'Wi-Fi kullanım dönemi';

  @override
  String get showAppNamesBelowIcons => 'Simge altında uygulama adlarını göster';

  @override
  String get wifiUsage => 'Wi-Fi kullanımı';

  @override
  String get networkIndicator => 'Ağ göstergesi';

  @override
  String get customName => 'Özel ad';

  @override
  String get lastUsed => 'Son kullanım';

  @override
  String get daily => 'Günlük';

  @override
  String get weekly => 'Haftalık';

  @override
  String get monthly => 'Aylık';

  @override
  String get grantPermission => 'İzin ver';

  @override
  String get checkStatus => 'Durumu denetle';

  @override
  String get backupAndRestore => 'Yedekleme ve Geri Yükleme';

  @override
  String get createBackup => 'Şimdi yedekle';

  @override
  String get restoreLatestBackup => 'Son yedeği geri yükle';

  @override
  String get noBackups => 'Henüz yedek yok';

  @override
  String get backupDescription =>
      'Yedekler düzeninizi, kategorilerinizi, favorilerinizi, gizli uygulamalarınızı, ayarlarınızı, özel afişlerinizi ve resim veya video duvar kağıtlarınızı içerir. En yeni beş yedek bu cihazda tutulur.';

  @override
  String get backupCreated => 'Yedek oluşturuldu';

  @override
  String get backupFailed => 'Yedek oluşturulamadı';

  @override
  String get restoreBackupTitle => 'Başlatıcı yedeği geri yüklensin mi?';

  @override
  String get restoreBackupWarning =>
      'Bu işlem mevcut düzeni, ayarları, afişleri ve duvar kağıtlarını son yedekle değiştirir.';

  @override
  String get restore => 'Geri yükle';

  @override
  String get cancel => 'İptal';

  @override
  String get backupRestored => 'Yedek geri yüklendi';

  @override
  String get restoreFailed => 'Yedek geri yüklenemedi';
}
