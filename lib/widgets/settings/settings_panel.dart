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

import 'package:goodtv_launcher/widgets/side_panel_dialog.dart';
import 'package:goodtv_launcher/widgets/settings/applications_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/launcher_sections_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/gradient_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/launcher_section_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/settings_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/status_bar_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/wallpaper_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/online_wallpaper_page.dart';
import 'package:goodtv_launcher/widgets/settings/wifi_usage_period_page.dart';
import 'package:goodtv_launcher/widgets/settings/back_button_action_page.dart';
import 'package:goodtv_launcher/widgets/settings/date_time_format_page.dart';
import 'package:goodtv_launcher/widgets/settings/app_details_page.dart';
import 'package:goodtv_launcher/widgets/settings/accent_color_page.dart';
import 'package:goodtv_launcher/widgets/settings/brightness_settings_page.dart';
import 'package:goodtv_launcher/widgets/settings/appearance_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/misc_panel_page.dart';
import 'package:goodtv_launcher/widgets/settings/interface_settings_page.dart';
import 'package:goodtv_launcher/widgets/settings/general_settings_page.dart';
import 'package:goodtv_launcher/widgets/settings/screensaver_clock_style_page.dart';
import 'package:goodtv_launcher/widgets/settings/backup_settings_page.dart';
import 'package:goodtv_launcher/widgets/settings/display_presets_page.dart';
import 'package:goodtv_launcher/widgets/settings/app_card_style_page.dart';
import 'package:goodtv_launcher/widgets/settings/system_setup_page.dart';
import 'package:goodtv_launcher/widgets/settings/pin_protection_page.dart';
import 'package:goodtv_launcher/widgets/settings/accessibility_settings_page.dart';
import 'package:goodtv_launcher/providers/pin_service.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:goodtv_launcher/models/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPanel extends StatefulWidget {
  final String? initialRoute;

  const SettingsPanel({Key? key, this.initialRoute}) : super(key: key);

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final pinService = context.watch<PinService>();
    if (pinService.enabled && !_unlocked) {
      return _SettingsPinGate(
        onUnlocked: () => setState(() => _unlocked = true),
      );
    }
    return WillPopScope(
      onWillPop: () async => !await _navigatorKey.currentState!.maybePop(),
      child: Scaffold(
        backgroundColor: Colors.black54, // Dim the background
        body: Stack(
          children: [
            // Tap outside to close
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
            // The side panel
            SidePanelDialog(
              width: 350,
              isRightSide: false,
              child: Navigator(
                key: _navigatorKey,
                initialRoute:
                    widget.initialRoute ?? SettingsPanelPage.routeName,
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case SettingsPanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => SettingsPanelPage(),
                      );
                    case GeneralSettingsPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => GeneralSettingsPage(),
                      );
                    case InterfaceSettingsPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => InterfaceSettingsPage(),
                      );
                    case WallpaperPanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => WallpaperPanelPage(),
                      );
                    case OnlineWallpaperPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const OnlineWallpaperPage(),
                      );
                    case StatusBarPanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => StatusBarPanelPage(),
                      );
                    case GradientPanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => GradientPanelPage(),
                      );
                    case ApplicationsPanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => ApplicationsPanelPage(),
                      );
                    case ApplicationsPanelPage.dockRouteName:
                      return _FastPageRoute(
                        builder: (_) =>
                            const ApplicationsPanelPage(initialTabIndex: 1),
                      );
                    case LauncherSectionsPanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => LauncherSectionsPanelPage(),
                      );
                    case LauncherSectionPanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => LauncherSectionPanelPage(
                          sectionIndex: settings.arguments as int?,
                        ),
                      );
                    case WifiUsagePeriodPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => WifiUsagePeriodPage(),
                      );
                    case BackButtonActionPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => BackButtonActionPage(),
                      );
                    case DateTimeFormatPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => DateTimeFormatPage(),
                      );
                    case AppearancePanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const AppearancePanelPage(),
                      );
                    case MiscPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => MiscPanelPage());
                    case ScreensaverClockStylePage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const ScreensaverClockStylePage(),
                      );
                    case AccentColorPage.routeName:
                      return _FastPageRoute(builder: (_) => AccentColorPage());
                    case BrightnessSettingsPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => BrightnessSettingsPage(),
                      );
                    case BackupSettingsPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const BackupSettingsPage(),
                      );
                    case DisplayPresetsPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const DisplayPresetsPage(),
                      );
                    case AppCardStylePage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const AppCardStylePage(),
                      );
                    case SystemSetupPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const SystemSetupPage(),
                      );
                    case PinProtectionPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const PinProtectionPage(),
                      );
                    case AccessibilitySettingsPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => const AccessibilitySettingsPage(),
                      );
                    case AppDetailsPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => AppDetailsPage(
                          application: settings.arguments as App,
                        ),
                      );
                    default:
                      throw ArgumentError.value(
                        settings.name,
                        "settings.name",
                        "Route not supported.",
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPinGate extends StatefulWidget {
  final VoidCallback onUnlocked;

  const _SettingsPinGate({required this.onUnlocked});

  @override
  State<_SettingsPinGate> createState() => _SettingsPinGateState();
}

class _SettingsPinGateState extends State<_SettingsPinGate> {
  final _controller = TextEditingController();
  bool _incorrect = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
          SidePanelDialog(
            width: 350,
            isRightSide: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(l10n.settingsLocked),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 8,
                    onSubmitted: (_) => _unlock(),
                    decoration: InputDecoration(
                      labelText: l10n.enterPin,
                      errorText: _incorrect ? l10n.incorrectPin : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _unlock,
                    child: Text(l10n.unlockSettings),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _unlock() {
    if (context.read<PinService>().verify(_controller.text)) {
      widget.onUnlocked();
    } else {
      setState(() => _incorrect = true);
    }
  }
}

/// A faster page route with a 150ms slide transition instead of
/// the default 300ms Material transition.
class _FastPageRoute<T> extends MaterialPageRoute<T> {
  _FastPageRoute({required super.builder});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 120);
}
