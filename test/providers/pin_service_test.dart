import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/providers/pin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('stores a hash and verifies the correct PIN', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = PinService(preferences);

    await service.setPin('2468');

    expect(service.enabled, isTrue);
    expect(service.verify('2468'), isTrue);
    expect(service.verify('1357'), isFalse);
    expect(preferences.getString('settings_pin_hash'), isNot('2468'));
  });

  test('rejects invalid PIN lengths', () async {
    final service = PinService(await SharedPreferences.getInstance());

    expect(() => service.setPin('123'), throwsFormatException);
    expect(() => service.setPin('123456789'), throwsFormatException);
  });

  test('requires the current PIN before disabling protection', () async {
    final service = PinService(await SharedPreferences.getInstance());
    await service.setPin('8642');

    expect(await service.disable('0000'), isFalse);
    expect(service.enabled, isTrue);
    expect(await service.disable('8642'), isTrue);
    expect(service.enabled, isFalse);
  });
}
