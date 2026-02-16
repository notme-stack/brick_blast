import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:brick_blast/modules/brick_blast/data/brick_row_generator.dart';
import 'package:brick_blast/modules/brick_blast/data/game_tuning.dart';
import 'package:brick_blast/modules/brick_blast/data/level_plan_builder.dart';
import 'package:brick_blast/modules/brick_blast/logic/level_progression_service.dart';
import 'package:brick_blast/modules/brick_blast/models/wave_pattern.dart';

void main() {
  const builder = LevelPlanBuilder();
  const progression = LevelProgressionService();

  test('level planner uses formula wavesTotal = 8 + (level * 2)', () {
    final level1 = builder.buildForLevel(1);
    final level2 = builder.buildForLevel(2);
    final level5 = builder.buildForLevel(5);

    expect(level1.wavesTotal, 10);
    expect(level2.wavesTotal, 12);
    expect(level5.wavesTotal, 18);
  });

  test('wall waves are gated to level 6+ and every 5th wave', () {
    final level1 = builder.buildForLevel(1).copyWith(wavesSpawned: 4);
    final level6 = builder.buildForLevel(6).copyWith(wavesSpawned: 4);

    expect(progression.determineNextPattern(level1), isNot(WavePattern.wall));
    expect(progression.determineNextPattern(level6), WavePattern.wall);
  });

  test('final wave is boss pattern', () {
    final progress = builder.buildForLevel(1).copyWith(wavesSpawned: 9);
    expect(progression.determineNextPattern(progress), WavePattern.boss);
  });

  test('cleanup phase starts after final spawn and completes when cleared', () {
    final progress = builder.buildForLevel(1).copyWith(wavesSpawned: 9);
    final afterSpawn = progression.onWaveSpawned(progress, bossWave: true);

    expect(afterSpawn.inCleanupPhase, true);

    final completed = progression.markLevelComplete(afterSpawn);
    expect(completed.levelCompleted, true);
  });

  test('row generator wall pattern has no gaps', () {
    final generator = BrickRowGenerator(random: Random(1));
    final progress = builder.buildForLevel(6).copyWith(wavesSpawned: 4);

    final wallRow = generator.generateWaveRow(
      progress: progress,
      pattern: WavePattern.wall,
      isBossWave: false,
      columns: GameTuning.columns,
      startId: 1,
    );

    expect(wallRow.length, GameTuning.columns);
  });

  test('prefill-style row generation guarantees at least 3 bricks', () {
    final generator = BrickRowGenerator(random: Random(9));
    final progress = builder.buildForLevel(1);

    final row = generator.generateWaveRow(
      progress: progress,
      pattern: WavePattern.random,
      isBossWave: false,
      columns: GameTuning.columns,
      startId: 1,
      minBrickCount: 3,
    );

    expect(row.length, greaterThanOrEqualTo(3));
  });
}
