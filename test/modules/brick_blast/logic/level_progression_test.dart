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

  test('level planner uses logarithmic waves formula with cap', () {
    final level1 = builder.buildForLevel(1);
    final level10 = builder.buildForLevel(10);
    final level100 = builder.buildForLevel(100);
    final level1000 = builder.buildForLevel(1000);
    final levelHuge = builder.buildForLevel(1000000);

    expect(level1.wavesTotal, 10);
    expect(level10.wavesTotal, 23);
    expect(level100.wavesTotal, 37);
    expect(level1000.wavesTotal, 51);
    expect(levelHuge.wavesTotal, GameTuning.maxWavesPerLevel);
  });

  test('ball cap helper uses logarithmic formula', () {
    expect(GameTuning.maxBallsForLevel(1), 30);
    expect(GameTuning.maxBallsForLevel(10), 110);
    expect(GameTuning.maxBallsForLevel(100), 191);
    expect(GameTuning.maxBallsForLevel(1000), 271);
  });

  test('hp helper uses level*3 + wave and boss multiplier', () {
    final normal = GameTuning.baseHpForWave(10, 23);
    final boss = (normal * GameTuning.bossHpMultiplier).ceil();

    expect(GameTuning.baseHpForWave(1, 1), 4);
    expect(normal, 53);
    expect(boss, 133);
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
