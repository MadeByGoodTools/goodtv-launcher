/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:goodtv_launcher/flauncher_channel.dart';
import 'package:goodtv_launcher/gradients.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class RemoteWallpaperItem {
  final Uri uri;
  final bool isVideo;
  final String? title;

  const RemoteWallpaperItem({
    required this.uri,
    required this.isVideo,
    this.title,
  });
}

List<RemoteWallpaperItem> parseWallpaperFeed(String body, Uri source) {
  final trimmed = body.trim();
  if (trimmed.startsWith('[')) {
    final decoded = jsonDecode(trimmed) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((rawItem) {
          final item = Map<String, dynamic>.from(rawItem);
          final url =
              [
                item['url_1080p'],
                item['url_4k'],
                item['url_1080p_hdr'],
                item['url_4k_hdr'],
                item['url_img'],
                item['url'],
              ].whereType<String>().firstWhere(
                (value) => value.trim().isNotEmpty,
                orElse: () => '',
              );
          if (url.isEmpty) return null;
          final uri = source.resolve(url);
          return RemoteWallpaperItem(
            uri: uri,
            isVideo: _isVideoUri(uri),
            title: item['title']?.toString(),
          );
        })
        .whereType<RemoteWallpaperItem>()
        .toList();
  }

  if (trimmed.startsWith('#EXTM3U') || trimmed.contains('\n')) {
    return const LineSplitter()
        .convert(trimmed)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .map(source.resolve)
        .map((uri) => RemoteWallpaperItem(uri: uri, isVideo: _isVideoUri(uri)))
        .toList();
  }

  final uri = source.resolve(trimmed);
  return [RemoteWallpaperItem(uri: uri, isVideo: _isVideoUri(uri))];
}

bool _isVideoUri(Uri uri) {
  final path = uri.path.toLowerCase();
  return path.endsWith('.mp4') ||
      path.endsWith('.m3u8') ||
      path.endsWith('.webm') ||
      path.endsWith('.mkv') ||
      path.endsWith('.mov');
}

class WallpaperService extends ChangeNotifier {
  final SettingsService _settingsService;
  final FLauncherChannel _channel = FLauncherChannel();

  late File _wallpaperFile;
  late File _wallpaperDayFile;
  late File _wallpaperNightFile;
  late File _wallpaperVideoFile;
  late File _wallpaperDayVideoFile;
  late File _wallpaperNightVideoFile;
  bool _initialized = false;
  Timer? _timer;
  Timer? _feedTimer;
  int _wallpaperRevision = 0;
  List<RemoteWallpaperItem> _remoteItems = const [];
  int _remoteIndex = 0;
  String? _lastFeedUrl;

  ImageProvider? _wallpaper;
  int get wallpaperRevision => _wallpaperRevision;

  ImageProvider? get wallpaper => _wallpaper;

  String? get wallpaperVideoUrl {
    if (_remoteItems.isEmpty) return null;
    final item = _remoteItems[_remoteIndex % _remoteItems.length];
    return item.isVideo ? item.uri.toString() : null;
  }

  bool get remoteFeedEnabled => _settingsService.wallpaperFeedUrl != null;

  String? get remoteWallpaperTitle => _remoteItems.isEmpty
      ? null
      : _remoteItems[_remoteIndex % _remoteItems.length].title;

  File? get wallpaperVideoFile {
    final f = _resolveActiveVideoFile();
    return f != null && f.existsSync() ? f : null;
  }

  FLauncherGradient get gradient => FLauncherGradients.all.firstWhere(
    (gradient) => gradient.uuid == _settingsService.gradientUuid,
    orElse: () => FLauncherGradients.saintPetersburg,
  );

  WallpaperService(this._settingsService) : _wallpaper = null {
    _settingsService.addListener(_onSettingsChanged);
    _init();
  }

  bool _lastTimeBasedEnabled = false;

  void _onSettingsChanged() {
    final enabled = _settingsService.timeBasedWallpaperEnabled;
    if (enabled != _lastTimeBasedEnabled) {
      _lastTimeBasedEnabled = enabled;
      _updateTimerState();
      _updateWallpaper();
    }
    final feedUrl = _settingsService.wallpaperFeedUrl;
    if (feedUrl != _lastFeedUrl) {
      _loadRemoteFeed().catchError((Object error) {
        debugPrint('Wallpaper feed refresh failed: $error');
      });
    }
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _timer?.cancel();
    _feedTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final directory = await getApplicationDocumentsDirectory();
    _wallpaperFile = File("${directory.path}/wallpaper");
    _wallpaperDayFile = File("${directory.path}/wallpaper_day");
    _wallpaperNightFile = File("${directory.path}/wallpaper_night");
    _wallpaperVideoFile = File("${directory.path}/wallpaper_video");
    _wallpaperDayVideoFile = File("${directory.path}/wallpaper_day_video");
    _wallpaperNightVideoFile = File("${directory.path}/wallpaper_night_video");
    _initialized = true;

    _lastTimeBasedEnabled = _settingsService.timeBasedWallpaperEnabled;
    _updateWallpaper();
    _updateTimerState();
    try {
      await _loadRemoteFeed();
    } catch (error) {
      debugPrint('Saved wallpaper feed could not be loaded: $error');
      _updateWallpaper(force: true);
    }
  }

