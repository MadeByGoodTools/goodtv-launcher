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

import 'dart:async';

import 'package:goodtv_launcher/widgets/settings/back_button_actions.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const _appHighlightAnimationEnabledKey = "app_highlight_animation_enabled";
const _appKeyClickEnabledKey = "app_key_click_enabled";
const _autoHideAppBar = "auto_hide_app_bar";
const _gradientUuidKey = "gradient_uuid";
const _backButtonAction = "back_button_action";
const _dateFormat = "date_format";
const _showCategoryTitles = "show_category_titles";
const _showAppNamesBelowIcons = "show_app_names_below_icons";
const _showDateInStatusBar = "show_date_in_status_bar";
const _showTimeInStatusBar = "show_time_in_status_bar";
const _timeFormat = "time_format";
const _wifiUsagePeriod = "wifi_usage_period";
const _showWifiWidgetInStatusBar = "show_wifi_widget_in_status_bar";
const String _showNetworkIndicatorInStatusBar =
    "show_network_indicator_in_status_bar";
const String _accentColor = "accent_color";
const String _screensaverClockStyle = "screensaver_clock_style";
const String _screensaverBackground = "screensaver_background";
const String _dockBackdropFilterDisabled = "dock_backdrop_filter_disabled";
const String _backgroundBlurDisabled = "background_blur_disabled";
const String _showWatchNextSection = "show_watch_next_section";
const String _jellyfinServerUrl = "jellyfin_server_url";
const String _jellyfinApiToken = "jellyfin_api_token";
const String _continueWatchingFeedUrl = "continue_watching_feed_url";
const String _dockDarkBackground = "dock_dark_background";
const String _dockShadowEnabled = "dock_shadow_enabled";
const String _showFocusBorders = "show_focus_borders";
const String _displayPreset = "display_preset";
const String _appCardCornerStyle = "app_card_corner_style";
const String _appCardFocusZoom = "app_card_focus_zoom";
const String _appCardSpacing = "app_card_spacing";
const String _wallpaperFeedUrl = "wallpaper_feed_url";
const String _wallpaperFeedIntervalMinutes = "wallpaper_feed_interval_minutes";
const String _idleFadeEnabled = "idle_fade_enabled";
const String _wakeConsumesFirstPress = "wake_consumes_first_press";
const String _defaultAerialFeedUrl =
    'https://sylvan.apple.com/Aerials/2x/entries.json';

enum DisplayPreset { cinema, compact, easyRead }

enum AppCardCornerStyle { square, soft, rounded }

enum AppCardFocusZoom { none, standard, strong }

enum AppCardSpacing { tight, balanced, roomy }

// WiFi usage period options
const String WIFI_USAGE_DAILY = "daily";
const String WIFI_USAGE_WEEKLY = "weekly";
const String WIFI_USAGE_MONTHLY = "monthly";

// Accent color presets (hex values)
const String ACCENT_COLOR_PURPLE = "7C4DFF";
const String ACCENT_COLOR_TEAL = "00BFA5";
const String ACCENT_COLOR_BLUE = "2979FF";
const String ACCENT_COLOR_ORANGE = "FF6D00";
const String ACCENT_COLOR_PINK = "F50057";
const String ACCENT_COLOR_GREEN = "00C853";
const String ACCENT_COLOR_WHITE = "FFFFFF";
const String ACCENT_COLOR_YELLOW = "FFD600";
const String ACCENT_COLOR_RED = "D50000";
const String ACCENT_COLOR_CYAN = "00E5FF";
const String ACCENT_COLOR_INDIGO = "536DFE";
const String ACCENT_COLOR_LIME = "AEEA00";
const String ACCENT_COLOR_AMBER = "FFAB00";
const String ACCENT_COLOR_ROSE = "FF4081";
const String ACCENT_COLOR_ICE_BLUE = "80D8FF";

class SettingsService extends ChangeNotifier {
  static final defaultDateFormat = "EEEE d";
  static final defaultTimeFormat = "H:mm";
  final SharedPreferences _sharedPreferences;

  bool get appHighlightAnimationEnabled =>
      showFocusBorders &&
      (_sharedPreferences.getBool(_appHighlightAnimationEnabledKey) ?? false);

