import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/providers/watch_next_service.dart';

void main() {
  test('parses Jellyfin resume items into launcher tiles', () {
    final items = WatchNextService.parseJellyfinResumeItems(
      {
        'Items': [
          {
            'Id': 'episode-42',
            'Name': 'The Return',
            'SeriesName': 'Example Show',
            'Overview': 'An episode description',
            'PrimaryImageAspectRatio': 1.78,
            'UserData': {'PlayedPercentage': 37.6},
          },
        ],
      },
      serverUrl: 'http://media.local:8096',
      token: 'secret',
    );

    expect(items, hasLength(1));
    expect(items.single.title, 'Example Show — The Return');
    expect(items.single.packageName, 'org.jellyfin.androidtv');
    expect(items.single.contentId, 'episode-42');
    expect(items.single.progressPercent, 38);
    expect(
      items.single.posterUri,
      contains('/Items/episode-42/Images/Primary'),
    );
  });
}
