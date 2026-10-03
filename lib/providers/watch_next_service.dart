/*
 * FLauncher
 * Copyright (C) 2021 Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:goodtv_launcher/flauncher_channel.dart';
import 'package:goodtv_launcher/models/watch_next_item.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:http/http.dart' as http;

class WatchNextService extends ChangeNotifier {
  final FLauncherChannel _fLauncherChannel;
  final SettingsService _settingsService;

  List<WatchNextItem> _items = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  final Map<String, Uint8List> _posterCache = {};
  final Set<String> _loadingPosters = {};
  final Set<String> _failedPosters = {};
  Timer? _refreshTimer;
  Timer? _posterNotifyDebounce;
  static const int _maxParallelPosterLoads = 2;

  List<WatchNextItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  bool get hasItems => _items.isNotEmpty;
  bool get hasVisibleSection =>
      !_isLoading && (!_hasPermission || _items.isNotEmpty);

  WatchNextService(this._fLauncherChannel, this._settingsService) {
    _init();
  }

  void _init() async {
    await refreshPermissionAndItems();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      refreshPermissionAndItems();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _posterNotifyDebounce?.cancel();
    super.dispose();
  }

  Future<void> checkPermission() async {
    try {
      _hasPermission = await _fLauncherChannel.checkWatchNextPermission();
    } catch (e) {
      debugPrint('WatchNext: Error checking permission: $e');
      _hasPermission = false;
    }
    notifyListeners();
  }

  Future<void> requestPermission() async {
    try {
      await _fLauncherChannel.requestWatchNextPermission();
    } catch (e) {
      debugPrint('WatchNext: Error requesting permission: $e');
    }
  }

  Future<void> refreshPermissionAndItems() async {
    await checkPermission();
    if (_hasPermission ||
        _settingsService.jellyfinConfigured ||
        _settingsService.continueWatchingFeedUrl != null) {
      await refreshItems();
    } else {
      _items = [];
      notifyListeners();
    }
  }

  Future<void> refreshItems() async {
    if (_isLoading) return;

    if (!_hasPermission &&
        !_settingsService.jellyfinConfigured &&
        _settingsService.continueWatchingFeedUrl == null) {
      await checkPermission();
      if (!_hasPermission) {
        _items = [];
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final nativeFuture = _hasPermission
          ? _fLauncherChannel.getWatchNextItems()
          : Future.value(<Map<dynamic, dynamic>>[]);
      final jellyfinFuture = _loadJellyfinResumeItems();
      final feedFuture = _loadContinueWatchingFeed();
      final results = await Future.wait([
        nativeFuture,
        jellyfinFuture,
        feedFuture,
      ]);
      final nativeItems = (results[0] as List).map(
        (map) => WatchNextItem.fromMap(map as Map<dynamic, dynamic>),
      );
      final jellyfinItems = results[1] as List<WatchNextItem>;
      final feedItems = results[2] as List<WatchNextItem>;
      final seen = <String>{};
      _items = [...jellyfinItems, ...feedItems, ...nativeItems]
          .where(
            (item) =>
                seen.add('${item.packageName}:${item.contentId}:${item.title}'),
          )
          .take(20)
          .toList(growable: false);

      if (_items.length < 2 && _settingsService.jellyfinConfigured) {
        final recommendations = await _loadJellyfinRecommendations(
          limit: 2 - _items.length,
          excludeIds: _items.map((item) => item.contentId).whereType<String>(),
        );
        _items = [..._items, ...recommendations];
      }

      unawaited(_preloadInitialPosters());
    } catch (e) {
      debugPrint('WatchNext: Error loading items: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<WatchNextItem>> _loadContinueWatchingFeed() async {
    final feedUrl = _settingsService.continueWatchingFeedUrl;
    if (feedUrl == null) return const [];
    try {
      final response = await http
          .get(Uri.parse(feedUrl))
          .timeout(const Duration(seconds: 7));
      if (response.statusCode != 200) return const [];
      final payload = jsonDecode(response.body);
      final entries = payload is List
          ? payload
          : payload is Map && payload['items'] is List
          ? payload['items'] as List
          : const [];
      return entries
          .whereType<Map>()
          .map((item) => WatchNextItem.fromMap(item))
          .where((item) => item.title.isNotEmpty)
          .toList(growable: false);
    } catch (error) {
      debugPrint('WatchNext: provider feed refresh failed: $error');
      return const [];
    }
  }

  Future<List<WatchNextItem>> _loadJellyfinResumeItems() async {
    final serverUrl = _settingsService.jellyfinServerUrl;
    final token = _settingsService.jellyfinApiToken;
    if (serverUrl == null || token == null) return const [];

    try {
      final headers = {'X-Emby-Token': token, 'Accept': 'application/json'};
      final meResponse = await http
          .get(Uri.parse('$serverUrl/Users/Me'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (meResponse.statusCode != 200) return const [];
      final userId = (jsonDecode(meResponse.body) as Map)['Id']?.toString();
      if (userId == null || userId.isEmpty) return const [];

      final uri = Uri.parse('$serverUrl/Users/$userId/Items/Resume').replace(
        queryParameters: const {
          'Limit': '20',
          'Fields': 'Overview,PrimaryImageAspectRatio',
          'MediaTypes': 'Movie,Episode',
          'EnableImageTypes': 'Primary,Backdrop',
        },
      );
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 7));
      if (response.statusCode != 200) return const [];
      return parseJellyfinResumeItems(
        jsonDecode(response.body),
        serverUrl: serverUrl,
        token: token,
      );
    } catch (error) {
      debugPrint('WatchNext: Jellyfin refresh failed: $error');
      return const [];
    }
  }

  Future<List<WatchNextItem>> _loadJellyfinRecommendations({
    required int limit,
    required Iterable<String> excludeIds,
  }) async {
    final serverUrl = _settingsService.jellyfinServerUrl;
    final token = _settingsService.jellyfinApiToken;
    if (serverUrl == null || token == null || limit <= 0) return const [];

    try {
      final headers = {'X-Emby-Token': token, 'Accept': 'application/json'};
      final meResponse = await http
          .get(Uri.parse('$serverUrl/Users/Me'), headers: headers)
          .timeout(const Duration(seconds: 5));
      if (meResponse.statusCode != 200) return const [];
      final userId = (jsonDecode(meResponse.body) as Map)['Id']?.toString();
      if (userId == null || userId.isEmpty) return const [];

      final uri = Uri.parse('$serverUrl/Users/$userId/Items').replace(
        queryParameters: {
          'Recursive': 'true',
          'IncludeItemTypes': 'Movie,Series',
          'Filters': 'IsUnplayed',
          'SortBy': 'Random',
          'Limit': '${limit + excludeIds.length + 4}',
          'Fields': 'Overview,PrimaryImageAspectRatio',
          'EnableImageTypes': 'Primary,Backdrop',
        },
      );
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 7));
      if (response.statusCode != 200) return const [];
      return parseJellyfinRecommendationItems(
        jsonDecode(response.body),
        serverUrl: serverUrl,
        token: token,
        excludeIds: excludeIds.toSet(),
      ).take(limit).toList(growable: false);
    } catch (error) {
      debugPrint('WatchNext: Jellyfin recommendations failed: $error');
      return const [];
    }
  }

  @visibleForTesting
  static List<WatchNextItem> parseJellyfinResumeItems(
    dynamic payload, {
    required String serverUrl,
    required String token,
  }) {
    if (payload is! Map || payload['Items'] is! List) return const [];
    return (payload['Items'] as List)
        .whereType<Map>()
        .map((item) {
          final id = item['Id']?.toString() ?? '';
          final userData = item['UserData'] is Map
              ? item['UserData'] as Map
              : const {};
          final seriesName = item['SeriesName']?.toString();
          final name = item['Name']?.toString() ?? 'Continue watching';
          final title = seriesName == null || seriesName.isEmpty
              ? name
              : '$seriesName — $name';
          final hasBackdrop =
              item['BackdropImageTags'] is List &&
              (item['BackdropImageTags'] as List).isNotEmpty;
          final imagePath = hasBackdrop ? 'Backdrop/0' : 'Primary';
          final imageUri = Uri.parse('$serverUrl/Items/$id/Images/$imagePath')
              .replace(
                queryParameters: {
                  'maxWidth': '1280',
                  'quality': '90',
                  'api_key': token,
                },
              );
          return WatchNextItem(
            id: id.hashCode,
            title: title,
            description: item['Overview']?.toString(),
            posterUri: imageUri.toString(),
            packageName: 'org.jellyfin.androidtv',
            contentId: id,
            progressPercent: (userData['PlayedPercentage'] as num?)?.round(),
            intentUri: null,
            aspectRatio: item['PrimaryImageAspectRatio']?.toString(),
          );
        })
        .where((item) => item.contentId!.isNotEmpty)
        .toList(growable: false);
  }

  @visibleForTesting
  static List<WatchNextItem> parseJellyfinRecommendationItems(
    dynamic payload, {
    required String serverUrl,
    required String token,
    Set<String> excludeIds = const {},
  }) {
    if (payload is! Map || payload['Items'] is! List) return const [];
    return (payload['Items'] as List)
        .whereType<Map>()
        .map((item) {
          final id = item['Id']?.toString() ?? '';
          final hasBackdrop =
              item['BackdropImageTags'] is List &&
              (item['BackdropImageTags'] as List).isNotEmpty;
          final imagePath = hasBackdrop ? 'Backdrop/0' : 'Primary';
          final imageUri = Uri.parse('$serverUrl/Items/$id/Images/$imagePath')
              .replace(
                queryParameters: {
                  'maxWidth': '1280',
                  'quality': '90',
                  'api_key': token,
                },
              );
          return WatchNextItem(
            id: id.hashCode,
            title: item['Name']?.toString() ?? 'Watch now',
            description: item['Overview']?.toString(),
            posterUri: imageUri.toString(),
            packageName: 'org.jellyfin.androidtv',
            contentId: id,
            intentUri: null,
            aspectRatio: item['PrimaryImageAspectRatio']?.toString(),
            isRecommendation: true,
          );
        })
        .where(
          (item) =>
              item.contentId!.isNotEmpty &&
              !excludeIds.contains(item.contentId),
        )
        .toList(growable: false);
  }

  Future<void> _preloadInitialPosters() async {
    final pendingUris = _items
        .take(3)
        .map((item) => item.artworkUri)
        .whereType<String>()
        .where((uri) => !_posterCache.containsKey(uri))
        .toList(growable: false);

    if (pendingUris.isEmpty) {
      return;
    }

    int nextIndex = 0;
    Future<void> worker() async {
      while (nextIndex < pendingUris.length) {
        final uri = pendingUris[nextIndex++];
        await _loadPosterImage(uri);
      }
    }

    final workers = List.generate(_maxParallelPosterLoads, (_) => worker());
    await Future.wait(workers);
  }

  void ensurePosterLoaded(String? uri) {
    if (uri == null ||
        _posterCache.containsKey(uri) ||
        _failedPosters.contains(uri) ||
        _loadingPosters.contains(uri)) {
      return;
    }
    unawaited(_loadPosterImage(uri));
  }

  Future<void> _loadPosterImage(String uri) async {
    if (_posterCache.containsKey(uri) || _loadingPosters.contains(uri)) {
      return;
    }
    _loadingPosters.add(uri);
    try {
      Uint8List? imageBytes;

      if (uri.startsWith('content://')) {
        imageBytes = await _fLauncherChannel.loadContentUriImage(uri);
      } else {
        final uriObj = Uri.parse(uri);
        final response = await http
            .get(uriObj)
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      }

      if (imageBytes != null && imageBytes.isNotEmpty) {
        _posterCache[uri] = imageBytes;
        _failedPosters.remove(uri);
        _schedulePosterCacheNotification();
      } else {
        _failedPosters.add(uri);
        _schedulePosterCacheNotification();
      }
    } catch (_) {
      _failedPosters.add(uri);
      _schedulePosterCacheNotification();
    } finally {
      _loadingPosters.remove(uri);
    }
  }

  void _schedulePosterCacheNotification() {
    if (_posterNotifyDebounce?.isActive ?? false) {
      return;
    }
    _posterNotifyDebounce = Timer(
      const Duration(milliseconds: 80),
      notifyListeners,
    );
  }

  Uint8List? getCachedPoster(String? uri) {
    if (uri == null) return null;
    return _posterCache[uri];
  }

  bool hasPosterLoadFailed(String? uri) {
    if (uri == null) return false;
    return _failedPosters.contains(uri);
  }

  Future<void> launchItem(WatchNextItem item) async {
    debugPrint('WatchNext: Launching item: ${item.title}');
    debugPrint(
      'WatchNext: packageName=${item.packageName}, contentId=${item.contentId}, intentUri=${item.intentUri}',
    );

    if (item.packageName == null && item.intentUri == null) {
      debugPrint('WatchNext: Cannot launch - no package name or intent URI');
      return;
    }

    await _fLauncherChannel.launchWatchNextItem(
      item.packageName,
      item.contentId,
      item.intentUri,
    );
  }
}
