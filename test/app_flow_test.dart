import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/app.dart';

void main() {
  testWidgets('follows splash -> login -> home -> game flow', (tester) async {
    await tester.pumpWidget(const BrickBlastApp());

    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();

    expect(find.text('Brick Blast'), findsOneWidget);
    expect(find.text('Start Shooter Run'), findsOneWidget);

    await tester.tap(find.text('Start Shooter Run'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
