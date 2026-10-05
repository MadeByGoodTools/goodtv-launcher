import 'package:goodtv_launcher/widgets/settings/settings_panel.dart';
import 'package:goodtv_launcher/widgets/settings/applications_panel_page.dart';
import 'package:goodtv_launcher/widgets/focus_keyboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodtv_launcher/flauncher_channel.dart';

import '../providers/launcher_state.dart';
import '../providers/network_service.dart';
import '../providers/settings_service.dart';
import '../models/category.dart';
import 'daily_wifi_usage_widget.dart';
import 'date_time_widget.dart';
import 'network_widget.dart';

class FocusAwareAppBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?>? onCategorySelected;

  const FocusAwareAppBar({
    Key? key,
    this.categories = const [],
    this.selectedCategoryId,
    this.onCategorySelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FocusAwareAppBarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class FocusAwareAppBarState extends State<FocusAwareAppBar> {
  bool focused = false;
  late FocusNode _settingsFocusNode;

  @override
  void initState() {
    super.initState();
    _settingsFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _settingsFocusNode.dispose();
    super.dispose();
  }

  void focusSettings() {
    _settingsFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsService, bool>(
      selector: (_, settings) => settings.autoHideAppBarEnabled,
      builder: (context, autoHide, appBar) {
        if (autoHide) {
          return Focus(
            canRequestFocus: false,
            child: SizedBox(
              // Keep the toolbar's layout extent fixed. Only its pixels move,
              // so Watch Next and the Dock never jump when it auto-hides.
              height: kToolbarHeight,
              child: ClipRect(
                child: AnimatedSlide(
                  offset: focused ? Offset.zero : const Offset(0, -1),
                  curve: Curves.decelerate,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedOpacity(
                    opacity: focused ? 1 : 0,
                    duration: const Duration(milliseconds: 120),
                    child: appBar!,
                  ),
                ),
              ),
            ),
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                context.read<LauncherState>().setAppGridFocused(false);
              }
              this.setState(() {
                focused = hasFocus;
              });
            },
          );
        }

        return appBar!;
      },
      child: RepaintBoundary(
        child: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          // Left side: Settings, Network indicator, WiFi usage
          title: Row(
            children: [
              _FocusableIconButton(
                icon: Icons.search_rounded,
                tooltip: 'Search apps',
                onPressed: () => _showAppSearch(context),
              ),
              const SizedBox(width: 10),
              // Settings button (moved to left side)
              _FocusableIconButton(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                focusNode: _settingsFocusNode,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const SettingsPanel(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryButton(
                        label: 'Home',
                        selected: widget.selectedCategoryId == null,
                        onPressed: () => widget.onCategorySelected?.call(null),
                      ),
                      ...widget.categories.map(
                        (category) => _CategoryButton(
                          label: _categoryLabel(category),
                          selected: widget.selectedCategoryId == category.id,
                          onPressed: () =>
                              widget.onCategorySelected?.call(category.id),
                          onLongPress: category.name == 'All Apps'
                              ? () => showDialog<void>(
                                  context: context,
                                  builder: (_) => const SettingsPanel(
                                    initialRoute:
                                        ApplicationsPanelPage.dockRouteName,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Network indicator (conditionally shown)
              Selector<SettingsService, bool>(
                selector: (_, settings) =>
                    settings.showNetworkIndicatorInStatusBar,
                builder: (context, showNetwork, _) => showNetwork
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _FocusableNetworkWidget(),
                      )
                    : const SizedBox.shrink(),
              ),
              // WiFi usage widget
              Selector<SettingsService, bool>(
                selector: (_, settings) => settings.showWifiWidgetInStatusBar,
                builder: (context, showWifi, _) => showWifi
                    ? const DailyWifiUsageWidget()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          // Right side: Date/Time only
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 32),
              child:
                  Selector<
                    SettingsService,
                    ({
                      bool showDateInStatusBar,
                      bool showTimeInStatusBar,
                      String dateFormat,
                      String timeFormat,
                    })
                  >(
                    selector: (context, service) => (
                      showDateInStatusBar: service.showDateInStatusBar,
                      showTimeInStatusBar: service.showTimeInStatusBar,
                      dateFormat: service.dateFormat,
                      timeFormat: service.timeFormat,
                    ),
                    builder: (context, dateTimeSettings, _) {
                      // Define standard text style
                      const textStyle = TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      );

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Date
                          if (dateTimeSettings.showDateInStatusBar)
                            DateTimeWidget(
                              dateTimeSettings.dateFormat,
                              key: const Key("statusbar_date"),
                              updateInterval: const Duration(minutes: 1),
                              textStyle: textStyle,
                            ),

                          if (dateTimeSettings.showDateInStatusBar &&
                              dateTimeSettings.showTimeInStatusBar)
                            const SizedBox(width: 16),

                          // Clock
                          if (dateTimeSettings.showTimeInStatusBar)
                            DateTimeWidget(
                              dateTimeSettings.timeFormat,
                              key: const Key("statusbar_clock"),
                              updateInterval: const Duration(minutes: 1),
                              textStyle: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(Category category) {
    if (category.name == 'Favorites' || category.name == 'Dock') {
      return 'Dock 1';
    }
    return category.name;
  }
}

Future<void> _showAppSearch(BuildContext context) async {
  try {
    final channel = FLauncherChannel();
    final aptoideInstalled = await channel.applicationExists('cm.aptoidetv.pt');
    if (!aptoideInstalled) {
      if (!context.mounted) return;
      final install = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Install an app store?'),
          content: const Text(
            'GoodTV uses Aptoide TV for app search. It is not installed on this TV yet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton.icon(
              autofocus: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Install Aptoide TV'),
            ),
          ],
        ),
      );
      if (install == true) {
        final opened = await channel.openAptoideInstaller();
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No browser or Downloader app was found.'),
            ),
          );
        }
      }
      return;
    }

    final opened = await channel.searchAppstore('');
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No compatible app store was found on this device.'),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search could not open. Please try again.'),
        ),
      );
    }
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FocusKeyboardListener(
      onPressed: (key) {
        if (!longPressableKeys.contains(key)) return KeyEventResult.ignored;
        onPressed();
        return KeyEventResult.handled;
      },
      onLongPress: onLongPress == null
          ? null
          : (_) {
              onLongPress!();
              return KeyEventResult.handled;
            },
      child: TextButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: selected ? Colors.white24 : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    ),
  );
}

/// Reusable focusable icon button with consistent outline focus indicator
class _FocusableIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final FocusNode? focusNode;
  final String? tooltip;

  const _FocusableIconButton({
    required this.icon,
    required this.onPressed,
    this.focusNode,
    this.tooltip,
  });

  @override
  State<_FocusableIconButton> createState() => _FocusableIconButtonState();
}

class _FocusableIconButtonState extends State<_FocusableIconButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onPressed(),
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) => widget.onPressed(),
        ),
      },
      child: Focus(
        focusNode: widget.focusNode,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            context.read<LauncherState>().setAppGridFocused(false);
          }
          setState(() => _focused = hasFocus);
        },
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(4), // Match network indicator padding
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: _focused
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
              boxShadow: _focused
                  ? const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Tooltip(
              message: widget.tooltip ?? '',
              child: Icon(
                widget.icon,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Network widget with consistent focus indicator
class _FocusableNetworkWidget extends StatefulWidget {
  @override
  State<_FocusableNetworkWidget> createState() =>
      _FocusableNetworkWidgetState();
}

class _FocusableNetworkWidgetState extends State<_FocusableNetworkWidget> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    void openNetworks() => context.read<NetworkService>().openWifiSettings();
    return Actions(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => openNetworks(),
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) => openNetworks(),
        ),
      },
      child: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            context.read<LauncherState>().setAppGridFocused(false);
          }
          setState(() => _focused = hasFocus);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: _focused
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
            boxShadow: _focused
                ? const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: NetworkWidget(onPressed: openNetworks),
        ),
      ),
    );
  }
}
