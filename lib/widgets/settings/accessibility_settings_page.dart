import 'package:flutter/material.dart';
import 'package:goodtv_launcher/flauncher_channel.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:goodtv_launcher/widgets/settings/back_button_action_page.dart';
import 'package:provider/provider.dart';

class AccessibilitySettingsPage extends StatelessWidget {
  static const String routeName = 'accessibility_settings';

  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) => Column(
        children: [
          Text(
            'Accessibility & remote',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                SwitchListTile(
                  autofocus: true,
                  secondary: const Icon(Icons.visibility_outlined),
                  title: const Text('Strong focus outlines'),
                  subtitle: const Text('Clearly show the selected button'),
                  value: settings.showFocusBorders,
                  onChanged: settings.setShowFocusBorders,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.animation_outlined),
                  title: const Text('Focus animation'),
                  subtitle: const Text('Turn off to reduce motion'),
                  value: settings.appHighlightAnimationEnabled,
                  onChanged: settings.showFocusBorders
                      ? settings.setAppHighlightAnimationEnabled
                      : null,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.label_outline),
                  title: const Text('Show app names'),
                  value: settings.showAppNamesBelowIcons,
                  onChanged: settings.setShowAppNamesBelowIcons,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: const Text('Button feedback'),
                  subtitle: const Text(
                    'Play feedback when moving or selecting',
                  ),
                  value: settings.appKeyClickEnabled,
                  onChanged: settings.setAppKeyClickEnabled,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.wallpaper_outlined),
                  title: const Text('Background-only after 2 minutes'),
                  subtitle: const Text('Fade controls away when inactive'),
                  value: settings.idleFadeEnabled,
                  onChanged: settings.setIdleFadeEnabled,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.touch_app_outlined),
                  title: const Text('First button only wakes'),
                  subtitle: const Text(
                    'Prevents an accidental launch when leaving idle mode',
                  ),
                  value: settings.wakeConsumesFirstPress,
                  onChanged: settings.setWakeConsumesFirstPress,
                ),
                const _HomeLauncherToggle(),
                ListTile(
                  leading: const Icon(Icons.keyboard_return),
                  title: const Text('Override Back button'),
                  subtitle: const Text(
                    'Do nothing, show clock, or screensaver',
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(BackButtonActionPage.routeName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLauncherToggle extends StatefulWidget {
  const _HomeLauncherToggle();

  @override
  State<_HomeLauncherToggle> createState() => _HomeLauncherToggleState();
}

class _HomeLauncherToggleState extends State<_HomeLauncherToggle> {
  bool _isDefault = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final isDefault = await FLauncherChannel().isDefaultLauncher();
    if (!mounted) return;
    setState(() {
      _isDefault = isDefault;
      _checking = false;
    });
  }

  Future<void> _changeDefault(bool _) async {
    await FLauncherChannel().openHomeSettings();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: const Icon(Icons.home_outlined),
    title: const Text('Use GoodTV as main launcher'),
    subtitle: Text(
      _checking
          ? 'Checking the current Home launcher…'
          : _isDefault
          ? 'Home button returns to GoodTV'
          : 'Select GoodTV in the Fire TV Home launcher step',
    ),
    value: _isDefault,
    onChanged: _checking ? null : _changeDefault,
  );
}
