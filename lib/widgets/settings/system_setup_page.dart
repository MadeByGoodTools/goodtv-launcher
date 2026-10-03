import 'package:flutter/material.dart';
import 'package:goodtv_launcher/flauncher_channel.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:goodtv_launcher/providers/system_setup_service.dart';
import 'package:provider/provider.dart';

import 'focusable_settings_tile.dart';

class SystemSetupPage extends StatefulWidget {
  static const String routeName = 'system_setup';

  const SystemSetupPage({super.key});

  @override
  State<SystemSetupPage> createState() => _SystemSetupPageState();
}

class _SystemSetupPageState extends State<SystemSetupPage>
    with WidgetsBindingObserver {
  late SystemSetupService _service;
  late Future<Map<String, dynamic>> _profile;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _service = SystemSetupService(
      FLauncherChannel(),
      context.read<SettingsService>(),
    );
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(_refresh);
  }

  void _refresh() {
    _profile = _service.inspect();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.configureThisTv,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _profile,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final profile = snapshot.data!;
              final isDefault = profile['isDefaultLauncher'] == true;
              final isFireTv = profile['isFireTv'] == true;
              final redirectEnabled = profile['homeRedirectEnabled'] == true;
              final device = [
                profile['manufacturer'],
                profile['model'],
              ].where((value) => value.toString().trim().isNotEmpty).join(' ');
              return ListView(
                children: [
                  FocusableSettingsTile(
                    autofocus: true,
                    leading: const Icon(Icons.auto_fix_high),
                    title: Text(l10n.applyRecommendedSetup),
                    trailing: _applying
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onPressed: _applying
                        ? null
                        : () => _applyRecommended(profile),
                  ),
                  FocusableSettingsTile(
                    leading: Icon(
                      isDefault || redirectEnabled
                          ? Icons.check_circle
                          : Icons.home_outlined,
                      color: isDefault || redirectEnabled
                          ? Colors.greenAccent
                          : null,
                    ),
                    title: Text(
                      isDefault || redirectEnabled
                          ? l10n.goodTvIsDefaultLauncher
                          : isFireTv
                          ? 'Override Fire TV Home button'
                          : l10n.chooseDefaultLauncher,
                    ),
                    onPressed: isDefault
                        ? _refreshStatus
                        : isFireTv
                        ? () => _setFireRedirect(!redirectEnabled)
                        : _openHomeSettings,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.tv),
                    title: Text(device.isEmpty ? l10n.unknownDevice : device),
                    subtitle: Text(
                      l10n.androidVersionDetected(
                        profile['androidVersion']?.toString() ?? '?',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.systemSetupLimitations,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _applyRecommended(Map<String, dynamic> profile) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _applying = true);
    final preset = await _service.applyRecommended(profile);
    if (!mounted) return;
    setState(() => _applying = false);
    final presetName = preset == DisplayPreset.compact
        ? l10n.displayProfileCompact
        : l10n.displayProfileCinema;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.recommendedSetupApplied(presetName))),
    );
    if (profile['isFireTv'] != true && profile['isDefaultLauncher'] != true) {
      await _openHomeSettings();
    }
    if (mounted) setState(_refresh);
  }

  Future<void> _openHomeSettings() async {
    await _service.openHomeSettings();
  }

  Future<void> _setFireRedirect(bool enabled) async {
    await FLauncherChannel().setHomeRedirectEnabled(enabled);
    if (mounted) setState(_refresh);
  }

  void _refreshStatus() => setState(_refresh);
}
