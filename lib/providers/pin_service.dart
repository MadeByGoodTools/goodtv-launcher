import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pinHashKey = 'settings_pin_hash';
const _pinSaltKey = 'settings_pin_salt';

class PinService extends ChangeNotifier {
  final SharedPreferences _preferences;

  PinService(this._preferences);

  bool get enabled =>
      _preferences.getString(_pinHashKey)?.isNotEmpty == true &&
      _preferences.getString(_pinSaltKey)?.isNotEmpty == true;

  bool isValidPin(String pin) => RegExp(r'^\d{4,8}$').hasMatch(pin);

  Future<void> setPin(String pin) async {
    if (!isValidPin(pin)) throw const FormatException('PIN must be 4-8 digits');
    final random = Random.secure();
    final salt = base64UrlEncode(
      List<int>.generate(18, (_) => random.nextInt(256)),
    );
    await Future.wait([
      _preferences.setString(_pinSaltKey, salt),
      _preferences.setString(_pinHashKey, _hash(pin, salt)),
    ]);
    notifyListeners();
  }

  bool verify(String pin) {
    final salt = _preferences.getString(_pinSaltKey);
    final expected = _preferences.getString(_pinHashKey);
    if (salt == null || expected == null) return false;
    final actual = _hash(pin, salt);
    if (actual.length != expected.length) return false;
    var difference = 0;
    for (var i = 0; i < actual.length; i++) {
      difference |= actual.codeUnitAt(i) ^ expected.codeUnitAt(i);
    }
    return difference == 0;
  }

  Future<bool> disable(String pin) async {
    if (!verify(pin)) return false;
    await Future.wait([
      _preferences.remove(_pinHashKey),
      _preferences.remove(_pinSaltKey),
    ]);
    notifyListeners();
    return true;
  }

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();
}
