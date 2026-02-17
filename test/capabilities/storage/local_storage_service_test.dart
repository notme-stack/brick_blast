import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brick_blast/capabilities/storage/local_storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    LocalStorageService.clear();
  });

  test('read/write persists after init rehydration', () async {
    final storage = LocalStorageService();
    await storage.write('test_key', 42);

    await LocalStorageService.init();

    expect(storage.read<int>('test_key'), 42);
  });

  test('clear resets memory and stored values', () async {
    final storage = LocalStorageService();
    await storage.write('clear_key', true);
    expect(storage.read<bool>('clear_key'), isTrue);

    LocalStorageService.clear();
    await LocalStorageService.init();

    expect(storage.read<bool>('clear_key'), isNull);
  });
}
