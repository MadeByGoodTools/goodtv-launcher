import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/snoopy_seasons.dart';

void main() {
  final catalogue = SnoopyCatalogue.parse(
    File('assets/video_collections/Snoopy/catalog.json').readAsStringSync(),
  );

  test('catalogue covers 65 distinct assets and source files', () {
    expect(catalogue.clips.length, 65);
    expect(catalogue.clips.map((clip) => clip.id).toSet().length, 65);
    expect(catalogue.clips.map((clip) => clip.filename).toSet().length, 65);
  });

  test('everyday clips remain available on every date including leap day', () {
    for (
      var date = DateTime(2028);
      date.year == 2028;
      date = DateTime(date.year, date.month, date.day + 1)
    ) {
      final available = catalogue.clips
          .where((clip) => clip.unlocked(date))
          .toList();
      expect(available.length, greaterThan(1), reason: date.toString());
      for (final clip in catalogue.clips.where(
        (clip) => clip.themes.contains(SnoopyTheme.yearRound),
      )) {
        expect(available, contains(clip));
      }
    }
  });

  test('Canadian season windows and shoulder-season overlap', () {
    for (var month = 1; month <= 12; month++) {
      final date = DateTime(2026, month, 15);
      expect(
        snoopyThemeUnlocked(SnoopyTheme.spring, date),
        month >= 3 && month <= 5,
      );
      expect(
        snoopyThemeUnlocked(SnoopyTheme.summer, date),
        month >= 6 && month <= 8,
      );
      expect(
        snoopyThemeUnlocked(SnoopyTheme.autumn, date),
        month >= 9 && month <= 11,
      );
      expect(
        snoopyThemeUnlocked(SnoopyTheme.winter, date),
        month >= 11 || month <= 3,
      );
    }
  });

  test('holiday and New Year windows cross the year boundary correctly', () {
    expect(
      snoopyThemeUnlocked(SnoopyTheme.holidays, DateTime(2026, 11, 30)),
      isFalse,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.holidays, DateTime(2026, 12, 1)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.holidays, DateTime(2027, 1, 6)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.holidays, DateTime(2027, 1, 7)),
      isFalse,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.newYear, DateTime(2026, 12, 25)),
      isFalse,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.newYear, DateTime(2026, 12, 26)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.newYear, DateTime(2027, 1, 7)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.newYear, DateTime(2027, 1, 8)),
      isFalse,
    );
  });

  test('Canadian Thanksgiving is in October, not US November', () {
    expect(
      snoopyThemeUnlocked(SnoopyTheme.thanksgiving, DateTime(2026, 10, 14)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.thanksgiving, DateTime(2026, 10, 15)),
      isFalse,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.thanksgiving, DateTime(2026, 11, 26)),
      isFalse,
    );
    // In 2024 the second Monday is October 14, not October 12.
    expect(
      snoopyThemeUnlocked(SnoopyTheme.thanksgiving, DateTime(2024, 10, 16)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.thanksgiving, DateTime(2024, 10, 17)),
      isFalse,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.canadaDay, DateTime(2026, 7, 1)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.canadaDay, DateTime(2026, 7, 4)),
      isFalse,
    );
  });

  test('Halloween and Valentines lock outside their windows', () {
    expect(
      snoopyThemeUnlocked(SnoopyTheme.halloween, DateTime(2026, 9, 30)),
      isFalse,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.halloween, DateTime(2026, 10, 1)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.halloween, DateTime(2026, 11, 2)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.halloween, DateTime(2026, 11, 3)),
      isFalse,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.valentines, DateTime(2026, 2, 14)),
      isTrue,
    );
    expect(
      snoopyThemeUnlocked(SnoopyTheme.valentines, DateTime(2026, 2, 16)),
      isFalse,
    );
  });

  test('unknown user files are year round, malformed catalogue is rejected', () {
    expect(catalogue.fileUnlocked('my-video.mp4', DateTime(2026, 7)), isTrue);
    expect(
      () => SnoopyCatalogue.parse('{"version":2,"clips":[]}'),
      throwsFormatException,
    );
    expect(
      () => SnoopyCatalogue.parse(
        '{"version":1,"clips":[{"id":"101_AS001","sourceId":"../bad.mp4","themes":["winter"]}]}',
      ),
      throwsFormatException,
    );
    expect(
      () => SnoopyCatalogue.parse(
        '{"version":1,"clips":[{"id":"101_AS001","sourceId":"3_TQ0FKoTcI","themes":["unknown"]}]}',
      ),
      throwsFormatException,
    );
  });
}
