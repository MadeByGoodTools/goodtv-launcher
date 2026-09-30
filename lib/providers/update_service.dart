import 'dart:convert';
import 'dart:io';

import 'package:goodtv_launcher/flauncher_channel.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateResult {
  final bool updateAvailable;
  final String currentVersion;
  final String latestVersion;
  final String? releaseNotes;
  final String? apkUrl;
  final String? apkName;

  const UpdateResult({
    required this.updateAvailable,
    required this.currentVersion,
    required this.latestVersion,
    this.releaseNotes,
    this.apkUrl,
    this.apkName,
  });
}

class DownloadedApk {
  final String path;
  final String version;

  const DownloadedApk({required this.path, required this.version});
}

/// ABI-split APKs are named like `goodtv-launcher-1.0.5-arm64-v8a.apk`.
/// Universal builds omit the ABI suffix (`goodtv-launcher-1.0.5.apk`).
bool isAbiSplitApk(String name) {
  return RegExp(
    r"-(arm64-v8a|armeabi-v7a|armeabi|x86_64|x86)\.apk$",
    caseSensitive: false,
  ).hasMatch(name);
}

/// Prefers a universal APK asset; falls back to the first APK if none match.
({String name, String url})? pickReleaseApk(List<dynamic> assets) {
  String? fallbackName;
  String? fallbackUrl;

  for (final asset in assets) {
    if (asset is! Map) {
      continue;
    }

    final name = asset["name"];
    final downloadUrl = asset["browser_download_url"];
    if (name is! String || downloadUrl is! String) {
      continue;
    }
    if (!name.toLowerCase().endsWith(".apk")) {
      continue;
    }

    if (isAbiSplitApk(name)) {
      fallbackName ??= name;
      fallbackUrl ??= downloadUrl;
      continue;
    }

    return (name: name, url: downloadUrl);
  }

  if (fallbackName != null && fallbackUrl != null) {
    return (name: fallbackName, url: fallbackUrl);
  }
  return null;
}

class UpdateService {
  static const String _owner = "MadeByGoodTools";
  static const String _repo = "goodtv-launcher";
  final FLauncherChannel _fLauncherChannel;

  UpdateService({FLauncherChannel? fLauncherChannel})
    : _fLauncherChannel = fLauncherChannel ?? FLauncherChannel();

  Future<UpdateResult> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final release = await _fetchLatestStableRelease();

    final latestVersion = _normalizeVersion(release.tagName);
    final updateAvailable = _compareVersions(latestVersion, currentVersion) > 0;

    return UpdateResult(
      updateAvailable: updateAvailable,
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      releaseNotes: release.body,
      apkUrl: release.apkDownloadUrl,
      apkName: release.apkName,
    );
  }

  Future<DownloadedApk> downloadApk(UpdateResult update) async {
    if (!update.updateAvailable || update.apkUrl == null) {
      throw StateError("No update APK available to download.");
    }

    final uri = Uri.parse(update.apkUrl!);
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, "application/octet-stream");
      request.headers.set(
        HttpHeaders.userAgentHeader,
        "GoodTVLauncher-Updater",
      );
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          "APK download failed with status ${response.statusCode}",
          uri: uri,
        );
      }

      final directory = await getApplicationSupportDirectory();
      final updatesDirectory = Directory("${directory.path}/updates");
      if (!await updatesDirectory.exists()) {
        await updatesDirectory.create(recursive: true);
      }

      final fileName =
          update.apkName ?? "goodtv-launcher-${update.latestVersion}.apk";
      final file = File("${updatesDirectory.path}/$fileName");
      await response.pipe(file.openWrite());
      return DownloadedApk(path: file.path, version: update.latestVersion);
    } finally {
      httpClient.close();
    }
  }

  Future<bool> installApk(String apkPath) {
    return _fLauncherChannel.installApk(apkPath);
  }

  Future<void> requestInstallUnknownAppsPermission() {
    return _fLauncherChannel.requestInstallUnknownAppsPermission();
  }

  Future<_GitHubRelease> _fetchLatestStableRelease() async {
    final uri = Uri.parse(
      "https://api.github.com/repos/$_owner/$_repo/releases",
    );
    final httpClient = HttpClient();

    try {
      final request = await httpClient.getUrl(uri);
      request.headers.set(
        HttpHeaders.acceptHeader,
        "application/vnd.github+json",
      );
      request.headers.set(
        HttpHeaders.userAgentHeader,
        "GoodTVLauncher-Updater",
      );

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          "GitHub release check failed with status ${response.statusCode}",
          uri: uri,
        );
      }

      final body = await utf8.decodeStream(response);
      final parsed = jsonDecode(body);
      if (parsed is! List) {
        throw const FormatException("Unexpected releases response format.");
      }

      for (final releaseData in parsed) {
        if (releaseData is! Map<String, dynamic>) {
          continue;
        }
        if ((releaseData["draft"] as bool?) ?? false) {
          continue;
        }
        if ((releaseData["prerelease"] as bool?) ?? false) {
          continue;
        }

        final tagName = releaseData["tag_name"] as String?;
        final releaseBody = releaseData["body"] as String?;
        final assets = releaseData["assets"];
        if (tagName == null || assets is! List) {
          continue;
        }

        final apk = pickReleaseApk(assets);
        if (apk == null) {
          continue;
        }

        return _GitHubRelease(
          tagName: tagName,
          body: releaseBody,
          apkName: apk.name,
          apkDownloadUrl: apk.url,
        );
      }

      throw StateError("No stable release with an APK asset was found.");
    } finally {
      httpClient.close();
    }
  }

  String _normalizeVersion(String version) {
    var normalized = version.trim();
    if (normalized.startsWith("v") || normalized.startsWith("V")) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  int _compareVersions(String left, String right) {
    final leftParts = _versionParts(left);
    final rightParts = _versionParts(right);
    final maxLength = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var i = 0; i < maxLength; i++) {
      final leftValue = i < leftParts.length ? leftParts[i] : 0;
      final rightValue = i < rightParts.length ? rightParts[i] : 0;
      if (leftValue != rightValue) {
        return leftValue.compareTo(rightValue);
      }
    }
    return 0;
  }

  List<int> _versionParts(String version) {
    return _normalizeVersion(version)
        .split(".")
        .map(
          (part) => int.tryParse(part.replaceAll(RegExp(r"[^0-9]"), "")) ?? 0,
        )
        .toList();
  }
}

class _GitHubRelease {
  final String tagName;
  final String? body;
  final String apkName;
  final String apkDownloadUrl;

  const _GitHubRelease({
    required this.tagName,
    required this.body,
    required this.apkName,
    required this.apkDownloadUrl,
  });
}
