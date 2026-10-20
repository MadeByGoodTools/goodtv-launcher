import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/local_wallpaper_collection.dart';

void main() {
  test('collection reads only nonempty MP4 clips in stable order', () async {
    final root = await Directory.systemTemp.createTemp('goodtv-collection-');
    addTearDown(() => root.delete(recursive: true));
    final collection = await Directory('${root.path}/Snoopy').create();
    await File('${collection.path}/b.mp4').writeAsBytes([1]);
    await File('${collection.path}/a.MP4').writeAsBytes([2]);
    await File('${collection.path}/empty.mp4').create();
    await File('${collection.path}/sources.md').writeAsString('source');
    final result = await readWallpaperCollection(root, collection);
    expect(result.name, 'Snoopy');
    expect(result.videos.map((file) => file.uri.pathSegments.last), [
      'a.MP4',
      'b.mp4',
    ]);
  });

  test('collection cannot escape the app collection root', () async {
    final root = await Directory.systemTemp.createTemp('goodtv-collection-');
    final outside = await Directory.systemTemp.createTemp('goodtv-outside-');
    addTearDown(() => root.delete(recursive: true));
    addTearDown(() => outside.delete(recursive: true));
    await Link('${root.path}/escape').create(outside.path);
    await expectLater(
      readWallpaperCollection(root, Directory('${root.path}/escape')),
      throwsFormatException,
    );
  });
}
