/*
 * FLauncher
 * Copyright (C) 2024 LeanBitLab
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

import 'package:flutter/material.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';
import 'focusable_settings_tile.dart';
import 'brightness_settings_page.dart';
import 'date_time_format_page.dart';
import 'back_button_action_page.dart';
import 'wifi_usage_period_page.dart';
import 'screensaver_clock_style_page.dart';
import 'backup_settings_page.dart';
import 'system_setup_page.dart';
import 'pin_protection_page.dart';

class GeneralSettingsPage extends StatelessWidget {
  static const String routeName = "general_settings_panel";

  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          localizations.system,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FocusableSettingsTile(
                  autofocus: true,
                  leading: const Icon(Icons.auto_fix_high),
                  title: Text(
                    localizations.configureThisTv,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(SystemSetupPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(
                    localizations.pinProtection,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(PinProtectionPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.brightness_6),
                  title: Text(
                    localizations.brightnessScheduler,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(BrightnessSettingsPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.screenshot_monitor),
                  title: Text(
                    localizations.screensaverSettings,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(ScreensaverClockStylePage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(
                    localizations.dateAndTimeFormat,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(DateTimeFormatPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.arrow_back),
                  title: Text(
                    localizations.backButtonAction,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(BackButtonActionPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.settings_backup_restore),
                  title: Text(
                    localizations.backupAndRestore,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(BackupSettingsPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.wifi),
                  title: Text(
                    localizations.wifiUsagePeriod,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(WifiUsagePeriodPage.routeName),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
