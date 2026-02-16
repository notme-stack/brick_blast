import 'package:flutter/material.dart';

import '../data/brick_row_generator.dart';
import '../data/game_tuning.dart';
import '../models/ball.dart';
import '../models/game_phase.dart';
import '../models/game_state.dart';
import 'level_progression_service.dart';

class TurnResolver {
  TurnResolver({
    required BrickRowGenerator rowGenerator,
    required LevelProgressionService progressionService,
  }) : _rowGenerator = rowGenerator,
       _progressionService = progressionService;

  final BrickRowGenerator _rowGenerator;
  final LevelProgressionService _progressionService;

  GameState resolve(GameState state) {
    final mergedX = state.nextLauncherX ?? state.launcher.x;
    var bricks = state.bricks
        .map((brick) => brick.copyWith(row: brick.row + 1))
        .toList();
    var progress = state.levelProgress;
    var wavePattern = state.wavePatternLast;

    if (_progressionService.shouldSpawnWave(progress)) {
      final isBossWave = _progressionService.isBossWave(progress);
      final pattern = _progressionService.determineNextPattern(progress);
      final maxId = bricks.fold<int>(
        0,
        (acc, brick) => brick.id > acc ? brick.id : acc,
      );
      final newRow = _rowGenerator.generateWaveRow(
        progress: progress,
        pattern: pattern,
        isBossWave: isBossWave,
        columns: GameTuning.columns,
        startId: maxId + 1,
      );
      bricks = [...bricks, ...newRow];
      progress = _progressionService.onWaveSpawned(
        progress,
        bossWave: isBossWave,
      );
      wavePattern = pattern;
    }

    if (progress.inCleanupPhase && bricks.isEmpty) {
      progress = _progressionService.markLevelComplete(progress);
    }

    final isGameOver = bricks.any(
      (brick) =>
          GameTuning.isAtOrPastDangerLine(GameTuning.brickBottomY(brick.row)),
    );
    final launcher = state.launcher.copyWith(x: mergedX);
    final nextBallCount = state.ballCount + 1;
    final balls = List<Ball>.generate(
      nextBallCount,
      (index) => Ball(
        id: index,
        position: Offset(mergedX, GameTuning.launcherY),
        previousPosition: Offset(mergedX, GameTuning.launcherY),
        velocity: Offset.zero,
        radius: GameTuning.ballRadius,
        active: false,
        grounded: false,
        merged: false,
        flightTimeSeconds: 0,
      ),
    );

    return state.copyWith(
      phase: isGameOver ? GamePhase.gameOver : GamePhase.idle,
      balls: balls,
      ballsToFire: 0,
      activeBallCount: 0,
      clearNextLauncherX: true,
      launcher: launcher,
      bricks: bricks,
      turnIndex: state.turnIndex + 1,
      isInputLocked: isGameOver,
      fireTimer: 0,
      shouldShowGameOverDialog: isGameOver,
      levelProgress: progress,
      ballCount: nextBallCount,
      damageMultiplier: _progressionService.damageMultiplier(progress),
      wavePatternLast: wavePattern,
      pendingLevelUpDialog: progress.levelCompleted,
    );
  }
}
