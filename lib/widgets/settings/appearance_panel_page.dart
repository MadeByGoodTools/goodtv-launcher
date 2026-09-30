import 'package:goodtv_launcher/l10n/app_localizations.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:goodtv_launcher/widgets/rounded_switch_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_card_style_page.dart';
import 'focusable_settings_tile.dart';

class AppearancePanelPage extends StatelessWidget {
  static const String routeName = "appearance_panel";

  const AppearancePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settingsService = Provider.of<SettingsService>(context);

    return Column(
      children: [
        Text(
          localizations.appearanceSettings,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FocusableSettingsTile(
                autofocus: true,
                leading: const Icon(Icons.style_outlined),
                title: Text(
                  localizations.appCardStyle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppCardStylePage.routeName),
              ),
              RoundedSwitchListTile(
                value: !settingsService.dockBackdropFilterDisabled,
                onChanged: (value) =>
                    settingsService.setDockBackdropFilterDisabled(!value),
                title: Text(
                  localizations.dockBlur,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: const Icon(Icons.blur_circular),
              ),
              RoundedSwitchListTile(
                value: !settingsService.backgroundBlurDisabled,
                onChanged: (value) =>
                    settingsService.setBackgroundBlurDisabled(!value),
                title: Text(
                  localizations.backgroundBlur,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: const Icon(Icons.blur_on),
              ),
              RoundedSwitchListTile(
                value: settingsService.dockShadowEnabled,
                onChanged: settingsService.setDockShadowEnabled,
                title: Text(
                  localizations.dockShadow,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: const Icon(Icons.layers),
              ),
              RoundedSwitchListTile(
                value: settingsService.dockDarkBackground,
                onChanged: settingsService.setDockDarkBackground,
                title: Text(
                  localizations.dockDarkBackground,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: const Icon(Icons.dark_mode),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
