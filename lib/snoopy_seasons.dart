import 'dart:convert';

import 'package:flutter/services.dart';

enum SnoopyTheme {
  yearRound('Everyday', 'All year'),
  spring('Spring', 'March–May'),
  summer('Summer', 'June–August'),
  autumn('Autumn', 'September–November'),
  winter('Winter', 'November–March'),
  halloween('Halloween', 'October 1–November 2'),
  holidays('Holiday season', 'December 1–January 6'),
  newYear('New Year', 'December 26–January 7'),
  valentines('Valentine’s', 'February 1–15'),
  thanksgiving(
    'Canadian Thanksgiving',
    'October 1–two days after Thanksgiving',
  ),
  canadaDay('Canada Day', 'June 25–July 2');

  const SnoopyTheme(this.label, this.window);
  final String label;
  final String window;
}

/// Canadian-style calendar, not a location or live-weather forecast. Winter
/// deliberately overlaps autumn in November and spring in March.
bool snoopyThemeUnlocked(SnoopyTheme theme, DateTime localDate) {
  final month = localDate.month;
  final day = localDate.day;
  return switch (theme) {
    SnoopyTheme.yearRound => true,
    SnoopyTheme.spring => month >= 3 && month <= 5,
    SnoopyTheme.summer => month >= 6 && month <= 8,
    SnoopyTheme.autumn => month >= 9 && month <= 11,
    SnoopyTheme.winter => month >= 11 || month <= 3,
    SnoopyTheme.halloween => month == 10 || (month == 11 && day <= 2),
    SnoopyTheme.holidays => month == 12 || (month == 1 && day <= 6),
    SnoopyTheme.newYear =>
      (month == 12 && day >= 26) || (month == 1 && day <= 7),
    SnoopyTheme.valentines => month == 2 && day <= 15,
    SnoopyTheme.thanksgiving =>
      month == 10 && day <= _thanksgivingDay(localDate.year) + 2,
    SnoopyTheme.canadaDay =>
      (month == 6 && day >= 25) || (month == 7 && day <= 2),
  };
}

int _thanksgivingDay(int year) {
  final first = DateTime(year, 10, 1);
  return 8 + (DateTime.monday - first.weekday + 7) % 7;
}

class SnoopyClip {
  final String id;
  final String sourceId;
  final List<SnoopyTheme> themes;

  const SnoopyClip(this.id, this.sourceId, this.themes);

  String get filename => '$sourceId.mp4';

  bool unlocked(DateTime date) =>
      themes.any((theme) => snoopyThemeUnlocked(theme, date));
}

class SnoopyCatalogue {
  final List<SnoopyClip> clips;
  late final Map<String, SnoopyClip> _byFilename = {
    for (final clip in clips) clip.filename: clip,
  };

  SnoopyCatalogue(this.clips);

  factory SnoopyCatalogue.parse(String json) {
    final data = jsonDecode(json);
    if (data is! Map || data['version'] != 1 || data['clips'] is! List) {
      throw const FormatException('Unsupported Snoopy catalogue');
    }
    final clips = <SnoopyClip>[];
    final ids = <String>{};
    final sources = <String>{};
    for (final entry in data['clips'] as List) {
      if (entry is! Map ||
          entry['id'] is! String ||
          entry['sourceId'] is! String ||
          !RegExp(r'^\d{3}_AS\d{3}$').hasMatch(entry['id'] as String) ||
          !RegExp(
            r'^[A-Za-z0-9_-]{11}$',
          ).hasMatch(entry['sourceId'] as String) ||
          entry['themes'] is! List ||
          (entry['themes'] as List).isEmpty ||
          !ids.add(entry['id'] as String) ||
          !sources.add(entry['sourceId'] as String)) {
        throw const FormatException('Invalid or duplicate Snoopy clip');
      }
      final themes = <SnoopyTheme>[];
      for (final value in entry['themes'] as List) {
        final matches = SnoopyTheme.values.where(
          (theme) => theme.name == value,
        );
        if (matches.isEmpty)
          throw FormatException('Unknown Snoopy theme: $value');
        themes.add(matches.single);
      }
      clips.add(
        SnoopyClip(
          entry['id'] as String,
          entry['sourceId'] as String,
          List.unmodifiable(themes),
        ),
      );
    }
    return SnoopyCatalogue(List.unmodifiable(clips));
  }

  // Unknown user-added clips are not seasonal and remain available all year.
  bool fileUnlocked(String filename, DateTime date) =>
      _byFilename[filename]?.unlocked(date) ?? true;

  List<SnoopyTheme> activeThemes(DateTime date) => SnoopyTheme.values
      .where((theme) => snoopyThemeUnlocked(theme, date))
      .toList(growable: false);
}

Future<SnoopyCatalogue>? _bundledCatalogue;

Future<SnoopyCatalogue> loadSnoopyCatalogue() =>
    _bundledCatalogue ??= rootBundle
        .loadString('assets/video_collections/Snoopy/catalog.json')
        .then(SnoopyCatalogue.parse);
