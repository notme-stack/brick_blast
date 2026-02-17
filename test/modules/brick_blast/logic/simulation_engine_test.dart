import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/modules/brick_blast/data/brick_row_generator.dart';
import 'package:brick_blast/modules/brick_blast/data/game_tuning.dart';
import 'package:brick_blast/modules/brick_blast/data/level_plan_builder.dart';
import 'package:brick_blast/modules/brick_blast/logic/level_progression_service.dart';
import 'package:brick_blast/modules/brick_blast/logic/simulation_engine.dart';
import 'package:brick_blast/modules/brick_blast/logic/turn_resolver.dart';
import 'package:brick_blast/modules/brick_blast/models/ball.dart';
import 'package:brick_blast/modules/brick_blast/models/brick.dart';
import 'package:brick_blast/modules/brick_blast/models/game_phase.dart';
import 'package:brick_blast/modules/brick_blast/models/game_state.dart';
import 'package:brick_blast/modules/brick_blast/models/launcher.dart';
import 'package:brick_blast/modules/brick_blast/models/level_progress.dart';
import 'package:brick_blast/modules/brick_blast/models/wave_pattern.dart';

void main() {
  late SimulationEngine engine;

  setUp(() {
    engine = SimulationEngine(
      turnResolver: TurnResolver(
        rowGenerator: BrickRowGenerator(random: Random(1)),
        progressionService: const LevelProgressionService(),
      ),
    );
  });

  test('state transitions idle -> aiming -> firing', () {
    final initial = _baseState();
    final aiming = engine.startAiming(initial, const Offset(0.1, 0.5));
    final firing = engine.releaseFire(aiming);

    expect(aiming.phase, GamePhase.aiming);
    expect(firing.phase, GamePhase.firing);
    expect(firing.ballsToFire, firing.ballCount);
  });

  test('firing cadence releases balls in stream, not all at once', () {
    var state = _baseState(ballCount: 5);
    state = engine.startAiming(state, const Offset(0.2, 0.3));
    state = engine.releaseFire(state);

    state = engine.tick(state, GameTuning.turnConfig.fireIntervalSeconds * 0.5);
    expect(state.activeBallCount, 0);

    state = engine.tick(
      state,
      GameTuning.turnConfig.fireIntervalSeconds * 0.75,
    );
    expect(state.activeBallCount, 1);
  });

  test('launched ball moves upward instead of landing immediately', () {
    var state = _baseState(ballCount: 1);
    state = engine.startAiming(state, const Offset(0.5, 0.1));
    state = engine.releaseFire(state);

    state = engine.tick(
      state,
      GameTuning.turnConfig.fireIntervalSeconds + 0.001,
    );
    final launched = state.balls.first;

    expect(launched.active, true);
    expect(launched.grounded, false);
    expect(launched.position.dy, lessThan(GameTuning.launcherY));
  });

  test('launch speed applies level-scoped multiplier', () {
    var state = _baseState(ballCount: 1).copyWith(launchSpeedMultiplier: 1.5);
    state = engine.startAiming(state, const Offset(0.5, 0.1));
    state = engine.releaseFire(state);

    state = engine.tick(
      state,
      GameTuning.turnConfig.fireIntervalSeconds + 0.001,
    );
    final launched = state.balls.first;
    final expected = GameTuning.turnConfig.ballSpeed * 1.5;

    expect(launched.velocity.distance, closeTo(expected, 1e-6));
  });

  test('blitz damage multiplier applies at least 2 damage', () {
    final brick = const Brick(id: 1, row: 1, col: 3, hp: 4, colorTier: 0);
    final ball = Ball(
      id: 0,
      position: const Offset(0.5, 0.19),
      previousPosition: const Offset(0.5, 0.205),
      velocity: const Offset(0, -0.9),
      radius: GameTuning.ballRadius,
      active: true,
      grounded: false,
      merged: false,
      flightTimeSeconds: 0,
    );

    var state = _baseState(
      phase: GamePhase.busy,
      balls: [ball],
      ballCount: 1,
      activeBallCount: 1,
      ballsToFire: 0,
      bricks: [brick],
      damageMultiplier: 2,
    );

    state = engine.tick(state, 1 / 120);

    expect(state.bricks.single.hp, lessThanOrEqualTo(2));
  });

  test('end turn increments turn and can enter cleanup', () {
    final progress = const LevelPlanBuilder()
        .buildForLevel(1)
        .copyWith(wavesSpawned: 9);

    final state = _baseState(
      phase: GamePhase.busy,
      ballsToFire: 0,
      activeBallCount: 0,
      nextLauncherX: 0.42,
      balls: const [
        Ball(
          id: 0,
          position: Offset(0.42, GameTuning.launcherY),
          previousPosition: Offset(0.42, GameTuning.launcherY),
          velocity: Offset.zero,
          radius: GameTuning.ballRadius,
          active: false,
          grounded: true,
          merged: true,
          flightTimeSeconds: 0,
        ),
      ],
      ballCount: 1,
      bricks: const [],
      levelProgress: progress,
    );

    final updated = engine.tick(state, 1 / 120);

    expect(updated.turnIndex, state.turnIndex + 1);
    expect(updated.levelProgress.inCleanupPhase, true);
  });

  test('all balls eventually return to floor and turn resolves', () {
    var state = _baseState(ballCount: 4, bricks: const []);
    state = engine.startAiming(state, const Offset(0.2, 0.1));
    state = engine.releaseFire(state);

    for (var i = 0; i < 2200; i++) {
      state = engine.tick(state, 1 / 120);
      if (state.phase == GamePhase.idle) {
        break;
      }
    }

    expect(state.phase, GamePhase.idle);
    expect(state.balls.every((ball) => !ball.active && !ball.grounded), true);
    expect(state.nextLauncherX, isNull);
  });

  test('corner/wall bounce does not stall near boundary', () {
    final ball = Ball(
      id: 0,
      position: const Offset(0.02, 0.12),
      previousPosition: const Offset(0.025, 0.125),
      velocity: const Offset(-0.01, -0.04),
      radius: GameTuning.ballRadius,
      active: true,
      grounded: false,
      merged: false,
      flightTimeSeconds: 0,
    );

    var state = _baseState(
      phase: GamePhase.busy,
      balls: [ball],
      ballCount: 1,
      activeBallCount: 1,
      ballsToFire: 0,
      bricks: const [],
    );

    for (var i = 0; i < 2000; i++) {
      state = engine.tick(state, 1 / 120);
      if (state.phase == GamePhase.idle) {
        break;
      }
    }

    expect(state.phase, GamePhase.idle);
  });
}

