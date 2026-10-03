import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:goodtv_launcher/providers/watch_next_service.dart';
import 'package:goodtv_launcher/widgets/rounded_switch_list_tile.dart';
import 'package:goodtv_launcher/widgets/settings/focusable_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';

class MiscPanelPage extends StatelessWidget {
  static const String routeName = "misc_panel";

  const MiscPanelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    SettingsService settingsService = Provider.of(context);

    return Column(
      children: [
        Text(
          localizations.miscellaneous,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              RoundedSwitchListTile(
                autofocus: true,
                value: settingsService.appHighlightAnimationEnabled,
                onChanged: (value) =>
                    settingsService.setAppHighlightAnimationEnabled(value),
                title: Text(
                  localizations.appCardHighlightAnimation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: Icon(Icons.filter_center_focus),
              ),
              RoundedSwitchListTile(
                value: settingsService.appKeyClickEnabled,
                onChanged: (value) =>
                    settingsService.setAppKeyClickEnabled(value),
                title: Text(
                  localizations.appKeyClick,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: Icon(Icons.notifications_active),
              ),
              RoundedSwitchListTile(
                value: settingsService.showCategoryTitles,
                onChanged: (value) =>
                    settingsService.setShowCategoryTitles(value),
                title: Text(
                  localizations.showCategoryTitles,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: Icon(Icons.abc),
              ),
              RoundedSwitchListTile(
                value: settingsService.showAppNamesBelowIcons,
                onChanged: (value) =>
                    settingsService.setShowAppNamesBelowIcons(value),
                title: Text(
                  localizations.showAppNamesBelowIcons,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: Icon(Icons.subtitles),
              ),
              RoundedSwitchListTile(
                value: settingsService.showFocusBorders,
                onChanged: (value) =>
                    settingsService.setShowFocusBorders(value),
                title: Text(
                  localizations.showFocusBorders,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: Icon(Icons.border_outer),
              ),
              RoundedSwitchListTile(
                value: settingsService.showWatchNextSection,
                onChanged: (value) async {
                  await settingsService.setShowWatchNextSection(value);
                  if (value && context.mounted) {
                    final watchNextService = context.read<WatchNextService>();
                    if (!watchNextService.hasPermission) {
                      await watchNextService.requestPermission();
                    }
                  }
                },
                title: Text(
                  localizations.showWatchNextSection,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: Icon(Icons.play_circle_outline),
              ),
              if (settingsService.showWatchNextSection)
                Consumer<WatchNextService>(
                  builder: (context, watchNextService, _) {
                    if (watchNextService.hasPermission) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                localizations.watchNextPermissionTitle,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizations.watchNextPermissionBody,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    watchNextService.requestPermission(),
                                icon: const Icon(Icons.lock_open),
                                label: Text(
                                  localizations.watchNextGrantPermission,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => watchNextService
                                    .refreshPermissionAndItems(),
                                icon: const Icon(Icons.refresh),
                                label: Text(
                                  localizations.watchNextCheckPermission,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              FocusableSettingsTile(
                leading: const Icon(Icons.video_library_outlined),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jellyfin Continue Watching'),
                    Text(
                      settingsService.jellyfinConfigured
                          ? 'Connected • refreshes automatically at startup'
                          : 'Connect Jellyfin to fill Watch Next automatically',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onPressed: () => _showJellyfinSetup(context),
              ),
              FocusableSettingsTile(
                leading: const Icon(Icons.hub_outlined),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Other streaming service'),
                    Text(
                      settingsService.continueWatchingFeedUrl == null
                          ? 'Connect a compatible Continue Watching feed'
                          : 'Custom feed connected',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onPressed: () => _showProviderFeedSetup(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showJellyfinSetup(BuildContext context) async {
    final settings = context.read<SettingsService>();
    final serverController = TextEditingController(
      text: settings.jellyfinServerUrl,
    );
    final tokenController = TextEditingController(
      text: settings.jellyfinApiToken,
    );
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Connect Jellyfin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serverController,
              autofocus: true,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Server address',
                hintText: 'http://192.168.1.20:8096',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tokenController,
              obscureText: true,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'API token'),
            ),
          ],
        ),
        actions: [
          if (settings.jellyfinConfigured)
            TextButton(
              onPressed: () async {
                await settings.clearJellyfinConnection();
                if (dialogContext.mounted) Navigator.pop(dialogContext, false);
              },
              child: const Text('Disconnect'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    if (save == true && context.mounted) {
      await settings.setJellyfinConnection(
        serverController.text,
        tokenController.text,
      );
      if (context.mounted) {
        await context.read<WatchNextService>().refreshPermissionAndItems();
      }
    }
    serverController.dispose();
    tokenController.dispose();
  }

  Future<void> _showProviderFeedSetup(BuildContext context) async {
    final settings = context.read<SettingsService>();
    final controller = TextEditingController(
      text: settings.continueWatchingFeedUrl,
    );
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Connect streaming service'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Continue Watching feed URL',
            hintText: 'https://example.com/watch-next.json',
          ),
        ),
        actions: [
          if (settings.continueWatchingFeedUrl != null)
            TextButton(
              onPressed: () async {
                await settings.setContinueWatchingFeed(null);
                if (dialogContext.mounted) Navigator.pop(dialogContext, false);
              },
              child: const Text('Disconnect'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    if (save == true && context.mounted) {
      await settings.setContinueWatchingFeed(controller.text);
      if (context.mounted) {
        await context.read<WatchNextService>().refreshPermissionAndItems();
      }
    }
    controller.dispose();
  }
}
