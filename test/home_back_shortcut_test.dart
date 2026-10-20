import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/home_back_shortcut.dart';

void main() {
  testWidgets('double Back starts screensaver without running single Back', (
    tester,
  ) async {
    var singles = 0, doubles = 0;
    final shortcut = HomeBackShortcut(
      onSingle: () => singles++,
      onDouble: () => doubles++,
    );
    shortcut.press();
    await tester.pump(const Duration(milliseconds: 200));
    shortcut.press();
    expect(doubles, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(singles, 0);
    shortcut.cancel();
  });

  testWidgets('single Back runs once after the double-press window', (
    tester,
  ) async {
    var singles = 0, doubles = 0;
    final shortcut = HomeBackShortcut(
      onSingle: () => singles++,
      onDouble: () => doubles++,
    );
    shortcut.press();
    await tester.pump(const Duration(milliseconds: 399));
    expect(singles, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(singles, 1);
    expect(doubles, 0);
    shortcut.press();
    await tester.pump(const Duration(milliseconds: 400));
    expect(singles, 2);
    shortcut.cancel();
  });

  testWidgets('navigation, wake and app switching can cancel pending Back', (
    tester,
  ) async {
    var fired = false;
    final shortcut = HomeBackShortcut(
      onSingle: () => fired = true,
      onDouble: () => fired = true,
    );
    shortcut.press();
    shortcut.cancel();
    await tester.pump(const Duration(seconds: 1));
    expect(fired, isFalse);
  });
}
