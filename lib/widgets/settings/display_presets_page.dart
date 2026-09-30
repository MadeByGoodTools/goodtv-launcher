import 'package:flutter/material.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:provider/provider.dart';

import 'focusable_settings_tile.dart';

class DisplayPresetsPage extends StatelessWidget {
  static const String routeName = 'display_presets';

  const DisplayPresetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsService>();

    return Column(
      children: [
        Text(
          localizations.displayProfiles,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              _presetTile(
                context,
                preset: DisplayPreset.cinema,
                icon: Icons.movie_filter_outlined,
                title: localizations.displayProfileCinema,
                description: localizations.displayProfileCinemaDescription,
                autofocus: true,
                selected: settings.displayPreset == DisplayPreset.cinema,
              ),
              _presetTile(
                context,
                preset: DisplayPreset.compact,
                icon: Icons.dashboard_customize_outlined,
                title: localizations.displayProfileCompact,
                description: localizations.displayProfileCompactDescription,
                selected: settings.displayPreset == DisplayPreset.compact,
              ),
              _presetTile(
                context,
                preset: DisplayPreset.easyRead,
                icon: Icons.visibility_outlined,
                title: localizations.displayProfileEasyRead,
                description: localizations.displayProfileEasyReadDescription,
                selected: settings.displayPreset == DisplayPreset.easyRead,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  localizations.displayProfilesDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _presetTile(
    BuildContext context, {
    required DisplayPreset preset,
    required IconData icon,
    required String title,
    required String description,
    required bool selected,
    bool autofocus = false,
  }) {
    return FocusableSettingsTile(
      autofocus: autofocus,
      leading: Icon(icon),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 3),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      trailing: selected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(Icons.circle_outlined),
      onPressed: () async {
        await context.read<SettingsService>().applyDisplayPreset(preset);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.displayProfileApplied(title),
            ),
          ),
        );
      },
    );
  }
}
