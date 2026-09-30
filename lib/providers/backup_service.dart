/*
 * GoodTV Launcher backup and restore
 * Copyright (C) 2026 GoodTV Launcher contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../database.dart';
import 'apps_service.dart';
import 'settings_service.dart';
import 'wallpaper_service.dart';

class LauncherBackup {
  final File file;
  final DateTime createdAt;

  const LauncherBackup(this.file, this.createdAt);
}

class BackupService extends ChangeNotifier {
  static const int formatVersion = 1;
  static const int maximumBackups = 5;
  static const List<String> _wallpaperNames = [
    'wallpaper',
    'wallpaper_day',
    'wallpaper_night',
    'wallpaper_video',
    'wallpaper_day_video',
    'wallpaper_night_video',
  ];

  final FLauncherDatabase _database;
  final SettingsService _settings;
  final AppsService _apps;
  final WallpaperService _wallpaper;

  bool _busy = false;
  bool get busy => _busy;

  BackupService(this._database, this._settings, this._apps, this._wallpaper);

  Future<Directory> _backupDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(documents.path, 'backups'));
    await directory.create(recursive: true);
    return directory;
  }

  Future<List<LauncherBackup>> listBackups() async {
    final directory = await _backupDirectory();
    final backups = <LauncherBackup>[];
    await for (final entity in directory.list()) {
      if (entity is! File || !entity.path.endsWith('.arcbackup')) continue;
      final stat = await entity.stat();
      backups.add(LauncherBackup(entity, stat.modified));
    }
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  Future<LauncherBackup> createBackup() => _guard(() async {
    final now = DateTime.now();
    final manifest = <String, dynamic>{
      'formatVersion': formatVersion,
      'createdAt': now.toUtc().toIso8601String(),
      'settings': _settings.exportSettings(),
      'layout': await _database.exportBackupData(),
    };

    final archive = Archive()
      ..addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)));

    final documents = await getApplicationDocumentsDirectory();
    await for (final entity in documents.list()) {
      if (entity is! File) continue;
      final name = path.basename(entity.path);
      if (!_isUserMedia(name)) continue;
      archive.addFile(
        ArchiveFile.bytes('media/$name', await entity.readAsBytes()),
      );
    }

    final encoded = ZipEncoder().encode(archive);
    final directory = await _backupDirectory();
    final stamp = now.toUtc().toIso8601String().replaceAll(':', '-');
    final file = File(
      path.join(directory.path, 'goodtv-launcher-$stamp.arcbackup'),
    );
    await file.writeAsBytes(encoded, flush: true);
    await _pruneOldBackups();
    return LauncherBackup(file, now);
  });

  Future<void> restoreBackup(LauncherBackup backup) => _guard(() async {
    final archive = ZipDecoder().decodeBytes(
      await backup.file.readAsBytes(),
      verify: true,
    );
    final manifestEntry = archive.find('manifest.json');
    final manifestBytes = manifestEntry?.readBytes();
    if (manifestBytes == null)
      throw const FormatException('Backup manifest is missing');

    final manifest = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(manifestBytes)) as Map,
    );
    if (manifest['formatVersion'] != formatVersion) {
      throw const FormatException('This backup version is not supported');
    }

    await _settings.restoreSettings(
      Map<String, dynamic>.from(manifest['settings'] as Map? ?? const {}),
    );
    await _database.restoreBackupData(
      Map<String, dynamic>.from(manifest['layout'] as Map? ?? const {}),
    );

    final documents = await getApplicationDocumentsDirectory();
    await for (final entity in documents.list()) {
      if (entity is File && _isUserMedia(path.basename(entity.path))) {
        await entity.delete();
      }
    }
    for (final entry in archive.files) {
      if (!entry.isFile || !entry.name.startsWith('media/')) continue;
      final name = path.basename(entry.name);
      if (!_isUserMedia(name)) continue;
      final bytes = entry.readBytes();
      if (bytes != null) {
        await File(
          path.join(documents.path, name),
        ).writeAsBytes(bytes, flush: true);
      }
    }

    await _apps.reloadFromStorage();
    await _wallpaper.reloadFromStorage();
  });

  bool _isUserMedia(String name) =>
      _wallpaperNames.contains(name) || name.startsWith('custom_banner_');

  Future<void> _pruneOldBackups() async {
    final backups = await listBackups();
    for (final backup in backups.skip(maximumBackups)) {
      await backup.file.delete();
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    if (_busy) throw StateError('A backup operation is already running');
    _busy = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
