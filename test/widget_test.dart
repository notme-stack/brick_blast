import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/app.dart';

void main() {
  testWidgets('app boots and shows splash CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const BrickBlastApp());

    expect(find.text('Continue'), findsOneWidget);
  });
}
