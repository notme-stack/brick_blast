import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/modules/brick_blast/ui/result_dialog.dart';

void main() {
  testWidgets('game over dialog shows core UI and final score', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameOverResultDialog(
            finalScore: 8240,
            onPlayAgain: () {},
            onHome: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('game-over-dialog')), findsOneWidget);
    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.text('RESULT'), findsOneWidget);
    expect(find.text('FINAL SCORE'), findsOneWidget);
    expect(find.text('8,240'), findsOneWidget);
    expect(find.text('PLAY AGAIN'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('game over dialog actions are tappable', (tester) async {
    var playAgainTapped = 0;
    var homeTapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameOverResultDialog(
            finalScore: 99,
            onPlayAgain: () => playAgainTapped++,
            onHome: () => homeTapped++,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('PLAY AGAIN'));
    await tester.pump();
    await tester.tap(find.text('HOME'));
    await tester.pump();

    expect(playAgainTapped, 1);
    expect(homeTapped, 1);
  });

  testWidgets('level clear dialog shows core UI and stats', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelClearResultDialog(
            level: 12,
            levelScore: 12450,
            coinsEarned: 250,
            totalCoins: 2700,
            onNextLevel: () {},
            onHome: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('HOME'));
    await tester.pump();

    expect(find.byKey(const Key('level-clear-dialog')), findsOneWidget);
    expect(find.text('LEVEL CLEARED!'), findsOneWidget);
    expect(find.byKey(const Key('level-clear-stars')), findsOneWidget);
    expect(find.text('MISSION COMPLETE'), findsOneWidget);
    expect(find.text('Level 12'), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('Coins Earned'), findsOneWidget);
    expect(find.text('Total Coins'), findsOneWidget);
    expect(find.text('12,450'), findsOneWidget);
    expect(find.text('+250'), findsOneWidget);
    expect(find.text('2,700'), findsOneWidget);
    expect(find.text('NEXT LEVEL'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('level clear dialog actions are tappable', (tester) async {
    var nextTapped = 0;
    var homeTapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelClearResultDialog(
            level: 1,
            levelScore: 100,
            coinsEarned: 1,
            totalCoins: 1,
            onNextLevel: () => nextTapped++,
            onHome: () => homeTapped++,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('NEXT LEVEL'));
    await tester.tap(find.text('NEXT LEVEL'));
    await tester.pump();
    await tester.ensureVisible(find.text('HOME'));
    await tester.tap(find.text('HOME'));
    await tester.pump();

    expect(nextTapped, 1);
    expect(homeTapped, 1);
  });
}
