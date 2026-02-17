import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/capabilities/analytics/noop_analytics_service.dart';
import 'package:brick_blast/capabilities/storage/local_storage_service.dart';
import 'package:brick_blast/modules/brick_blast/data/brick_row_generator.dart';
import 'package:brick_blast/modules/brick_blast/data/game_tuning.dart';
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

  test('retryCurrentLevel rebuilds same level with fresh run state', () {
    final controller = GameController(
      storageService: LocalStorageService(),
      analyticsService: NoopAnalyticsService(),
    );

    controller.advanceToNextLevel();
    controller.retryCurrentLevel();
    final state = controller.state;

    expect(state.levelProgress.levelIndex, 1);
    expect(state.score, 0);
    expect(state.ballCount, GameTuning.initialBallCount);
    expect(state.phase, GamePhase.idle);
    expect(state.shouldShowGameOverDialog, false);
    expect(state.coinsPaidBucketsInRun, 0);
    expect(state.levelProgress.wavesSpawned, GameTuning.initialPrefillRows);
    expect(state.launchSpeedMultiplier, 1.0);
  });

  test('restart resets launch speed multiplier to base', () {
    final controller = GameController(
      storageService: LocalStorageService(),
      analyticsService: NoopAnalyticsService(),
      engine: _FakeSimulationEngine(
        nextStateBuilder: (state) => state.copyWith(launchSpeedMultiplier: 1.7),
      ),
    );

    controller.tick(1 / 60);
    expect(controller.state.launchSpeedMultiplier, 1.7);

    controller.restart();
    expect(controller.state.launchSpeedMultiplier, 1.0);
  });

  test('advanceToNextLevel resets launch speed multiplier to base', () {
    final controller = GameController(
      storageService: LocalStorageService(),
      analyticsService: NoopAnalyticsService(),
      engine: _FakeSimulationEngine(
        nextStateBuilder: (state) => state.copyWith(
          launchSpeedMultiplier: 1.8,
          pendingLevelUpDialog: true,
        ),
      ),
    );

    controller.tick(1 / 60);
    expect(controller.state.launchSpeedMultiplier, 1.8);
    expect(controller.state.pendingLevelUpDialog, true);

    controller.advanceToNextLevel();
    expect(controller.state.launchSpeedMultiplier, 1.0);
  });

  test('confirmLevelClearUnlock unlocks next level and persists it', () {
    final storage = LocalStorageService();
    final controller = GameController(
      storageService: storage,
      analyticsService: NoopAnalyticsService(),
      engine: _FakeSimulationEngine(
        nextStateBuilder: (state) => state.copyWith(
          pendingLevelUpDialog: true,
          highestLevelReached: 2,
          levelProgress: state.levelProgress.copyWith(levelIndex: 2),
        ),
      ),
    );

    controller.tick(1 / 60);
    controller.confirmLevelClearUnlock();

    expect(controller.state.highestLevelReached, 3);
    expect(storage.read<int>(GameController.highestLevelKey), 3);
  });

  test('confirmLevelClearUnlock is idempotent for same clear state', () {
    final storage = LocalStorageService();
    final controller = GameController(
      storageService: storage,
      analyticsService: NoopAnalyticsService(),
      engine: _FakeSimulationEngine(
        nextStateBuilder: (state) => state.copyWith(
          pendingLevelUpDialog: true,
          highestLevelReached: 2,
          levelProgress: state.levelProgress.copyWith(levelIndex: 2),
        ),
      ),
    );

    controller.tick(1 / 60);
    controller.confirmLevelClearUnlock();
    controller.confirmLevelClearUnlock();

    expect(controller.state.highestLevelReached, 3);
    expect(storage.read<int>(GameController.highestLevelKey), 3);
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
