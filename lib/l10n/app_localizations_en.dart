// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutFlauncher => 'About GoodTV Launcher';

  @override
  String get addCategory => 'Add category';

  @override
  String get addSection => 'Add section';

  @override
  String get alphabetical => 'Alphabetical';

  @override
  String get appCardHighlightAnimation => 'App card highlight animation';

  @override
  String get showFocusBorders => 'Show focus borders';

  @override
  String get appInfo => 'Application info';

  @override
  String get appKeyClick => 'Click sound on key press';

  @override
  String get appCardStyle => 'App card style';

  @override
  String get appCardCorners => 'Card corners';

  @override
  String get appCardCornersSquare => 'Square';

  @override
  String get appCardCornersSoft => 'Soft';

  @override
  String get appCardCornersRounded => 'Rounded';

  @override
  String get appCardFocusZoom => 'Focus zoom';

  @override
  String get appCardFocusZoomNone => 'None';

  @override
  String get appCardFocusZoomStandard => 'Standard';

  @override
  String get appCardFocusZoomStrong => 'Strong';

  @override
  String get appCardSpacing => 'Card spacing';

  @override
  String get appCardSpacingTight => 'Tight';

  @override
  String get appCardSpacingBalanced => 'Balanced';

  @override
  String get appCardSpacingRoomy => 'Roomy';

  @override
  String get appearanceSettings => 'Appearance';

  @override
  String get backgroundBlur => 'Background blur';

  @override
  String get dockBlur => 'Dock blur';

  @override
  String get dockDarkBackground => 'Dark dock background';

  @override
  String get dockShadow => 'Dock shadow';

  @override
  String get displayProfiles => 'Display profiles';

  @override
  String get displayProfilesDescription =>
      'Profiles change several appearance settings together. You can still fine-tune every setting afterward.';

  @override
  String get displayProfileCinema => 'Cinema';

  @override
  String get displayProfileCinemaDescription =>
      'A clean, immersive layout with Watch Next and rich visual effects.';

  @override
  String get displayProfileCompact => 'Compact';

  @override
  String get displayProfileCompactDescription =>
      'A fast, information-dense layout with fewer visual effects.';

  @override
  String get displayProfileEasyRead => 'Easy Read';

  @override
  String get displayProfileEasyReadDescription =>
      'Always-visible labels, status details, and strong focus feedback.';

  @override
  String displayProfileApplied(String profile) {
    return '$profile profile applied';
  }

  @override
  String get applications => 'Applications';

  @override
  String get autoHideAppBar => 'Automatically hide status bar';

  @override
  String get backButtonAction => 'Back button action';

  @override
  String get category => 'Category';

  @override
  String get categories => 'Categories';

  @override
  String get columnCount => 'Column count';

  @override
  String get configureThisTv => 'Configure this TV';

  @override
  String get pinProtection => 'PIN protection';

  @override
  String get pinProtectionDescription =>
      'Require a 4-8 digit PIN before opening launcher settings. If you forget it, clearing the app\'s data resets the PIN and launcher configuration.';

  @override
  String get createPin => 'Create settings PIN';

  @override
  String get changePin => 'Change settings PIN';

  @override
  String get disablePin => 'Disable PIN protection';

  @override
  String get enterNewPin => 'Enter a new 4-8 digit PIN';

  @override
  String get confirmPin => 'Confirm the new PIN';

  @override
  String get enterCurrentPin => 'Enter the current PIN';

  @override
  String get enterPin => 'PIN';

  @override
  String get pinLengthError => 'Use 4-8 digits';

  @override
  String get pinsDoNotMatch => 'The PINs do not match';

  @override
  String get pinEnabled => 'Settings PIN enabled';

  @override
  String get pinDisabled => 'Settings PIN disabled';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get settingsLocked => 'Settings are locked';

  @override
  String get unlockSettings => 'Unlock settings';

  @override
  String get applyRecommendedSetup => 'Apply recommended setup';

  @override
  String get goodTvIsDefaultLauncher => 'GoodTV is the default launcher';

  @override
  String get chooseDefaultLauncher => 'Choose GoodTV as the Home app';

  @override
  String get unknownDevice => 'Unknown TV device';

  @override
  String androidVersionDetected(String version) {
    return 'Android $version';
  }

  @override
  String recommendedSetupApplied(String profile) {
    return '$profile settings applied';
  }

  @override
  String get systemSetupLimitations =>
      'GoodTV can detect your TV and apply safe launcher settings automatically. Android requires you to approve the default Home app in the system screen. Other launchers cannot be disabled silently without device-owner, ADB, or root access.';

  @override
  String get date => 'Date';

  @override
  String get dateAndTimeFormat => 'Date and time format';

  @override
  String get delete => 'Delete';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Do nothing';

  @override
  String get dialogOptionBackButtonActionShowScreensaver => 'Show screensaver';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Show clock';

  @override
  String get dialogTextNoFileExplorer =>
      'Please install a file explorer in order to pick a picture.';

  @override
  String get dialogTitleBackButtonAction => 'Choose the back button action';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Category)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Formatted date: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Formatted time: $timeString';
  }

  @override
  String get gradient => 'Gradient';

  @override
  String get favoriteApps => 'Favorite Apps';

  @override
  String get grid => 'Grid';

  @override
  String get height => 'Height';

  @override
  String get hide => 'Hide';

  @override
  String get hiddenApplications => 'Hidden Apps';

  @override
  String get launcherSections => 'Sections';

  @override
  String get layout => 'Layout';

  @override
  String get loading => 'Loading';

  @override
  String get manual => 'Manual';

  @override
  String get modifySection => 'Modify section';

  @override
  String get mustNotBeEmpty => 'Must not be empty';

  @override
  String get name => 'Name';

  @override
  String get newSection => 'New section';

  @override
  String get noDateFormatSpecified => 'No date format specified';

  @override
  String get noTimeFormatSpecified => 'No time format specified';

  @override
  String get allApplications => 'All Apps';

  @override
  String get nonTvApplications => 'Non-TV Apps';

  @override
  String get open => 'Open';

  @override
  String get orSelectFormatSpecifiers => 'Or select format specifiers';

  @override
  String get picture => 'Picture';

  @override
  String removeFrom(String name) {
    return 'Remove from $name';
  }

  @override
  String get renameCategory => 'Rename category';

  @override
  String get reorder => 'Reorder';

  @override
  String get row => 'Row';

  @override
  String get rowHeight => 'Row height';

  @override
  String get save => 'Save';

  @override
  String get spacer => 'Spacer';

  @override
  String get spacerMaxHeightRequirement =>
      'Must be greater than 0 and less than or equal to 500';

  @override
  String get statusBar => 'Status bar';

  @override
  String get settings => 'Settings';

  @override
  String get show => 'Show';

  @override
  String get showCategoryTitles => 'Show category titles';

  @override
  String get sort => 'Sort';

  @override
  String get systemSettings => 'System settings';

  @override
  String get updateCheck => 'Check for updates';

  @override
  String get updateNoUpdateTitle => 'No updates available';

  @override
  String updateNoUpdateBody(String currentVersion) {
    return 'You are already on the latest version ($currentVersion).';
  }

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String latestVersion, String currentVersion) {
    return 'Version $latestVersion is available (current: $currentVersion).';
  }

  @override
  String get updateDownloadButton => 'Download';

  @override
  String get updateReadyToInstallTitle => 'Ready to install';

  @override
  String updateReadyToInstallBody(String latestVersion) {
    return 'The APK for version $latestVersion is downloaded. Start installation now?';
  }

  @override
  String get updateInstallButton => 'Install';

  @override
  String get updateInstallPermissionTitle => 'Installer permission required';

  @override
  String get updateInstallPermissionBody =>
      'Allow GoodTV Launcher to install unknown apps, then retry the update.';

  @override
  String get updateOpenPermissionSettingsButton => 'Open permission settings';

  @override
  String get updateErrorGeneric => 'Update check failed. Please try again.';

  @override
  String textAboutDialog(String repoUrl) {
    return 'GoodTV Launcher is a free, open-source launcher for Android TV, Google TV, and Fire TV. It is developed by Good Tools.\n\nOpen-source information: $repoUrl';
  }

  @override
  String get textEmptyCategory => 'This category is empty.';

  @override
  String get time => 'Time';

  @override
  String get titleStatusBarSettingsPage =>
      'Choose what to display in the status bar';

  @override
  String get tvApplications => 'TV Apps';

  @override
  String get type => 'Type';

  @override
  String get typeInTheDateFormat => 'Type in the date format';

  @override
  String get typeInTheHourFormat => 'Type in the hour format';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get wallpaper => 'Wallpaper';

  @override
  String get withEllipsisAddTo => 'Add to...';

  @override
  String get timeBasedWallpaper => 'Time based wallpaper';

  @override
  String get pickDayWallpaper => 'Pick day wallpaper';

  @override
  String get pickNightWallpaper => 'Pick night wallpaper';

  @override
  String get video => 'Video';

  @override
  String get pickDayVideoWallpaper => 'Pick day video';

  @override
  String get pickNightVideoWallpaper => 'Pick night video';

  @override
  String get watchNextSectionTitle => 'Watch Next';

  @override
  String get showWatchNextSection => 'Show Watch Next Section';

  @override
  String get watchNextPermissionTitle => 'Watch Next permission required';

  @override
  String get watchNextPermissionBody =>
      'Allow access to TV listings to show your continue watching items.';

  @override
  String get watchNextGrantPermission => 'Grant permission';

  @override
  String get watchNextCheckPermission => 'Check again';

  @override
  String get interface => 'Interface';

  @override
  String get system => 'System';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get miscellaneous => 'Miscellaneous';

  @override
  String get brightnessScheduler => 'Brightness Scheduler';

  @override
  String get screensaverSettings => 'Screensaver Settings';

  @override
  String get screensaverClockStyle => 'Screensaver Clock Style';

  @override
  String get wifiUsagePeriod => 'WiFi Usage Period';

  @override
  String get showAppNamesBelowIcons => 'Show App Names Below Icons';

  @override
  String get wifiUsage => 'WiFi Usage';

  @override
  String get networkIndicator => 'Network Indicator';

  @override
  String get customName => 'Custom Name';

  @override
  String get lastUsed => 'Last Used';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get checkStatus => 'Check Status';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get createBackup => 'Create backup now';

  @override
  String get restoreLatestBackup => 'Restore latest backup';

  @override
  String get noBackups => 'No backups yet';

  @override
  String get backupDescription =>
      'Backups include your layout, categories, favourites, hidden apps, settings, custom banners, and image or video wallpapers. The five newest backups are kept on this device.';

  @override
  String get backupCreated => 'Backup created';

  @override
  String get backupFailed => 'Could not create the backup';

  @override
  String get restoreBackupTitle => 'Restore launcher backup?';

  @override
  String get restoreBackupWarning =>
      'This replaces the current layout, settings, banners, and wallpapers with the latest backup.';

  @override
  String get restore => 'Restore';

  @override
  String get cancel => 'Cancel';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get restoreFailed => 'Could not restore the backup';

  @override
  String get onlineAerialBackgrounds => 'Online & aerial backgrounds';

  @override
  String get onlineWallpaper => 'Online backgrounds';

  @override
  String get onlineWallpaperDescription =>
      'Connect a direct image or video URL, an M3U playlist, or an Overflight-style JSON feed. GoodTV rotates multi-item feeds automatically.';

  @override
  String get wallpaperFeedUrl => 'Background feed URL';

  @override
  String get changeBackgroundEvery => 'Change background every';

  @override
  String get connectWallpaperFeed => 'Connect background feed';

  @override
  String get nextWallpaper => 'Next background';

  @override
  String get disableOnlineWallpaper => 'Turn off online backgrounds';

  @override
  String get wallpaperFeedConnected => 'Background feed connected';

  @override
  String get wallpaperFeedError => 'Could not load that background feed';
}
