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

//import 'dart:html';

import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

//import '../mocks.mocks.dart';

void main() async {
  SharedPreferencesStorePlatform.instance =
      InMemorySharedPreferencesStore.empty();
  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsService = SettingsService(sharedPreferences);

  setUp(() async {
    await sharedPreferences.clear();
  });

  test("setUse24HourTimeFormat", () async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final settingsService = SettingsService(sharedPreferences);
    final expected = "XYZ";

    await settingsService.setDateTimeFormat("", expected);

    expect(settingsService.timeFormat, expected);
  });

  test("setGradientUuid", () async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final settingsService = SettingsService(sharedPreferences);

    await settingsService.setGradientUuid(
      "4730aa2d-1a90-49a6-9942-ffe82f470e26",
    );

    expect(
      sharedPreferences.getString("gradient_uuid"),
      "4730aa2d-1a90-49a6-9942-ffe82f470e26",
    );
  });

  group("getGradientUuid", () {
    test("without uuid from shared preferences", () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      final settingsService = SettingsService(sharedPreferences);

      final gradientUuid = settingsService.gradientUuid;

      expect(gradientUuid, null);
    });

    test("with uuid from shared preferences", () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      sharedPreferences.setString(
        "gradient_uuid",
        "4730aa2d-1a90-49a6-9942-ffe82f470e26",
      );
      final settingsService = SettingsService(sharedPreferences);

      final gradientUuid = settingsService.gradientUuid;

      expect(gradientUuid, "4730aa2d-1a90-49a6-9942-ffe82f470e26");
    });
  });

  group("getDateFormat", () {
    test("with default", () async {
      expect(settingsService.dateFormat, SettingsService.defaultDateFormat);
    });

    test("with value set", () async {
      final expected = "XYZ";

      settingsService.setDateTimeFormat(expected, "");

      expect(settingsService.dateFormat, expected);
    });
  });

  group("display presets", () {
    test("cinema applies a media-first profile", () async {
      await settingsService.applyDisplayPreset(DisplayPreset.cinema);

      expect(settingsService.displayPreset, DisplayPreset.cinema);
      expect(settingsService.autoHideAppBarEnabled, isTrue);
      expect(settingsService.showWatchNextSection, isTrue);
      expect(settingsService.showAppNamesBelowIcons, isFalse);
      expect(settingsService.backgroundBlurDisabled, isFalse);
      expect(settingsService.accentColorHex, ACCENT_COLOR_GREEN);
      expect(settingsService.appCardCornerStyle, AppCardCornerStyle.rounded);
      expect(settingsService.appCardFocusZoom, AppCardFocusZoom.strong);
    });

    test("easy read keeps labels and status information visible", () async {
      await settingsService.applyDisplayPreset(DisplayPreset.easyRead);

      expect(settingsService.displayPreset, DisplayPreset.easyRead);
      expect(settingsService.showCategoryTitles, isTrue);
      expect(settingsService.showAppNamesBelowIcons, isTrue);
      expect(settingsService.showDateInStatusBar, isTrue);
      expect(settingsService.showTimeInStatusBar, isTrue);
      expect(settingsService.accentColorHex, ACCENT_COLOR_YELLOW);
    });

    test("card style controls persist custom choices", () async {
      await settingsService.setAppCardCornerStyle(AppCardCornerStyle.square);
      await settingsService.setAppCardFocusZoom(AppCardFocusZoom.none);

      expect(settingsService.appCardCornerRadius, 0);
      expect(settingsService.appCardFocusScale, 1);
    });
  });
}
