import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/modules/brick_blast/ui/game_screen.dart';

void main() {
  testWidgets('settings opens paused modal with style and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BrickBlastGameScreen())),
    );
    await tester.pump();

    expect(find.text('Paused'), findsNothing);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Restart Level'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('PROJECTILE STYLE'), findsOneWidget);
    expect(find.text('Dotted Line'), findsOneWidget);
    expect(find.text('Light Sabre'), findsOneWidget);
    expect(find.text('Resume Game'), findsOneWidget);
  });

  testWidgets('resume closes paused modal', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BrickBlastGameScreen())),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump(const Duration(milliseconds: 220));

    await tester.tap(find.text('Resume Game'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Paused'), findsNothing);
    expect(find.text('SCORE'), findsOneWidget);
  });

  testWidgets('drag aiming still transitions after closing modal', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BrickBlastGameScreen())),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.tap(find.text('Resume Game'));
    await tester.pump(const Duration(milliseconds: 200));

    final boardFinder = find.byType(GestureDetector).first;
    final center = tester.getCenter(boardFinder);

    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 16));

    await gesture.moveBy(const Offset(-70, -100));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('SCORE'), findsOneWidget);
  });
}
