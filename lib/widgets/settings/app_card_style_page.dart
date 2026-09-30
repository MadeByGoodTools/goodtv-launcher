import 'package:flutter/material.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:provider/provider.dart';

import 'focusable_settings_tile.dart';

class AppCardStylePage extends StatelessWidget {
  static const String routeName = 'app_card_style';

  const AppCardStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsService>();

    return Column(
      children: [
        Text(l10n.appCardStyle, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              _heading(context, l10n.appCardCorners),
              _cornerTile(
                context,
                AppCardCornerStyle.square,
                l10n.appCardCornersSquare,
                settings,
                autofocus: true,
              ),
              _cornerTile(
                context,
                AppCardCornerStyle.soft,
                l10n.appCardCornersSoft,
                settings,
              ),
              _cornerTile(
                context,
                AppCardCornerStyle.rounded,
                l10n.appCardCornersRounded,
                settings,
              ),
              const Divider(),
              _heading(context, l10n.appCardFocusZoom),
              _zoomTile(
                context,
                AppCardFocusZoom.none,
                l10n.appCardFocusZoomNone,
                settings,
              ),
              _zoomTile(
                context,
                AppCardFocusZoom.standard,
                l10n.appCardFocusZoomStandard,
                settings,
              ),
              _zoomTile(
                context,
                AppCardFocusZoom.strong,
                l10n.appCardFocusZoomStrong,
                settings,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heading(BuildContext context, String label) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
    child: Text(label, style: Theme.of(context).textTheme.labelLarge),
  );

  Widget _cornerTile(
    BuildContext context,
    AppCardCornerStyle style,
    String label,
    SettingsService settings, {
    bool autofocus = false,
  }) => FocusableSettingsTile(
    autofocus: autofocus,
    leading: Icon(
      style == AppCardCornerStyle.square
          ? Icons.crop_square
          : style == AppCardCornerStyle.soft
          ? Icons.rounded_corner
          : Icons.rectangle_outlined,
    ),
    title: Text(label),
    trailing: _selection(context, settings.appCardCornerStyle == style),
    onPressed: () => settings.setAppCardCornerStyle(style),
  );

  Widget _zoomTile(
    BuildContext context,
    AppCardFocusZoom zoom,
    String label,
    SettingsService settings,
  ) => FocusableSettingsTile(
    leading: const Icon(Icons.zoom_out_map),
    title: Text(label),
    trailing: _selection(context, settings.appCardFocusZoom == zoom),
    onPressed: () => settings.setAppCardFocusZoom(zoom),
  );

  Widget _selection(BuildContext context, bool selected) => selected
      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
      : const Icon(Icons.circle_outlined);
}
