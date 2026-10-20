import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../local_wallpaper_collection.dart';
import '../../providers/settings_service.dart';
import '../../providers/wallpaper_service.dart';
import '../../snoopy_seasons.dart';
import 'focusable_settings_tile.dart';

class LocalVideoCollections extends StatefulWidget {
  const LocalVideoCollections({super.key});

  @override
  State<LocalVideoCollections> createState() => _LocalVideoCollectionsState();
}

class _LocalVideoCollectionsState extends State<LocalVideoCollections> {
  late final _collections = prepareBundledWallpaperCollections();
  late final _catalogue = loadSnoopyCatalogue();
  bool _saving = false;

  Future<void> _select(LocalWallpaperCollection collection) async {
    setState(() => _saving = true);
    try {
      await context.read<WallpaperService>().configureLocalVideoCollection(
        collection,
      );
      if (!mounted) return;
      final settings = context.read<SettingsService>();
      await settings.setBackgroundBlurDisabled(true);
      await settings.setIdleFadeEnabled(true);
      await settings.setScreensaverBackground('launcher');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${collection.name} selected for wallpaper and screensaver',
          ),
        ),
      );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load this video collection')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<LocalWallpaperCollection>>(
    future: _collections,
    builder: (context, snapshot) {
      final collections = snapshot.data ?? const <LocalWallpaperCollection>[];
      final selected = context.watch<SettingsService>().wallpaperFeedUrl;
      return Column(
        children: [
          for (final collection in collections) ...[
            FocusableSettingsTile(
              leading: const Icon(Icons.video_library_outlined),
              title: Text(
                '${collection.name} · ${collection.videos.length} clips',
              ),
              trailing: selected == collection.directory.uri.toString()
                  ? const Icon(Icons.check_circle_outline)
                  : const Text('Use both'),
              onPressed: _saving ? null : () => _select(collection),
            ),
            if (collection.name.toLowerCase() == 'snoopy')
              FutureBuilder<SnoopyCatalogue>(
                future: _catalogue,
                builder: (context, data) {
                  final settings = context.watch<SettingsService>();
                  final automatic = settings.automaticSnoopySeasons;
                  final date = DateTime.now();
                  final catalogue = data.data;
                  final unlocked = collection.videos
                      .where(
                        (file) =>
                            !automatic ||
                            catalogue == null ||
                            catalogue.fileUnlocked(
                              file.uri.pathSegments.last,
                              date,
                            ),
                      )
                      .length;
                  final themes = catalogue
                      ?.activeThemes(date)
                      .where((theme) => theme != SnoopyTheme.yearRound)
                      .map((theme) => theme.label)
                      .join(', ');
                  return FocusableSettingsTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Automatic seasons · Canada'),
                        Text(
                          automatic
                              ? '$unlocked/${collection.videos.length} clips unlocked · Everyday${themes == null || themes.isEmpty ? '' : ' + $themes'}'
                              : 'All ${collection.videos.length} clips available year-round',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const Text(
                          'Uses the local date, not live weather.',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    trailing: ExcludeFocus(
                      child: IgnorePointer(
                        child: Switch(
                          value: automatic,
                          onChanged: settings.setAutomaticSnoopySeasons,
                        ),
                      ),
                    ),
                    onPressed: () =>
                        settings.setAutomaticSnoopySeasons(!automatic),
                  );
                },
              ),
          ],
        ],
      );
    },
  );
}
