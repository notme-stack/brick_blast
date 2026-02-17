import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/app.dart';
import 'package:brick_blast/capabilities/storage/local_storage_service.dart';

void main() {
  setUp(() {
    LocalStorageService.clear();
  });

  testWidgets('app boots and shows splash branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrickBlastApp());

    expect(find.text('BRICK'), findsOneWidget);
    expect(find.text('BLAST'), findsOneWidget);
    expect(find.text('SHOOTER'), findsOneWidget);
    expect(find.textContaining('LOADING'), findsOneWidget);
  });
}
