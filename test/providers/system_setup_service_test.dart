import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:goodtv_launcher/providers/system_setup_service.dart';

void main() {
  test('Fire TV receives the low-overhead compact profile', () {
    expect(
      recommendedDisplayPreset({'isFireTv': true, 'sdkInt': 33}),
      DisplayPreset.compact,
    );
  });

  test('older Android TV receives the compact profile', () {
    expect(
      recommendedDisplayPreset({'isFireTv': false, 'sdkInt': 27}),
      DisplayPreset.compact,
    );
  });

  test('modern Android TV receives the cinema profile', () {
    expect(
      recommendedDisplayPreset({'isFireTv': false, 'sdkInt': 34}),
      DisplayPreset.cinema,
    );
  });
}