GameState _baseState({
  List<Ball>? balls,
  List<Brick>? bricks,
  int ballCount = 3,
  GamePhase phase = GamePhase.idle,
  int ballsToFire = 0,
  int activeBallCount = 0,
  double? nextLauncherX,
  double damageMultiplier = 1,
  LevelProgress? levelProgress,
}) {
  final launcher = const Launcher(
    x: 0.5,
    y: GameTuning.launcherY,
    aimAngle: -90,
  );

  final progress = levelProgress ?? const LevelPlanBuilder().buildForLevel(1);

  return GameState(
    phase: phase,
    balls:
        balls ??
        List<Ball>.generate(
          ballCount,
          (index) => Ball(
            id: index,
            position: Offset(launcher.x, launcher.y),
            previousPosition: Offset(launcher.x, launcher.y),
            velocity: Offset.zero,
            radius: GameTuning.ballRadius,
            active: false,
            grounded: false,
            merged: false,
            flightTimeSeconds: 0,
          ),
        ),
    ballsToFire: ballsToFire,
    activeBallCount: activeBallCount,
    nextLauncherX: nextLauncherX,
    launcher: launcher,
    bricks: bricks ?? const [],
    turnIndex: 1,
    score: 0,
    ballCount: ballCount,
    isInputLocked: false,
    lastUpdateMicros: 0,
    bestScore: 0,
    fireTimer: 0,
    shouldShowGameOverDialog: false,
    levelProgress: progress,
    damageMultiplier: damageMultiplier,
    wavePatternLast: WavePattern.random,
    pendingLevelUpDialog: false,
    totalCoins: 0,
    coinsEarnedThisLevel: 0,
    coinsPaidBucketsInRun: 0,
    highestLevelReached: 1,
    launchSpeedMultiplier: 1.0,
  );
}
