import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:brick_blast/main.dart' as app;
import 'package:brick_blast/capabilities/storage/local_storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: Splash -> Login -> Home -> Play', (
    WidgetTester tester,
  ) async {
    // Clear storage to ensure fresh start
    await LocalStorageService.clear();

    // Start the app
    app.main();
    // Wait for splash screen (2.5s) + buffer.
    // We cannot use pumpAndSettle here because the splash screen has an infinite loading animation.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 1. Verify Splash/Login Screen
    // Expect 'CONTINUE AS GUEST' button (since we cleared storage)
    expect(find.text('CONTINUE AS GUEST'), findsOneWidget);

    // 2. Interact: Tap 'CONTINUE AS GUEST'
    await tester.tap(find.text('CONTINUE AS GUEST'));
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 1000),
    ); // Wait for navigation

    // 3. Verify Home Screen
    expect(find.text('BRICK BLAST'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);

    // 4. Interact: Tap 'PLAY'
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 1000),
    ); // Wait for navigation

    // 5. Verify Game Screen
    expect(find.byIcon(Icons.settings), findsOneWidget); // Pause button
    expect(find.text('SCORE'), findsOneWidget);
  });
}
