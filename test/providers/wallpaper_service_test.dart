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
import 'dart:typed_data';

import 'package:goodtv_launcher/gradients.dart';
import 'package:goodtv_launcher/providers/wallpaper_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mocks.mocks.dart';

void main() {
  late final _MockPathProviderPlatform pathProviderPlatform;
  setUpAll(() {
    pathProviderPlatform = _MockPathProviderPlatform();
    when(
      pathProviderPlatform.getApplicationDocumentsPath(),
    ).thenAnswer((_) => Future.value("."));
    PathProviderPlatform.instance = pathProviderPlatform;
  });

  test("pickWallpaper saves source file", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = MockSettingsService();
    when(settingsService.timeBasedWallpaperEnabled).thenReturn(false);
    final wallpaperService = WallpaperService(settingsService);
    await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());

    final source = File("test_wallpaper_src");
    await source.writeAsBytes([0x01, 0x02]);
    addTearDown(() async {
      if (await source.exists()) await source.delete();
      final dest = File("./wallpaper");
      if (await dest.exists()) await dest.delete();
    });

    await wallpaperService.pickWallpaper(source);

    expect(await File("./wallpaper").exists(), isTrue);
    expect(await File("./wallpaper").readAsBytes(), [0x01, 0x02]);
  });

  test("pickWallpaperFromUri saves the selected image bytes", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('me.efesser.flauncher/method');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'loadContentUriImage') {
        return Uint8List.fromList([0x03, 0x04]);
      }
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final settingsService = MockSettingsService();
    when(settingsService.timeBasedWallpaperEnabled).thenReturn(false);
    final wallpaperService = WallpaperService(settingsService);
    await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());
    addTearDown(() async {
      final dest = File('./wallpaper');
      if (await dest.exists()) await dest.delete();
    });

    await wallpaperService.pickWallpaperFromUri(
      'content://media/external/images/media/1',
    );

    expect(await File('./wallpaper').readAsBytes(), [0x03, 0x04]);
  });

  test("setGradient", () async {
    final settingsService = MockSettingsService();
    when(settingsService.timeBasedWallpaperEnabled).thenReturn(false);
    final wallpaperService = WallpaperService(settingsService);

    await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());
    await wallpaperService.setGradient(FLauncherGradients.greatWhale);

    verify(settingsService.setGradientUuid(FLauncherGradients.greatWhale.uuid));
    expect(wallpaperService.wallpaper, null);
  });

  group("getGradient", () {
    test("without uuid from settings", () async {
      final settingsService = MockSettingsService();
      when(settingsService.timeBasedWallpaperEnabled).thenReturn(false);
      final wallpaperService = WallpaperService(settingsService);
      when(settingsService.gradientUuid).thenReturn(null);

      await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());
      final gradient = wallpaperService.gradient;

      expect(gradient, FLauncherGradients.saintPetersburg);
    });

    test("with uuid from settings", () async {
      final settingsService = MockSettingsService();
      when(settingsService.timeBasedWallpaperEnabled).thenReturn(false);
      final wallpaperService = WallpaperService(settingsService);
      when(
        settingsService.gradientUuid,
      ).thenReturn(FLauncherGradients.grassShampoo.uuid);
      await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());

      final gradient = wallpaperService.gradient;

      expect(gradient, FLauncherGradients.grassShampoo);
    });
  });
}

class _MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() => super.noSuchMethod(
    Invocation.method(#getApplicationDocumentsPath, []),
    returnValue: Future<String?>.value(),
  );
}
