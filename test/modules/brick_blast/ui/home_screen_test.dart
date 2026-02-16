import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/capabilities/storage/local_storage_service.dart';
import 'package:brick_blast/modules/brick_blast/logic/game_controller.dart';
import 'package:brick_blast/modules/brick_blast/ui/home_screen.dart';

void main() {
  setUp(() {
    LocalStorageService.clear();
  });

  testWidgets('home screen shows total coins and current level', (
    tester,
  ) async {
    final storage = LocalStorageService();
    await storage.write(GameController.totalCoinsKey, 12);
    await storage.write(GameController.highestLevelKey, 4);
    await storage.write(GameController.bestScoreKey, 760);

    await tester.pumpWidget(const MaterialApp(home: BrickBlastHomeScreen()));
    await tester.pump();

    expect(find.text('Total Coins: 12'), findsOneWidget);
    expect(find.text('Current Level: 4'), findsOneWidget);
    expect(find.text('Best Score: 760'), findsOneWidget);
  });
}
