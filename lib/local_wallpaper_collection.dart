import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class LocalWallpaperCollection {
  final String name;
  final Directory directory;
  final List<File> videos;

  const LocalWallpaperCollection(this.name, this.directory, this.videos);
}

Future<Directory> wallpaperCollectionsDirectory() async {
  final base = Platform.isAndroid
      ? await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory()
      : await getApplicationDocumentsDirectory();
  return Directory(
    '${base.path}/wallpaper_collections',
  ).create(recursive: true);
}

Future<LocalWallpaperCollection> readWallpaperCollection(
  Directory root,
  Directory directory,
) async {
  final rootPath = await root.resolveSymbolicLinks();
  final collectionPath = await directory.resolveSymbolicLinks();
  if (!collectionPath.startsWith('$rootPath${Platform.pathSeparator}')) {
    throw const FormatException('Choose a folder in GoodTV video collections');
  }
  final videos = <File>[];
  await for (final entry in directory.list(followLinks: false)) {
    if (entry is File &&
        entry.path.toLowerCase().endsWith('.mp4') &&
        await entry.length() > 0)
      videos.add(entry);
  }
  videos.sort((a, b) => a.path.compareTo(b.path));
  return LocalWallpaperCollection(
    directory.uri.pathSegments.where((part) => part.isNotEmpty).last,
    directory,
    List.unmodifiable(videos),
  );
}

Future<List<LocalWallpaperCollection>> discoverWallpaperCollections() async {
  final root = await wallpaperCollectionsDirectory();
  final collections = <LocalWallpaperCollection>[];
  await for (final entry in root.list(followLinks: false)) {
    if (entry is! Directory) continue;
    final collection = await readWallpaperCollection(root, entry);
    if (collection.videos.isNotEmpty) collections.add(collection);
  }
  collections.sort((a, b) => a.name.compareTo(b.name));
  return collections;
}

/// Extract packaged videos once into app-owned storage for native decoding.
/// Subsequent launches reuse those files and do not need a network connection.
Future<List<LocalWallpaperCollection>>
prepareBundledWallpaperCollections() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  const prefix = 'assets/video_collections/';
  final videos = manifest.listAssets().where(
    (asset) => asset.startsWith(prefix) && asset.toLowerCase().endsWith('.mp4'),
  );
  final root = await wallpaperCollectionsDirectory();
  for (final asset in videos) {
    final relativePath = asset.substring(prefix.length);
    final segments = relativePath.split('/');
    if (segments.length != 2 ||
        segments.any((part) => part.isEmpty || part == '..'))
      continue;
    final output = File('${root.path}/$relativePath');
    if (await output.exists() && await output.length() > 0) continue;
    await output.parent.create(recursive: true);
    final data = await rootBundle.load(asset);
    final temporary = File('${output.path}.part');
    await temporary.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    await temporary.rename(output.path);
  }
  return discoverWallpaperCollections();
}
