import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/backup_service.dart';
import 'focusable_settings_tile.dart';

class BackupSettingsPage extends StatefulWidget {
  static const String routeName = 'backup_settings';

  const BackupSettingsPage({super.key});

  @override
  State<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends State<BackupSettingsPage> {
  late Future<List<LauncherBackup>> _backups;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _backups = context.read<BackupService>().listBackups();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final backupService = context.watch<BackupService>();

    return Column(
      children: [
        Text(
          localizations.backupAndRestore,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Divider(),
        Expanded(
          child: FutureBuilder<List<LauncherBackup>>(
            future: _backups,
            builder: (context, snapshot) {
              final backups = snapshot.data ?? const <LauncherBackup>[];
              final latest = backups.isEmpty ? null : backups.first;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    FocusableSettingsTile(
                      autofocus: true,
                      leading: const Icon(Icons.add_to_drive_outlined),
                      title: Text(localizations.createBackup),
                      trailing: backupService.busy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onPressed: backupService.busy ? null : _createBackup,
                    ),
                    FocusableSettingsTile(
                      leading: const Icon(Icons.restore),
                      title: Text(localizations.restoreLatestBackup),
                      trailing: latest == null
                          ? Text(localizations.noBackups)
                          : Text(
                              DateFormat.yMMMd().add_jm().format(
                                latest.createdAt.toLocal(),
                              ),
                            ),
                      onPressed: backupService.busy || latest == null
                          ? null
                          : () => _confirmRestore(latest),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        localizations.backupDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _createBackup() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      await context.read<BackupService>().createBackup();
      if (!mounted) return;
      setState(_refresh);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.backupCreated)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.backupFailed)));
    }
  }

  Future<void> _confirmRestore(LauncherBackup backup) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.restoreBackupTitle),
        content: Text(localizations.restoreBackupWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(localizations.restore),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<BackupService>().restoreBackup(backup);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.backupRestored)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.restoreFailed)));
    }
  }
}
