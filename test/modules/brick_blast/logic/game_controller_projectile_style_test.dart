import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/capabilities/analytics/noop_analytics_service.dart';
import 'package:brick_blast/capabilities/storage/local_storage_service.dart';
import 'package:brick_blast/modules/brick_blast/logic/game_controller.dart';
import 'package:brick_blast/modules/brick_blast/models/projectile_style.dart';

void main() {
  setUp(() {
    LocalStorageService.clear();
  });

  test('projectile style persists across controller recreation', () {
    final storage = LocalStorageService();

    final controller = GameController(
      storageService: storage,
      analyticsService: NoopAnalyticsService(),
    );

    controller.setProjectileStyle(ProjectileStyle.lightSabre);
    expect(controller.state.projectileStyle, ProjectileStyle.lightSabre);

    final reloaded = GameController(
      storageService: storage,
      analyticsService: NoopAnalyticsService(),
    );

    expect(reloaded.state.projectileStyle, ProjectileStyle.lightSabre);
  });
}
