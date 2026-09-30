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

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';

class FLauncherAboutDialog extends StatelessWidget {
  final PackageInfo packageInfo;

  FLauncherAboutDialog({Key? key, required this.packageInfo})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return AboutDialog(
      applicationName: "GoodTV Launcher",
      applicationVersion:
          "v${packageInfo.version} (${packageInfo.buildNumber})",
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset("assets/icon.png", height: 72),
      ),
      applicationLegalese:
          "Developed by Good Tools\nBased on Arc Launcher, LTvLauncher, and FLauncher\nGNU GPL v3",
      children: [
        SizedBox(height: 24),
        Text(
          localizations.textAboutDialog(
            "https://github.com/meddouribadis/arclauncher",
          ),
        ),
      ],
    );
  }
}
