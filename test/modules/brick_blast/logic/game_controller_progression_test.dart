import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/capabilities/analytics/noop_analytics_service.dart';
import 'package:brick_blast/capabilities/storage/local_storage_service.dart';
import 'package:brick_blast/modules/brick_blast/data/game_tuning.dart';
import 'package:brick_blast/modules/brick_blast/logic/game_controller.dart';

void main() {
  setUp(() {
    LocalStorageService.clear();
  });

  test('initial state prefills 4 rows and starts at wave 4', () {
    final controller = GameController(
      storageService: LocalStorageService(),
      analyticsService: NoopAnalyticsService(),
    );

    final state = controller.state;
    final rows = state.bricks.map((brick) => brick.row).toSet();

    expect(state.levelProgress.wavesSpawned, GameTuning.initialPrefillRows);
    expect(rows.length, GameTuning.initialPrefillRows);
    expect(state.bricks.isNotEmpty, true);
  });
}
