import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/widgets/wallpaper_transition.dart';

void main() {
  testWidgets('preloaded clip stays paused until its scheduled transition', (
    tester,
  ) async {
    VoidCallback? ready;
    bool? playing;
    await tester.pumpWidget(
      MaterialApp(
        home: WallpaperTransition(
          sourceKey: 'next',
          startAt: DateTime.now().add(const Duration(seconds: 2)),
          fallback: const ColoredBox(color: Colors.black),
          builder: (_, onReady, onFailed, active) {
            ready = onReady;
            playing = active;
            return const Text('next');
          },
        ),
      ),
    );
    ready!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(playing, isFalse);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(playing, isTrue);
    await tester.pumpAndSettle();
  });
  testWidgets(
    'holds previous wallpaper until ready, then fades without remounting',
    (tester) async {
      final ready = <String, VoidCallback>{};
      final failed = <String, VoidCallback>{};
      final mounts = <String, int>{};
      Widget wallpaper(String id) => MaterialApp(
        home: WallpaperTransition(
          sourceKey: id,
          fallback: const ColoredBox(color: Colors.black),
          builder: (_, onReady, onFailed, playing) {
            ready[id] = onReady;
            failed[id] = onFailed;
            return _TrackedSurface(id, mounts);
          },
        ),
      );

      await tester.pumpWidget(wallpaper('first'));
      ready['first']!();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(mounts['first'], 1);

      await tester.pumpWidget(wallpaper('second'));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('first'), findsOneWidget);
      final nextFade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.text('second'),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(nextFade.opacity.value, 0);

      ready['second']!();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(nextFade.opacity.value, greaterThan(0));
      expect(nextFade.opacity.value, lessThan(1));
      expect(find.text('first'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      expect(mounts['second'], 1);

      await tester.pumpWidget(wallpaper('broken'));
      failed['broken']!();
      await tester.pump();
      await tester.pump();
      expect(find.text('broken'), findsNothing);
      expect(find.text('second'), findsOneWidget);

      await tester.pumpWidget(wallpaper('stale'));
      final staleReady = ready['stale']!;
      await tester.pumpWidget(wallpaper('latest'));
      staleReady();
      await tester.pumpAndSettle();
      expect(find.text('stale'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      ready['latest']!();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('second'), findsNothing);
      expect(find.text('latest'), findsOneWidget);
      expect(mounts['latest'], 1);
    },
  );
}

class _TrackedSurface extends StatefulWidget {
  final String id;
  final Map<String, int> mounts;
  const _TrackedSurface(this.id, this.mounts);

  @override
  State<_TrackedSurface> createState() => _TrackedSurfaceState();
}

class _TrackedSurfaceState extends State<_TrackedSurface> {
  @override
  void initState() {
    super.initState();
    widget.mounts.update(widget.id, (count) => count + 1, ifAbsent: () => 1);
  }

  @override
  Widget build(BuildContext context) => Text(widget.id);
}
