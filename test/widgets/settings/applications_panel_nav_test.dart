import 'package:goodtv_launcher/providers/apps_service.dart';
import 'package:goodtv_launcher/widgets/settings/applications_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';

import '../../mocks.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1280, 720);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  testWidgets(
    "Left/Right arrow keys switch categories in ApplicationsPanelPage",
    (tester) async {
      final appsService = MockAppsService();
      // Setup some fake apps to populate tabs
      when(appsService.applications).thenReturn([
        fakeApp(
          packageName: "pkg.tv",
          name: "TV App",
          sideloaded: false,
          hidden: false,
        ),
        fakeApp(
          packageName: "pkg.sideload",
          name: "Sideload App",
          sideloaded: true,
          hidden: false,
        ),
      ]);
      // Mock category for favorites (even if empty)
      when(appsService.categories).thenReturn([]);
      when(appsService.isAppInFavorites(any)).thenReturn(false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppsService>.value(value: appsService),
          ],
          builder: (_, __) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: ApplicationsPanelPage()),
            onGenerateRoute: (settings) =>
                MaterialPageRoute(builder: (_) => Container()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: all installed applications (index 0)
      expect(
        find.text("All Apps"),
        findsNWidgets(2),
        reason: "Should start on All Apps tab",
      );

      // Focus on the list (assuming list item is focusable, or we can just send keys if focus is set)
      // To be safe, we'll try to focus the first list item.
      // The list items are _AppListItem which contain Focus/InkWell.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Simulate Right Arrow
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // The second tab controls the Home dock.
      expect(
        find.text("Home dock"),
        findsNWidgets(2),
        reason: "Should switch to Home dock after Right Arrow",
      );

      // Simulate Left Arrow
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      // Should be back on all installed applications (index 0).
      expect(
        find.text("All Apps"),
        findsNWidgets(2),
        reason: "Should switch back to All Apps after Left Arrow",
      );
      expect(find.text("TV App"), findsOneWidget);

      // Check boundary (Left on first tab)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(
        find.text("All Apps"),
        findsNWidgets(2),
        reason: "Should stay on All Apps when pressing Left on first tab",
      );
    },
  );
}
