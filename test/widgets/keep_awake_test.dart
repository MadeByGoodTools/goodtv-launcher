import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/widgets/keep_awake.dart';

void main() {
  const channel = MethodChannel('me.efesser.flauncher/method');
  final calls = <bool>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'setKeepAwake');
          calls.add(call.arguments as bool);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('applies setting, updates live, and releases on removal', (
    tester,
  ) async {
    Widget build(bool enabled) =>
        KeepAwake(enabled: enabled, child: const SizedBox());
    await tester.pumpWidget(build(false));
    expect(calls, [false]);
    await tester.pumpWidget(build(true));
    expect(calls, [false, true]);
    await tester.pumpWidget(build(true));
    expect(calls, [false, true]);
    await tester.pumpWidget(build(false));
    expect(calls, [false, true, false]);
    await tester.pumpWidget(build(true));
    await tester.pumpWidget(const SizedBox());
    expect(calls, [false, true, false, true, false]);
  });

  testWidgets('unsupported platform does not crash the launcher', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'UNSUPPORTED');
        });
    await tester.pumpWidget(const KeepAwake(enabled: true, child: SizedBox()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