  Future<void> reloadFromStorage() async {
    if (!_initialized) {
      await _init();
      return;
    }
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    _updateWallpaper(force: true);
  }

  void _updateTimerState() {
    final enabled = _settingsService.timeBasedWallpaperEnabled;
    if (enabled && (_timer == null || !_timer!.isActive)) {
      _timer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _updateWallpaper(),
      );
    } else if (!enabled && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> configureRemoteFeed(String url, int intervalMinutes) async {
    final normalizedUrl = url.trim();
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null ||
        !uri.hasScheme ||
        !{'http', 'https'}.contains(uri.scheme)) {
      throw const FormatException('Use a valid HTTP or HTTPS URL');
    }
    final items = await _fetchRemoteItems(uri);
    if (items.isEmpty) throw StateError('No wallpapers found');

    _lastFeedUrl = normalizedUrl;
    _remoteItems = items;
    _remoteIndex = 0;
    await _settingsService.setWallpaperFeed(normalizedUrl, intervalMinutes);
    _startFeedTimer();
    _updateWallpaper(force: true);
  }

  Future<void> disableRemoteFeed() async {
    _feedTimer?.cancel();
    _feedTimer = null;
    _remoteItems = const [];
    _remoteIndex = 0;
    await _settingsService.setWallpaperFeed(null, 15);
    _updateWallpaper(force: true);
  }

  Future<void> nextRemoteWallpaper() async {
    if (_remoteItems.length < 2) return;
    _remoteIndex = (_remoteIndex + 1) % _remoteItems.length;
    _updateWallpaper(force: true);
  }

  Future<void> _loadRemoteFeed({bool force = false}) async {
    final feedUrl = _settingsService.wallpaperFeedUrl;
    if (!force && feedUrl == _lastFeedUrl) return;
    _lastFeedUrl = feedUrl;
    _feedTimer?.cancel();
    _feedTimer = null;
    _remoteItems = const [];
    _remoteIndex = 0;
    if (feedUrl == null || feedUrl.isEmpty) {
      _updateWallpaper(force: true);
      return;
    }

    final source = Uri.parse(feedUrl);
    _remoteItems = await _fetchRemoteItems(source);
    _startFeedTimer();
    _updateWallpaper(force: true);
  }

