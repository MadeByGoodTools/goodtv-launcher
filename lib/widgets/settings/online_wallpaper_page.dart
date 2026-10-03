import 'package:flutter/material.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:goodtv_launcher/providers/wallpaper_service.dart';
import 'package:goodtv_launcher/widgets/settings/focusable_settings_tile.dart';
import 'package:provider/provider.dart';

class OnlineWallpaperPage extends StatefulWidget {
  static const routeName = 'online_wallpaper';

  const OnlineWallpaperPage({super.key});

  @override
  State<OnlineWallpaperPage> createState() => _OnlineWallpaperPageState();
}

class _OnlineWallpaperPageState extends State<OnlineWallpaperPage> {
  static const _appleAerialFeed =
      'https://sylvan.apple.com/Aerials/2x/entries.json';
  static const _redditPresets = <String, String>{
    'Earth & landscapes': 'EarthPorn',
    'Space': 'spaceporn',
    'City views': 'CityPorn',
    'Cozy rooms': 'CozyPlaces',
  };
  late int _intervalMinutes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsService>();
    _intervalMinutes = settings.wallpaperFeedIntervalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final wallpaper = context.watch<WallpaperService>();
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Text(l.onlineWallpaper, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Text(l.onlineWallpaperDescription),
        ),
        FocusableSettingsTile(
          autofocus: true,
          leading: const Icon(Icons.airplay_rounded),
          title: const Text('Apple TV Aerials'),
          trailing: const Text('Use background'),
          onPressed: _saving ? null : () => _applyPreset(_appleAerialFeed),
        ),
        ..._redditPresets.entries.map(
          (preset) => FocusableSettingsTile(
            leading: const Icon(Icons.reddit),
            title: Text('Reddit: ${preset.key}'),
            trailing: const Text('Use background'),
            onPressed: _saving
                ? null
                : () => _applyPreset(
                    'https://www.reddit.com/r/${preset.value}/.rss?limit=50',
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<int>(
            initialValue: _intervalMinutes,
            decoration: InputDecoration(
              labelText: l.changeBackgroundEvery,
              border: const OutlineInputBorder(),
            ),
            items: const [5, 15, 30, 60, 180]
                .map(
                  (minutes) => DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes min'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _intervalMinutes = value);
            },
          ),
        ),
        FocusableSettingsTile(
          leading: const Icon(Icons.link),
          title: const Text('Custom background feed URL'),
          trailing: const Text('Advanced'),
          onPressed: _saving ? null : _showCustomFeedDialog,
        ),
        if (wallpaper.remoteFeedEnabled) ...[
          FocusableSettingsTile(
            leading: const Icon(Icons.skip_next),
            title: Text(l.nextWallpaper),
            onPressed: wallpaper.nextRemoteWallpaper,
          ),
          FocusableSettingsTile(
            leading: const Icon(Icons.link_off),
            title: Text(l.disableOnlineWallpaper),
            onPressed: () async {
              await wallpaper.disableRemoteFeed();
            },
          ),
        ],
      ],
    );
  }

  Future<void> _applyPreset(String url) async {
    final l = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await context.read<WallpaperService>().configureRemoteFeed(
        url,
        _intervalMinutes,
      );
      // Cinematic sources should remain crisp; the optional focus blur makes
      // high-resolution photography look soft on a large television.
      await context.read<SettingsService>().setBackgroundBlurDisabled(true);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.wallpaperFeedConnected)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.wallpaperFeedError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showCustomFeedDialog() async {
    final controller = TextEditingController(
      text: context.read<SettingsService>().wallpaperFeedUrl,
    );
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom background feed'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Feed URL',
            hintText: 'https://example.com/backgrounds.json',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url != null && url.trim().isNotEmpty && mounted) {
      await _applyPreset(url);
    }
  }
}
