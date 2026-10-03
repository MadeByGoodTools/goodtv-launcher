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
  static const _redditPresets = <String, String>{
    'Earth & landscapes': 'EarthPorn',
    'Space': 'spaceporn',
    'City views': 'CityPorn',
    'Cozy rooms': 'CozyPlaces',
  };
  late final TextEditingController _urlController;
  late int _intervalMinutes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsService>();
    _urlController = TextEditingController(text: settings.wallpaperFeedUrl);
    _intervalMinutes = settings.wallpaperFeedIntervalMinutes;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _redditPresets.entries
                .map(
                  (preset) => ActionChip(
                    avatar: const Icon(Icons.reddit, size: 20),
                    label: Text('Reddit: ${preset.key}'),
                    onPressed: () {
                      _urlController.text =
                          'https://www.reddit.com/r/${preset.value}/.rss?limit=50';
                    },
                  ),
                )
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: l.wallpaperFeedUrl,
              hintText: 'https://example.com/aerials.json',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
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
          autofocus: true,
          leading: _saving
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_download_outlined),
          title: Text(l.connectWallpaperFeed),
          onPressed: _saving ? null : _save,
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
              if (mounted) _urlController.clear();
            },
          ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await context.read<WallpaperService>().configureRemoteFeed(
        _urlController.text,
        _intervalMinutes,
      );
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
}