  Future<List<RemoteWallpaperItem>> _fetchRemoteItems(Uri source) async {
    if (_isVideoUri(source) || _isImageUri(source)) {
      return [RemoteWallpaperItem(uri: source, isVideo: _isVideoUri(source))];
    }
    final response = await http
        .get(source)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Wallpaper feed returned ${response.statusCode}');
    }
    return parseWallpaperFeed(response.body, source);
  }

  void _startFeedTimer() {
    _feedTimer?.cancel();
    _feedTimer = null;
    if (_remoteItems.length > 1) {
      _feedTimer = Timer.periodic(
        Duration(minutes: _settingsService.wallpaperFeedIntervalMinutes),
        (_) => nextRemoteWallpaper(),
      );
    }
  }

  static bool _isImageUri(Uri uri) {
    final path = uri.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  File? _resolveActiveVideoFile() {
    if (!isInitialized) return null;

    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 18;
    final enabled = _settingsService.timeBasedWallpaperEnabled;

    if (enabled) {
      if (isDay && _wallpaperDayVideoFile.existsSync()) {
        return _wallpaperDayVideoFile;
      }
      if (!isDay && _wallpaperNightVideoFile.existsSync()) {
        return _wallpaperNightVideoFile;
      }
      if (_wallpaperVideoFile.existsSync()) {
        return _wallpaperVideoFile;
      }
    } else if (_wallpaperVideoFile.existsSync()) {
      return _wallpaperVideoFile;
    }
    return null;
  }

  bool get isInitialized => _initialized;

  void _updateWallpaper({bool force = false}) {
    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 18;
    final enabled = _settingsService.timeBasedWallpaperEnabled;

    final videoFile = _resolveActiveVideoFile();
    final remoteItem = _remoteItems.isEmpty
        ? null
        : _remoteItems[_remoteIndex % _remoteItems.length];

    ImageProvider? newWallpaper;

    if (remoteItem != null && remoteItem.isVideo) {
      newWallpaper = null;
    } else if (remoteItem != null) {
      newWallpaper = NetworkImage(remoteItem.uri.toString());
    } else if (videoFile != null) {
      newWallpaper = null;
    } else if (enabled) {
      if (isDay && _wallpaperDayFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperDayFile);
      } else if (!isDay && _wallpaperNightFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperNightFile);
      } else if (_wallpaperFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperFile); // Fallback
      }
    } else if (_wallpaperFile.existsSync()) {
      newWallpaper = FileImage(_wallpaperFile);
    }

    if (_wallpaper != newWallpaper ||
        videoFile != null ||
        remoteItem?.isVideo == true ||
        force) {
      _wallpaper = newWallpaper;
      _wallpaperRevision++;
      notifyListeners();
    }
  }

  Future<void> pickWallpaper(File sourceFile) async {
    await disableRemoteFeed();
    await _saveImage(sourceFile, _wallpaperFile);
  }

  Future<void> pickWallpaperFromUri(String sourceUri) async {
    await disableRemoteFeed();
    await _saveImageBytes(
      await _channel.loadContentUriImage(sourceUri),
      _wallpaperFile,
    );
  }

  Future<void> pickWallpaperDay(File sourceFile) async {
    await disableRemoteFeed();
    await _saveImage(sourceFile, _wallpaperDayFile);
  }

  Future<void> pickWallpaperDayFromUri(String sourceUri) async {
    await disableRemoteFeed();
    await _saveImageBytes(
      await _channel.loadContentUriImage(sourceUri),
      _wallpaperDayFile,
    );
  }

  Future<void> pickWallpaperNight(File sourceFile) async {
    await disableRemoteFeed();
    await _saveImage(sourceFile, _wallpaperNightFile);
  }

  Future<void> pickWallpaperNightFromUri(String sourceUri) async {
    await disableRemoteFeed();
    await _saveImageBytes(
      await _channel.loadContentUriImage(sourceUri),
      _wallpaperNightFile,
    );
  }

  Future<void> pickVideoWallpaper(File sourceFile) async {
    await disableRemoteFeed();
    await _saveVideo(sourceFile, _wallpaperVideoFile);
  }

  Future<void> pickVideoWallpaperDay(File sourceFile) async {
    await disableRemoteFeed();
    await _saveVideo(sourceFile, _wallpaperDayVideoFile);
  }

  Future<void> pickVideoWallpaperNight(File sourceFile) async {
    await disableRemoteFeed();
    await _saveVideo(sourceFile, _wallpaperNightVideoFile);
  }

  Future<void> _saveImage(File sourceFile, File targetFile) async {
    await _replacePairedVideo(targetFile);

    final readStream = sourceFile.openRead();
    final writeStream = targetFile.openWrite();
    await readStream.cast<List<int>>().pipe(writeStream);

    await _refreshImageWallpaper(targetFile);
  }

  Future<void> _saveImageBytes(Uint8List imageBytes, File targetFile) async {
    if (imageBytes.isEmpty) {
      throw StateError('Unable to read the selected image');
    }

    await _replacePairedVideo(targetFile);
    await targetFile.writeAsBytes(imageBytes, flush: true);

    await _refreshImageWallpaper(targetFile);
  }

  Future<void> _replacePairedVideo(File targetFile) async {
    // Setting an image means the user no longer wants a video wallpaper, so
    // remove all video wallpaper files (including unrelated ones like the
    // general wallpaper_video when setting wallpaper_day) to prevent stale
    // video playback after switching.
    await cleanVideoWallpaperFiles();
  }

  Future<void> _refreshImageWallpaper(File targetFile) async {
    await FileImage(targetFile).evict();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    _updateWallpaper(force: true);
  }

  Future<void> _saveVideo(File sourceFile, File targetVideoFile) async {
    final pairedImage = _pairedImageForVideo(targetVideoFile);
    if (pairedImage != null && await pairedImage.exists()) {
      await pairedImage.delete();
    }

    final readStream = sourceFile.openRead();
    final writeStream = targetVideoFile.openWrite();
    await readStream.cast<List<int>>().pipe(writeStream);

    _updateWallpaper(force: true);
  }

  File? _pairedImageForVideo(File videoFile) {
    if (videoFile.path == _wallpaperVideoFile.path) return _wallpaperFile;
    if (videoFile.path == _wallpaperDayVideoFile.path) return _wallpaperDayFile;
    if (videoFile.path == _wallpaperNightVideoFile.path)
      return _wallpaperNightFile;
    return null;
  }

  Future<void> setGradient(FLauncherGradient fLauncherGradient) async {
    await disableRemoteFeed();
    await cleanImageWallpaperFiles();
    await cleanVideoWallpaperFiles();

    await _settingsService.setGradientUuid(fLauncherGradient.uuid);
    // Drop the in-memory wallpaper provider so the gradient is shown instead of
    // the (now deleted) image/video file. _updateWallpaper notifies listeners.
    _updateWallpaper(force: true);
  }

  // Cleaning methods

  Future<void> cleanVideoWallpaperFiles() async {
    if (await _wallpaperVideoFile.exists()) {
      await _wallpaperVideoFile.delete();
    }

    if (await _wallpaperDayVideoFile.exists()) {
      await _wallpaperDayVideoFile.delete();
    }

    if (await _wallpaperNightVideoFile.exists()) {
      await _wallpaperNightVideoFile.delete();
    }
  }

  Future<void> cleanImageWallpaperFiles() async {
    if (await _wallpaperFile.exists()) {
      await _wallpaperFile.delete();
    }

    if (await _wallpaperDayFile.exists()) {
      await _wallpaperDayFile.delete();
    }

    if (await _wallpaperNightFile.exists()) {
      await _wallpaperNightFile.delete();
    }
  }
}
