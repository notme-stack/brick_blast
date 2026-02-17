import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/app.dart';
import 'package:brick_blast/capabilities/storage/local_storage_service.dart';

void main() {
  setUp(() {
    LocalStorageService.clear();
  });

  testWidgets('follows first-time splash -> login -> home -> game flow', (
    tester,
  ) async {
    await tester.pumpWidget(const BrickBlastApp());

    expect(find.text('BRICK'), findsOneWidget);
    expect(find.textContaining('LOADING'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('CONTINUE AS GUEST'), findsOneWidget);
    expect(find.text('SHOOTER'), findsOneWidget);
    expect(find.byKey(const Key('login-brand-mark')), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);

    await tester.ensureVisible(find.text('CONTINUE AS GUEST'));
    await tester.tap(find.text('CONTINUE AS GUEST'));
    await tester.pumpAndSettle();

    expect(find.text('BRICK BLAST'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.textContaining('NEXT LEVEL'), findsOneWidget);

    await tester.ensureVisible(find.text('PLAY'));
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('SCORE'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('returning user splash routes directly to home', (tester) async {
    await LocalStorageService().write(
      LocalStorageService.hasCompletedLoginKey,
      true,
    );

    await tester.pumpWidget(const BrickBlastApp());
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('BRICK BLAST'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.textContaining('NEXT LEVEL'), findsOneWidget);
    expect(find.text('CONTINUE AS GUEST'), findsNothing);
  });
}
