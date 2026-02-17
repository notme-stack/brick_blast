import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/capabilities/storage/local_storage_service.dart';
import 'package:brick_blast/modules/brick_blast/logic/game_controller.dart';
import 'package:brick_blast/modules/brick_blast/ui/home_screen.dart';

void main() {
  setUp(() {
    LocalStorageService.clear();
  });

  testWidgets('home screen shows top stats and next level CTA', (tester) async {
    final storage = LocalStorageService();
    await storage.write(GameController.totalCoinsKey, 12);
    await storage.write(GameController.highestLevelKey, 4);
    await storage.write(GameController.bestScoreKey, 760);

    await tester.pumpWidget(const MaterialApp(home: BrickBlastHomeScreen()));
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('LEVEL'), findsNothing);
    expect(find.text('BEST'), findsNothing);
    expect(find.text('760'), findsNothing);
    expect(find.text('NEXT LEVEL 4'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.byKey(const Key('home-diamond-mark')), findsOneWidget);
    expect(find.byKey(const Key('home-top-stats-row')), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('home screen compact viewport keeps all key elements visible', (
    tester,
  ) async {
    final storage = LocalStorageService();
    await storage.write(GameController.totalCoinsKey, 210);
    await storage.write(GameController.highestLevelKey, 4);

    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: BrickBlastHomeScreen()));
    await tester.pump();

    expect(find.byKey(const Key('home-diamond-mark')), findsOneWidget);
    expect(find.text('BRICK BLAST'), findsOneWidget);
    expect(find.text('NEXT LEVEL 4'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home screen regular viewport stays balanced and visible', (
    tester,
  ) async {
    final storage = LocalStorageService();
    await storage.write(GameController.totalCoinsKey, 2450);
    await storage.write(GameController.highestLevelKey, 12);

    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: BrickBlastHomeScreen()));
    await tester.pump();

    expect(find.byKey(const Key('home-top-stats-row')), findsOneWidget);
    expect(find.byKey(const Key('home-diamond-mark')), findsOneWidget);
    expect(find.text('BRICK BLAST'), findsOneWidget);
    expect(find.text('NEXT LEVEL 12'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
