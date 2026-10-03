// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutFlauncher => 'Acerca de FLauncher';

  @override
  String get addCategory => 'Agregar categoría';

  @override
  String get addSection => 'Agregar sección';

  @override
  String get alphabetical => 'Alfabético';

  @override
  String get appCardHighlightAnimation => 'Resaltar aplicaciones';

  @override
  String get showFocusBorders => 'Mostrar bordes de enfoque';

  @override
  String get appInfo => 'Datos de la aplicación';

  @override
  String get appKeyClick => 'Sonido al presionar una tecla';

  @override
  String get appCardStyle => 'Estilo de tarjetas';

  @override
  String get appCardCorners => 'Esquinas de tarjetas';

  @override
  String get appCardCornersSquare => 'Cuadradas';

  @override
  String get appCardCornersSoft => 'Suaves';

  @override
  String get appCardCornersRounded => 'Redondeadas';

  @override
  String get appCardFocusZoom => 'Zoom de enfoque';

  @override
  String get appCardFocusZoomNone => 'Ninguno';

  @override
  String get appCardFocusZoomStandard => 'Estándar';

  @override
  String get appCardFocusZoomStrong => 'Fuerte';

  @override
  String get appCardSpacing => 'Espacio entre tarjetas';

  @override
  String get appCardSpacingTight => 'Estrecho';

  @override
  String get appCardSpacingBalanced => 'Equilibrado';

  @override
  String get appCardSpacingRoomy => 'Amplio';

  @override
  String get appearanceSettings => 'Apariencia';

  @override
  String get backgroundBlur => 'Desenfoque de fondo';

  @override
  String get dockBlur => 'Desenfoque del dock';

  @override
  String get dockDarkBackground => 'Fondo oscuro del dock';

  @override
  String get dockShadow => 'Sombra del dock';

  @override
  String get displayProfiles => 'Perfiles de pantalla';

  @override
  String get displayProfilesDescription =>
      'Los perfiles cambian varios ajustes de apariencia a la vez. Después puedes ajustar cada opción.';

  @override
  String get displayProfileCinema => 'Cine';

  @override
  String get displayProfileCinemaDescription =>
      'Un diseño limpio e inmersivo con Ver a continuación y efectos visuales.';

  @override
  String get displayProfileCompact => 'Compacto';

  @override
  String get displayProfileCompactDescription =>
      'Un diseño rápido y denso con menos efectos visuales.';

  @override
  String get displayProfileEasyRead => 'Lectura fácil';

  @override
  String get displayProfileEasyReadDescription =>
      'Etiquetas y estado siempre visibles, con enfoque destacado.';

  @override
  String displayProfileApplied(String profile) {
    return 'Perfil $profile aplicado';
  }

  @override
  String get applications => 'Aplicaciones';

  @override
  String get autoHideAppBar => 'Ocultar barra de estado automáticamente';

  @override
  String get backButtonAction => 'Acción del botón \'Atrás\'';

  @override
  String get category => 'Categoría';

  @override
  String get categories => 'Categorías';

  @override
  String get columnCount => 'Cantidad de columnas';

  @override
  String get configureThisTv => 'Configurar este televisor';

  @override
  String get pinProtection => 'Protección con PIN';

  @override
  String get pinProtectionDescription =>
      'Solicita un PIN de 4 a 8 dígitos antes de abrir los ajustes. Si lo olvidas, borrar los datos de la aplicación restablece el PIN y la configuración.';

  @override
  String get createPin => 'Crear PIN de ajustes';

  @override
  String get changePin => 'Cambiar PIN de ajustes';

  @override
  String get disablePin => 'Desactivar protección con PIN';

  @override
  String get enterNewPin => 'Introduce un PIN nuevo de 4 a 8 dígitos';

  @override
  String get confirmPin => 'Confirma el PIN nuevo';

  @override
  String get enterCurrentPin => 'Introduce el PIN actual';

  @override
  String get enterPin => 'PIN';

  @override
  String get pinLengthError => 'Usa de 4 a 8 dígitos';

  @override
  String get pinsDoNotMatch => 'Los PIN no coinciden';

  @override
  String get pinEnabled => 'PIN de ajustes activado';

  @override
  String get pinDisabled => 'PIN de ajustes desactivado';

  @override
  String get incorrectPin => 'PIN incorrecto';

  @override
  String get settingsLocked => 'Los ajustes están bloqueados';

  @override
  String get unlockSettings => 'Desbloquear ajustes';

  @override
  String get applyRecommendedSetup => 'Aplicar configuración recomendada';

  @override
  String get goodTvIsDefaultLauncher => 'GoodTV es el lanzador predeterminado';

  @override
  String get chooseDefaultLauncher => 'Elegir GoodTV como aplicación de inicio';

  @override
  String get unknownDevice => 'Dispositivo de TV desconocido';

  @override
  String androidVersionDetected(String version) {
    return 'Android $version';
  }

  @override
  String recommendedSetupApplied(String profile) {
    return 'Configuración $profile aplicada';
  }

  @override
  String get systemSetupLimitations =>
      'GoodTV puede detectar el televisor y aplicar ajustes seguros automáticamente. Android requiere que apruebes la aplicación de inicio en la pantalla del sistema. No se pueden desactivar otros lanzadores silenciosamente sin acceso de propietario del dispositivo, ADB o root.';

  @override
  String get date => 'Fecha';

  @override
  String get dateAndTimeFormat => 'Formato de fecha y hora';

  @override
  String get delete => 'Eliminar';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Nada';

  @override
  String get dialogOptionBackButtonActionShowScreensaver =>
      'Mostrar salvapantallas';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Mostrar reloj';

  @override
  String get dialogTextNoFileExplorer =>
      'Por favor, instale un gestor de archivos para seleccionar una imagen.';

  @override
  String get dialogTitleBackButtonAction =>
      'Elegir la acción del botón \'Atrás\'';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Categoría)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Fecha con formato: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Hora con formato: $timeString';
  }

  @override
  String get gradient => 'Gradiente';

  @override
  String get favoriteApps => 'Favoritas';

  @override
  String get grid => 'Cuadrícula';

  @override
  String get height => 'Altura';

  @override
  String get hide => 'Ocultar';

  @override
  String get hiddenApplications => 'Aplicaciones ocultas';

  @override
  String get launcherSections => 'Secciones';

  @override
  String get layout => 'Distribución';

  @override
  String get loading => 'Cargando';

  @override
  String get manual => 'Manual';

  @override
  String get modifySection => 'Modificar sección';

  @override
  String get mustNotBeEmpty => 'No debe estar vacío';

  @override
  String get name => 'Nombre';

  @override
  String get newSection => 'Nueva sección';

  @override
  String get noDateFormatSpecified => 'Sin formato de fecha';

  @override
  String get noTimeFormatSpecified => 'Sin formato de hora';

  @override
  String get allApplications => 'Todas las aplicaciones';

  @override
  String get nonTvApplications => 'Otras aplicaciones';

  @override
  String get open => 'Abrir';

  @override
  String get orSelectFormatSpecifiers =>
      'O seleccione especificadores de formato';

  @override
  String get picture => 'Imagen';

  @override
  String removeFrom(String name) {
    return 'Remover de $name';
  }

  @override
  String get renameCategory => 'Renombrar categoría';

  @override
  String get reorder => 'Reordenar';

  @override
  String get row => 'Row';

  @override
  String get rowHeight => 'Row height';

  @override
  String get save => 'Guardar';

  @override
  String get spacer => 'Espaciador';

  @override
  String get spacerMaxHeightRequirement =>
      'Debe ser mayor a cero y menor o igual a 500';

  @override
  String get statusBar => 'Barra de estado';

  @override
  String get settings => 'Ajustes';

  @override
  String get show => 'Mostrar';

  @override
  String get showCategoryTitles => 'Mostrar títulos de categorías';

  @override
  String get sort => 'Orden';

  @override
  String get systemSettings => 'Ajustes del sistema';

  @override
  String get updateCheck => 'Buscar actualizaciones';

  @override
  String get updateNoUpdateTitle => 'No hay actualizaciones';

  @override
  String updateNoUpdateBody(String currentVersion) {
    return 'Ya tienes la última versión ($currentVersion).';
  }

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String updateAvailableBody(String latestVersion, String currentVersion) {
    return 'La versión $latestVersion está disponible (actual: $currentVersion).';
  }

  @override
  String get updateDownloadButton => 'Descargar';

  @override
  String get updateReadyToInstallTitle => 'Lista para instalar';

  @override
  String updateReadyToInstallBody(String latestVersion) {
    return 'El APK de la versión $latestVersion ya se descargó. ¿Instalar ahora?';
  }

  @override
  String get updateInstallButton => 'Instalar';

  @override
  String get updateInstallPermissionTitle =>
      'Se requiere permiso de instalación';

  @override
  String get updateInstallPermissionBody =>
      'Permite que GoodTV Launcher instale apps desconocidas y vuelve a intentar la actualización.';

  @override
  String get updateOpenPermissionSettingsButton => 'Abrir ajustes de permisos';

  @override
  String get updateErrorGeneric =>
      'La actualización falló. Inténtalo de nuevo.';

  @override
  String textAboutDialog(String repoUrl) {
    return 'GoodTV Launcher es un lanzador gratuito y de código abierto para Android TV, Google TV y Fire TV. Good Tools lo desarrolla.\n\nInformación de código abierto: $repoUrl';
  }

  @override
  String get textEmptyCategory => 'Esta categoría está vacía.';

  @override
  String get time => 'Hora';

  @override
  String get titleStatusBarSettingsPage =>
      'Elija la información a mostrar en la barra de estado';

  @override
  String get tvApplications => 'Aplicaciones del televisor';

  @override
  String get type => 'Tipo';

  @override
  String get typeInTheDateFormat => 'Escriba el formato de fecha';

  @override
  String get typeInTheHourFormat => 'Escriba el formato de hora';

  @override
  String get uninstall => 'Desinstalar';

  @override
  String get wallpaper => 'Fondo de pantalla';

  @override
  String get withEllipsisAddTo => 'Añadir a...';

  @override
  String get timeBasedWallpaper => 'Fondo de pantalla según la hora';

  @override
  String get pickDayWallpaper => 'Elegir fondo de día';

  @override
  String get pickNightWallpaper => 'Elegir fondo de noche';

  @override
  String get video => 'Vídeo';

  @override
  String get pickDayVideoWallpaper => 'Elegir vídeo de día';

  @override
  String get pickNightVideoWallpaper => 'Elegir vídeo de noche';

  @override
  String get watchNextSectionTitle => 'Ver después';

  @override
  String get showWatchNextSection => 'Mostrar sección Ver después';

  @override
  String get watchNextPermissionTitle => 'Se requiere permiso para Ver después';

  @override
  String get watchNextPermissionBody =>
      'Permite el acceso a la guía de TV para mostrar lo que estabas viendo.';

  @override
  String get watchNextGrantPermission => 'Conceder permiso';

  @override
  String get watchNextCheckPermission => 'Comprobar de nuevo';

  @override
  String get interface => 'Interfaz';

  @override
  String get system => 'Sistema';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get miscellaneous => 'Varios';

  @override
  String get brightnessScheduler => 'Programador de brillo';

  @override
  String get screensaverSettings => 'Ajustes del salvapantallas';

  @override
  String get screensaverClockStyle => 'Estilo del reloj del salvapantallas';

  @override
  String get wifiUsagePeriod => 'Período de uso de WiFi';

  @override
  String get showAppNamesBelowIcons => 'Mostrar nombres bajo los iconos';

  @override
  String get wifiUsage => 'Uso de WiFi';

  @override
  String get networkIndicator => 'Indicador de red';

  @override
  String get customName => 'Nombre personalizado';

  @override
  String get lastUsed => 'Último uso';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get grantPermission => 'Conceder permiso';

  @override
  String get checkStatus => 'Comprobar estado';

  @override
  String get backupAndRestore => 'Copia y restauración';

  @override
  String get createBackup => 'Crear copia ahora';

  @override
  String get restoreLatestBackup => 'Restaurar la última copia';

  @override
  String get noBackups => 'Aún no hay copias';

  @override
  String get backupDescription =>
      'Las copias incluyen la distribución, categorías, favoritas, aplicaciones ocultas, ajustes, banners y fondos de imagen o vídeo. Se conservan las cinco copias más recientes en este dispositivo.';

  @override
  String get backupCreated => 'Copia creada';

  @override
  String get backupFailed => 'No se pudo crear la copia';

  @override
  String get restoreBackupTitle => '¿Restaurar la copia del lanzador?';

  @override
  String get restoreBackupWarning =>
      'Esto reemplaza la distribución, los ajustes, banners y fondos actuales con la última copia.';

  @override
  String get restore => 'Restaurar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get backupRestored => 'Copia restaurada';

  @override
  String get restoreFailed => 'No se pudo restaurar la copia';

  @override
  String get onlineAerialBackgrounds => 'Fondos en línea y aéreos';

  @override
  String get onlineWallpaper => 'Fondos en línea';

  @override
  String get onlineWallpaperDescription =>
      'Conecta una imagen o video directo, una lista M3U o una fuente JSON tipo Overflight. GoodTV cambia automáticamente entre los elementos.';

  @override
  String get wallpaperFeedUrl => 'URL de la fuente de fondos';

  @override
  String get changeBackgroundEvery => 'Cambiar fondo cada';

  @override
  String get connectWallpaperFeed => 'Conectar fuente de fondos';

  @override
  String get nextWallpaper => 'Siguiente fondo';

  @override
  String get disableOnlineWallpaper => 'Desactivar fondos en línea';

  @override
  String get wallpaperFeedConnected => 'Fuente de fondos conectada';

  @override
  String get wallpaperFeedError => 'No se pudo cargar esa fuente de fondos';
}
