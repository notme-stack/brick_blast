import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/capabilities/analytics/noop_analytics_service.dart';
import 'package:brick_blast/capabilities/storage/local_storage_service.dart';
import 'package:brick_blast/modules/brick_blast/data/brick_row_generator.dart';
import 'package:brick_blast/modules/brick_blast/logic/game_controller.dart';
import 'package:brick_blast/modules/brick_blast/logic/level_progression_service.dart';
import 'package:brick_blast/modules/brick_blast/logic/simulation_engine.dart';
import 'package:brick_blast/modules/brick_blast/logic/turn_resolver.dart';
import 'package:brick_blast/modules/brick_blast/models/game_phase.dart';
import 'package:brick_blast/modules/brick_blast/models/game_state.dart';

void main() {
  setUp(() {
    LocalStorageService.clear();
  });

  test('awards coins only when level clear is triggered', () {
    final storage = LocalStorageService();
    final engine = _FakeSimulationEngine(
      nextStateBuilder: (state) {
        return state.copyWith(score: 410, pendingLevelUpDialog: true);
      },
    );

    final controller = GameController(
      storageService: storage,
      analyticsService: NoopAnalyticsService(),
      engine: engine,
    );

    controller.tick(1 / 60);

    expect(controller.state.totalCoins, 4);
    expect(controller.state.coinsEarnedThisLevel, 4);

    controller.restart();
    expect(controller.state.totalCoins, 4);
    expect(controller.state.coinsPaidBucketsInRun, 0);
  });

  test('no coins awarded on game over transition', () {
    final storage = LocalStorageService();
    final engine = _FakeSimulationEngine(
      nextStateBuilder: (state) {
        return state.copyWith(
          score: 250,
          phase: GamePhase.gameOver,
          shouldShowGameOverDialog: true,
        );
      },
    );

    final controller = GameController(
      storageService: storage,
      analyticsService: NoopAnalyticsService(),
      engine: engine,
    );

    controller.tick(1 / 60);

    expect(controller.state.totalCoins, 0);
  });
}

class _FakeSimulationEngine extends SimulationEngine {
  _FakeSimulationEngine({required this.nextStateBuilder})
    : super(
        turnResolver: TurnResolver(
          rowGenerator: BrickRowGenerator(random: Random(1)),
          progressionService: const LevelProgressionService(),
        ),
      );

  final GameState Function(GameState) nextStateBuilder;

  @override
  GameState tick(GameState state, double dt) {
    return nextStateBuilder(state);
  }
}
