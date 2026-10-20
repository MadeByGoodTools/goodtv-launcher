import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/local_wallpaper_collection.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:goodtv_launcher/providers/wallpaper_service.dart';
import 'package:goodtv_launcher/snoopy_seasons.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Paths extends PathProviderPlatform {
  final String directory;
  _Paths(this.directory);
  @override
  Future<String?> getApplicationDocumentsPath() async => directory;
}

Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 1000 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(condition(), isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'rotation filters seasons at clip boundaries, preserves fade time, and supports all-clips override',
    () async {
      final originalPaths = PathProviderPlatform.instance;
      final root = await Directory.systemTemp.createTemp('goodtv-seasonal-');
      PathProviderPlatform.instance = _Paths(root.path);
      addTearDown(() async {
        PathProviderPlatform.instance = originalPaths;
        await root.delete(recursive: true);
      });
      SharedPreferences.setMockInitialValues({'wallpaper_feed_url': ''});
      final settings = SettingsService(await SharedPreferences.getInstance());
      addTearDown(settings.dispose);
      final catalogue = SnoopyCatalogue.parse(
        File('assets/video_collections/Snoopy/catalog.json').readAsStringSync(),
      );
      final directory = await Directory(
        '${root.path}/wallpaper_collections/Snoopy',
      ).create(recursive: true);
      for (final clip in catalogue.clips) {
        await File('${directory.path}/${clip.filename}').writeAsBytes([1]);
      }
      final collection = await readWallpaperCollection(
        await wallpaperCollectionsDirectory(),
        directory,
      );
      var date = DateTime(2026, 10, 31, 23, 59);
      final service = WallpaperService(settings, now: () => date);
      addTearDown(service.dispose);
      await _until(() => service.isInitialized);
      await service.configureLocalVideoCollection(collection);

      final available = catalogue.clips
          .where((clip) => clip.unlocked(date))
          .map((clip) => clip.filename)
          .toSet();
      final played = <String>{};
      for (var i = 0; i < available.length; i++) {
        final filename = Uri.parse(
          service.wallpaperVideoUrl!,
        ).pathSegments.last;
        expect(available, contains(filename));
        expect(played.add(filename), isTrue);
        await service.nextRemoteWallpaper();
      }
      expect(played, available);

      // A Canadian winter shoulder month starts and Halloween has finished.
      // Merely changing the date must not interrupt the current clip.
      final previous = service.wallpaperVideoUrl;
      date = DateTime(2026, 11, 3);
      expect(service.wallpaperVideoUrl, previous);
      final fadeAt = DateTime(2026, 11, 3, 12, 0, 1);
      await service.nextRemoteWallpaper(transitionAt: fadeAt);
      expect(service.transitionAt, fadeAt);
      for (var i = 0; i < 90; i++) {
        final filename = Uri.parse(
          service.wallpaperVideoUrl!,
        ).pathSegments.last;
        expect(catalogue.fileUnlocked(filename, date), isTrue);
        expect(filename, isNot(anyOf('NxZD0FULaKA.mp4', 'uj33McN9Oyw.mp4')));
        await service.nextRemoteWallpaper();
      }

      await settings.setAutomaticSnoopySeasons(false);
      await _until(() => service.wallpaperVideoUrl != null);
      final all = <String>{};
      for (var i = 0; i < 65; i++) {
        all.add(Uri.parse(service.wallpaperVideoUrl!).pathSegments.last);
        await service.nextRemoteWallpaper();
      }
      expect(all.length, 65);
      await settings.setAutomaticSnoopySeasons(true);
      await _until(() => service.wallpaperVideoUrl != null);
      expect(
        catalogue.fileUnlocked(
          Uri.parse(service.wallpaperVideoUrl!).pathSegments.last,
          date,
        ),
        isTrue,
      );
    },
  );
}
