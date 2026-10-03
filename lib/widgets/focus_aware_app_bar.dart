import 'package:goodtv_launcher/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodtv_launcher/flauncher_channel.dart';

import '../providers/launcher_state.dart';
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
      builder: (context, autoHide, widget) {
        if (autoHide) {
          return Focus(
            canRequestFocus: false,
            child: AnimatedContainer(
              curve: Curves.decelerate,
              duration: Duration(milliseconds: 150),
              height: focused ? kToolbarHeight : 0,
              child: widget!,
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

        return widget!;
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
                          label: category.name,
                          selected: widget.selectedCategoryId == category.id,
                          onPressed: () =>
                              widget.onCategorySelected?.call(category.id),
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
}

Future<void> _showAppSearch(BuildContext context) async {
  var typedQuery = '';
  const keys = <String>[
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];
  final query = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Search apps'),
        content: SizedBox(
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  typedQuery.isEmpty ? 'Choose letters below' : typedQuery,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: typedQuery.isEmpty ? Colors.white54 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var index = 0; index < keys.length; index++)
                      SizedBox(
                        width: 52,
                        height: 42,
                        child: FilledButton.tonal(
                          autofocus: index == 0,
                          onPressed: () =>
                              setDialogState(() => typedQuery += keys[index]),
                          child: Text(keys[index]),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: typedQuery.isEmpty
                ? null
                : () => setDialogState(() {
                    typedQuery = typedQuery.substring(0, typedQuery.length - 1);
                  }),
            icon: const Icon(Icons.backspace_outlined),
            label: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => setDialogState(() => typedQuery += ' '),
            child: const Text('Space'),
          ),
          FilledButton.icon(
            onPressed: typedQuery.trim().isEmpty
                ? null
                : () => Navigator.of(dialogContext).pop(typedQuery.trim()),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Find & install'),
          ),
        ],
      ),
    ),
  );
  if (query == null || query.isEmpty) return;
  await FLauncherChannel().searchAppstore(query);
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: selected ? Colors.white24 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
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
    return Focus(
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
        child: const NetworkWidget(),
      ),
    );
  }
}