  bool get appKeyClickEnabled =>
      _sharedPreferences.getBool(_appKeyClickEnabledKey) ?? true;

  bool get autoHideAppBarEnabled =>
      _sharedPreferences.getBool(_autoHideAppBar) ?? false;

  bool get showCategoryTitles =>
      _sharedPreferences.getBool(_showCategoryTitles) ?? false;

  bool get showAppNamesBelowIcons =>
      _sharedPreferences.getBool(_showAppNamesBelowIcons) ?? false;

  bool get showDateInStatusBar =>
      _sharedPreferences.getBool(_showDateInStatusBar) ?? false;

  bool get showTimeInStatusBar =>
      _sharedPreferences.getBool(_showTimeInStatusBar) ?? true;

  String? get gradientUuid => _sharedPreferences.getString(_gradientUuidKey);

  String get backButtonAction =>
      _sharedPreferences.getString(_backButtonAction) ??
      BACK_BUTTON_ACTION_NOTHING;

  String get dateFormat =>
      _sharedPreferences.getString(_dateFormat) ?? defaultDateFormat;

  String get timeFormat =>
      _sharedPreferences.getString(_timeFormat) ?? defaultTimeFormat;

  String get wifiUsagePeriod =>
      _sharedPreferences.getString(_wifiUsagePeriod) ?? WIFI_USAGE_DAILY;

  bool get showWifiWidgetInStatusBar =>
      _sharedPreferences.getBool(_showWifiWidgetInStatusBar) ?? false;

  bool get showNetworkIndicatorInStatusBar =>
      _sharedPreferences.getBool(_showNetworkIndicatorInStatusBar) ?? true;

  String get accentColorHex =>
      _sharedPreferences.getString(_accentColor) ?? ACCENT_COLOR_WHITE;

  String get screensaverClockStyle =>
      _sharedPreferences.getString(_screensaverClockStyle) ?? "minimal";
  String get screensaverBackground =>
      _sharedPreferences.getString(_screensaverBackground) ?? "launcher";

  bool get dockBackdropFilterDisabled =>
      _sharedPreferences.getBool(_dockBackdropFilterDisabled) ?? true;

  bool get backgroundBlurDisabled =>
      _sharedPreferences.getBool(_backgroundBlurDisabled) ?? true;

  bool get showWatchNextSection =>
      _sharedPreferences.getBool(_showWatchNextSection) ?? true;

  bool get idleFadeEnabled =>
      _sharedPreferences.getBool(_idleFadeEnabled) ?? true;

  bool get wakeConsumesFirstPress =>
      _sharedPreferences.getBool(_wakeConsumesFirstPress) ?? true;

