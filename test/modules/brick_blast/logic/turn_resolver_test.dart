import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/modules/brick_blast/data/brick_row_generator.dart';
import 'package:brick_blast/modules/brick_blast/data/game_tuning.dart';
import 'package:brick_blast/modules/brick_blast/models/ball.dart';
import 'package:brick_blast/modules/brick_blast/models/brick.dart';
import 'package:brick_blast/modules/brick_blast/models/game_phase.dart';
import 'package:brick_blast/modules/brick_blast/models/game_state.dart';
import 'package:brick_blast/modules/brick_blast/models/launcher.dart';
import 'package:brick_blast/modules/brick_blast/models/level_progress.dart';
import 'package:brick_blast/modules/brick_blast/models/level_type.dart';
import 'package:brick_blast/modules/brick_blast/models/wave_pattern.dart';
import 'package:brick_blast/modules/brick_blast/logic/level_progression_service.dart';
import 'package:brick_blast/modules/brick_blast/logic/turn_resolver.dart';

void main() {
  final resolver = TurnResolver(
    rowGenerator: BrickRowGenerator(),
    progressionService: const LevelProgressionService(),
  );

  test('danger helper returns true when brick bottom equals line', () {
    expect(
      GameTuning.isAtOrPastDangerLine(GameTuning.dangerLineYNormalized),
      true,
    );
  });

  test('brick bottom below danger line does not trigger game over', () {
    final state = _baseStateWithBrickRow(8);
    final resolved = resolver.resolve(state);

    expect(resolved.phase, GamePhase.idle);
    expect(resolved.shouldShowGameOverDialog, false);
  });

  test('brick bottom at/past danger line triggers game over', () {
    final atThresholdState = _baseStateWithBrickRow(9);
    final pastThresholdState = _baseStateWithBrickRow(10);

    final atThresholdResolved = resolver.resolve(atThresholdState);
    final pastThresholdResolved = resolver.resolve(pastThresholdState);

    expect(atThresholdResolved.phase, GamePhase.gameOver);
    expect(atThresholdResolved.shouldShowGameOverDialog, true);

    expect(pastThresholdResolved.phase, GamePhase.gameOver);
    expect(pastThresholdResolved.shouldShowGameOverDialog, true);
  });

  test('end turn increases launch speed multiplier by 7%', () {
    final state = _baseStateWithBrickRow(
      8,
    ).copyWith(launchSpeedMultiplier: 1.0);

    final resolved = resolver.resolve(state);

    expect(
      resolved.launchSpeedMultiplier,
      closeTo(GameTuning.turnSpeedGrowthMultiplier, 1e-9),
    );
  });

  test('end turn launch speed multiplier is capped at x2', () {
    final state = _baseStateWithBrickRow(
      8,
    ).copyWith(launchSpeedMultiplier: 1.99);

    final resolved = resolver.resolve(state);

    expect(resolved.launchSpeedMultiplier, GameTuning.maxLaunchSpeedMultiplier);
  });
}

GameState _baseStateWithBrickRow(int row) {
  const launcher = Launcher(x: 0.5, y: GameTuning.launcherY, aimAngle: -90);
  const progress = LevelProgress(
    levelIndex: 1,
    levelType: LevelType.standard,
    wavesTotal: 10,
    wavesSpawned: 10,
    inCleanupPhase: true,
    bossSpawned: true,
    levelCompleted: false,
  );

  return GameState(
    phase: GamePhase.endTurn,
    balls: const [
      Ball(
        id: 0,
        position: Offset(0.5, GameTuning.launcherY),
        previousPosition: Offset(0.5, GameTuning.launcherY),
        velocity: Offset.zero,
        radius: GameTuning.ballRadius,
        active: false,
        grounded: true,
        merged: true,
        flightTimeSeconds: 0,
      ),
    ],
    ballsToFire: 0,
    activeBallCount: 0,
    nextLauncherX: 0.5,
    launcher: launcher,
    bricks: [Brick(id: 1, row: row, col: 0, hp: 1, colorTier: 0)],
    turnIndex: 1,
    score: 0,
    ballCount: 1,
    isInputLocked: true,
    lastUpdateMicros: 0,
    bestScore: 0,
    fireTimer: 0,
    shouldShowGameOverDialog: false,
    levelProgress: progress,
    damageMultiplier: 1,
    wavePatternLast: WavePattern.random,
    pendingLevelUpDialog: false,
    totalCoins: 0,
    coinsEarnedThisLevel: 0,
    coinsPaidBucketsInRun: 0,
    highestLevelReached: 1,
    launchSpeedMultiplier: 1.0,
  );
}
