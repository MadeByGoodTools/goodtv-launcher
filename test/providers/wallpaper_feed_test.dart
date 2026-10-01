import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/providers/wallpaper_service.dart';

void main() {
  group('parseWallpaperFeed', () {
    test('reads Overflight-style JSON and prefers 1080p video', () {
      final items = parseWallpaperFeed('''[
          {
            "title": "Coast",
            "url_img": "preview.jpg",
            "url_1080p": "https://media.example/coast.mp4",
            "url_4k": "https://media.example/coast-4k.mp4"
          }
        ]''', Uri.parse('https://feeds.example/aerials.json'));

      expect(items, hasLength(1));
      expect(items.single.title, 'Coast');
      expect(items.single.uri.toString(), 'https://media.example/coast.mp4');
      expect(items.single.isVideo, isTrue);
    });

    test('reads M3U playlists and ignores metadata', () {
      final items = parseWallpaperFeed(
        '#EXTM3U\n#EXTINF:-1,Mountains\nmountains.mp4\nclouds.jpg',
        Uri.parse('https://feeds.example/backgrounds/list.m3u'),
      );

      expect(items, hasLength(2));
      expect(
        items.first.uri.toString(),
        'https://feeds.example/backgrounds/mountains.mp4',
      );
      expect(items.first.isVideo, isTrue);
      expect(items.last.isVideo, isFalse);
    });

    test('accepts a single direct media URL', () {
      final items = parseWallpaperFeed(
        'https://media.example/forest.webp',
        Uri.parse('https://feeds.example/feed.txt'),
      );

      expect(items.single.uri.toString(), 'https://media.example/forest.webp');
      expect(items.single.isVideo, isFalse);
    });
  });
}