  String? get jellyfinServerUrl {
    final value = _sharedPreferences.getString(_jellyfinServerUrl)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? get jellyfinApiToken {
    final value = _sharedPreferences.getString(_jellyfinApiToken)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  bool get jellyfinConfigured =>
      jellyfinServerUrl != null && jellyfinApiToken != null;

  String? get continueWatchingFeedUrl {
    final value = _sharedPreferences
        .getString(_continueWatchingFeedUrl)
        ?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  bool get dockDarkBackground =>
      _sharedPreferences.getBool(_dockDarkBackground) ?? true;

  bool get dockShadowEnabled =>
      _sharedPreferences.getBool(_dockShadowEnabled) ?? false;

  bool get showFocusBorders =>
      _sharedPreferences.getBool(_showFocusBorders) ?? true;

  DisplayPreset? get displayPreset {
    final value = _sharedPreferences.getString(_displayPreset);
    for (final preset in DisplayPreset.values) {
      if (preset.name == value) return preset;
    }
    return null;
  }

  AppCardCornerStyle get appCardCornerStyle {
    final value = _sharedPreferences.getString(_appCardCornerStyle);
    return AppCardCornerStyle.values.firstWhere(
      (style) => style.name == value,
      orElse: () => AppCardCornerStyle.soft,
    );
  }

  double get appCardCornerRadius => switch (appCardCornerStyle) {
    AppCardCornerStyle.square => 0,
    AppCardCornerStyle.soft => 12,
    AppCardCornerStyle.rounded => 24,
  };

  AppCardFocusZoom get appCardFocusZoom {
    final value = _sharedPreferences.getString(_appCardFocusZoom);
    return AppCardFocusZoom.values.firstWhere(
      (zoom) => zoom.name == value,
      orElse: () => AppCardFocusZoom.standard,
    );
  }

  double get appCardFocusScale => switch (appCardFocusZoom) {
    AppCardFocusZoom.none => 1,
    AppCardFocusZoom.standard => 1.05,
    AppCardFocusZoom.strong => 1.12,
  };

  AppCardSpacing get appCardSpacing {
    final value = _sharedPreferences.getString(_appCardSpacing);
    return AppCardSpacing.values.firstWhere(
      (spacing) => spacing.name == value,
      orElse: () => AppCardSpacing.balanced,
    );
  }

  double get appCardHorizontalSpacing => switch (appCardSpacing) {
    AppCardSpacing.tight => 6,
    AppCardSpacing.balanced => 12,
    AppCardSpacing.roomy => 18,
  };

  double get appCardVerticalSpacing => switch (appCardSpacing) {
    AppCardSpacing.tight => 4,
    AppCardSpacing.balanced => 9,
    AppCardSpacing.roomy => 14,
  };

  String? get wallpaperFeedUrl {
    if (!_sharedPreferences.containsKey(_wallpaperFeedUrl)) {
      return _defaultAerialFeedUrl;
    }
    final value = _sharedPreferences.getString(_wallpaperFeedUrl);
    return value == null || value.isEmpty ? null : value;
  }

  int get wallpaperFeedIntervalMinutes =>
      _sharedPreferences.getInt(_wallpaperFeedIntervalMinutes) ?? 15;

  Color get accentColor {
    final hex = accentColorHex;
    return Color(int.parse("0xFF$hex"));
  }

  SettingsService(this._sharedPreferences);

  Map<String, Object> exportSettings() {
    final values = <String, Object>{};
    for (final key in _sharedPreferences.getKeys()) {
      final value = _sharedPreferences.get(key);
      if (value is bool ||
          value is int ||
          value is double ||
          value is String ||
          value is List<String>) {
        values[key] = value as Object;
      }
    }
    return values;
  }

  Future<void> restoreSettings(Map<String, dynamic> values) async {
    await _sharedPreferences.clear();
    for (final entry in values.entries) {
      final value = entry.value;
      if (value is bool) {
        await _sharedPreferences.setBool(entry.key, value);
      } else if (value is int) {
        await _sharedPreferences.setInt(entry.key, value);
      } else if (value is double) {
        await _sharedPreferences.setDouble(entry.key, value);
      } else if (value is String) {
        await _sharedPreferences.setString(entry.key, value);
      } else if (value is List) {
        await _sharedPreferences.setStringList(entry.key, value.cast<String>());
      }
    }
    notifyListeners();
  }

  Future<void> set(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
    notifyListeners();
  }

  Future<void> setAppHighlightAnimationEnabled(bool value) async {
    if (value && !showFocusBorders) {
      return;
    }
    return set(_appHighlightAnimationEnabledKey, value);
  }

  Future<void> setAppKeyClickEnabled(bool value) async {
    return set(_appKeyClickEnabledKey, value);
  }

  Future<void> setAutoHideAppBarEnabled(bool value) async {
    return set(_autoHideAppBar, value);
  }

  Future<void> setGradientUuid(String value) async {
    await _sharedPreferences.setString(_gradientUuidKey, value);
    notifyListeners();
  }

  Future<void> setBackButtonAction(String value) async {
    await _sharedPreferences.setString(_backButtonAction, value);
    notifyListeners();
  }

  Future<void> setDateTimeFormat(
    String dateFormatString,
    String timeFormatString,
  ) async {
    await Future.wait([
      _sharedPreferences.setString(_dateFormat, dateFormatString),
      _sharedPreferences.setString(_timeFormat, timeFormatString),
    ]);
    notifyListeners();
  }

  Future<void> setShowCategoryTitles(bool show) async {
    return set(_showCategoryTitles, show);
  }

  Future<void> setShowAppNamesBelowIcons(bool show) async {
    return set(_showAppNamesBelowIcons, show);
  }

  Future<void> setShowDateInStatusBar(bool show) async {
    return set(_showDateInStatusBar, show);
  }

  Future<void> setShowTimeInStatusBar(bool show) async {
    return set(_showTimeInStatusBar, show);
  }

  Future<void> setWifiUsagePeriod(String period) async {
    await _sharedPreferences.setString(_wifiUsagePeriod, period);
    notifyListeners();
  }

  Future<void> setShowWifiWidgetInStatusBar(bool show) async {
    return set(_showWifiWidgetInStatusBar, show);
  }

  Future<void> setShowNetworkIndicatorInStatusBar(bool show) async {
    return set(_showNetworkIndicatorInStatusBar, show);
  }

  Future<void> setAccentColor(String colorHex) async {
    await _sharedPreferences.setString(_accentColor, colorHex);
    notifyListeners();
  }

  Future<void> setScreensaverClockStyle(String style) async {
    await _sharedPreferences.setString(_screensaverClockStyle, style);
    notifyListeners();
  }

  Future<void> setScreensaverBackground(String background) async {
    await _sharedPreferences.setString(_screensaverBackground, background);
    notifyListeners();
  }

  Future<void> setDockBackdropFilterDisabled(bool value) async {
    return set(_dockBackdropFilterDisabled, value);
  }

  Future<void> setBackgroundBlurDisabled(bool value) async {
    return set(_backgroundBlurDisabled, value);
  }

  Future<void> setShowWatchNextSection(bool value) async {
    return set(_showWatchNextSection, value);
  }

  Future<void> setIdleFadeEnabled(bool value) async {
    return set(_idleFadeEnabled, value);
  }

  Future<void> setWakeConsumesFirstPress(bool value) async {
    return set(_wakeConsumesFirstPress, value);
  }

  Future<void> setJellyfinConnection(String serverUrl, String apiToken) async {
    final normalizedUrl = serverUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    await _sharedPreferences.setString(_jellyfinServerUrl, normalizedUrl);
    await _sharedPreferences.setString(_jellyfinApiToken, apiToken.trim());
    notifyListeners();
  }

  Future<void> clearJellyfinConnection() async {
    await _sharedPreferences.remove(_jellyfinServerUrl);
    await _sharedPreferences.remove(_jellyfinApiToken);
    notifyListeners();
  }

  Future<void> setContinueWatchingFeed(String? url) async {
    final value = url?.trim() ?? '';
    if (value.isEmpty) {
      await _sharedPreferences.remove(_continueWatchingFeedUrl);
    } else {
      await _sharedPreferences.setString(_continueWatchingFeedUrl, value);
    }
    notifyListeners();
  }

  Future<void> setDockDarkBackground(bool value) async {
    return set(_dockDarkBackground, value);
  }

  Future<void> setDockShadowEnabled(bool value) async {
    return set(_dockShadowEnabled, value);
  }

  Future<void> setShowFocusBorders(bool value) async {
    await set(_showFocusBorders, value);
    if (!value) {
      await setAppHighlightAnimationEnabled(false);
    }
  }

  Future<void> setAppCardCornerStyle(AppCardCornerStyle style) async {
    await _sharedPreferences.setString(_appCardCornerStyle, style.name);
    notifyListeners();
  }

  Future<void> setAppCardFocusZoom(AppCardFocusZoom zoom) async {
    await _sharedPreferences.setString(_appCardFocusZoom, zoom.name);
    notifyListeners();
  }

  Future<void> setAppCardSpacing(AppCardSpacing spacing) async {
    await _sharedPreferences.setString(_appCardSpacing, spacing.name);
    notifyListeners();
  }

  Future<void> setWallpaperFeed(String? url, int intervalMinutes) async {
    if (url == null || url.trim().isEmpty) {
      await _sharedPreferences.setString(_wallpaperFeedUrl, '');
    } else {
      await _sharedPreferences.setString(_wallpaperFeedUrl, url.trim());
    }
    await _sharedPreferences.setInt(
      _wallpaperFeedIntervalMinutes,
      intervalMinutes.clamp(1, 1440),
    );
    notifyListeners();
  }

  Future<void> applyDisplayPreset(DisplayPreset preset) async {
    final values = switch (preset) {
      DisplayPreset.cinema => <String, bool>{
        _autoHideAppBar: true,
        _showCategoryTitles: false,
        _showAppNamesBelowIcons: false,
        _showDateInStatusBar: false,
        _showTimeInStatusBar: false,
        _showWatchNextSection: true,
        _dockBackdropFilterDisabled: false,
        _backgroundBlurDisabled: false,
        _dockDarkBackground: true,
        _dockShadowEnabled: true,
        _showFocusBorders: true,
        _appHighlightAnimationEnabledKey: true,
      },
      DisplayPreset.compact => <String, bool>{
        _autoHideAppBar: true,
        _showCategoryTitles: true,
        _showAppNamesBelowIcons: false,
        _showDateInStatusBar: true,
        _showTimeInStatusBar: true,
        _showWatchNextSection: true,
        _dockBackdropFilterDisabled: true,
        _backgroundBlurDisabled: true,
        _dockDarkBackground: true,
        _dockShadowEnabled: false,
        _showFocusBorders: true,
        _appHighlightAnimationEnabledKey: false,
      },
      DisplayPreset.easyRead => <String, bool>{
        _autoHideAppBar: false,
        _showCategoryTitles: true,
        _showAppNamesBelowIcons: true,
        _showDateInStatusBar: true,
        _showTimeInStatusBar: true,
        _showWatchNextSection: false,
        _dockBackdropFilterDisabled: true,
        _backgroundBlurDisabled: true,
        _dockDarkBackground: true,
        _dockShadowEnabled: false,
        _showFocusBorders: true,
        _appHighlightAnimationEnabledKey: true,
      },
    };

    await Future.wait([
      for (final entry in values.entries)
        _sharedPreferences.setBool(entry.key, entry.value),
      _sharedPreferences.setString(_displayPreset, preset.name),
      _sharedPreferences.setString(_accentColor, switch (preset) {
        DisplayPreset.cinema => ACCENT_COLOR_GREEN,
        DisplayPreset.compact => ACCENT_COLOR_GREEN,
        DisplayPreset.easyRead => ACCENT_COLOR_YELLOW,
      }),
      _sharedPreferences.setString(_appCardCornerStyle, switch (preset) {
        DisplayPreset.cinema => AppCardCornerStyle.rounded.name,
        DisplayPreset.compact => AppCardCornerStyle.rounded.name,
        DisplayPreset.easyRead => AppCardCornerStyle.soft.name,
      }),
      _sharedPreferences.setString(_appCardFocusZoom, switch (preset) {
        DisplayPreset.cinema => AppCardFocusZoom.strong.name,
        DisplayPreset.compact => AppCardFocusZoom.standard.name,
        DisplayPreset.easyRead => AppCardFocusZoom.strong.name,
      }),
      _sharedPreferences.setString(_appCardSpacing, switch (preset) {
        DisplayPreset.cinema => AppCardSpacing.roomy.name,
        DisplayPreset.compact => AppCardSpacing.balanced.name,
        DisplayPreset.easyRead => AppCardSpacing.balanced.name,
      }),
    ]);
    notifyListeners();
  }

  Future<void> applyGoodTvRecommendedDefaults() async {
    await Future.wait([
      _sharedPreferences.setBool(_idleFadeEnabled, true),
      _sharedPreferences.setBool(_wakeConsumesFirstPress, true),
      _sharedPreferences.setBool(_showNetworkIndicatorInStatusBar, true),
      _sharedPreferences.setBool(_showWifiWidgetInStatusBar, false),
      _sharedPreferences.setBool(_appKeyClickEnabledKey, true),
      _sharedPreferences.setString(_screensaverBackground, 'launcher'),
      _sharedPreferences.setString(_wallpaperFeedUrl, _defaultAerialFeedUrl),
      _sharedPreferences.setInt(_wallpaperFeedIntervalMinutes, 15),
    ]);
    notifyListeners();
  }

  bool get timeBasedWallpaperEnabled =>
      _sharedPreferences.getBool("time_based_wallpaper_enabled") ?? false;

  Future<void> setTimeBasedWallpaperEnabled(bool enabled) async {
    await _sharedPreferences.setBool("time_based_wallpaper_enabled", enabled);
    notifyListeners();
  }
}
