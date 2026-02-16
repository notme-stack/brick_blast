import 'dart:math';

import '../models/brick.dart';
import '../models/level_progress.dart';
import '../models/wave_pattern.dart';
import 'game_tuning.dart';

class BrickRowGenerator {
  BrickRowGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<Brick> generateWaveRow({
    required LevelProgress progress,
    required WavePattern pattern,
    required bool isBossWave,
    required int columns,
    required int startId,
    int minBrickCount = 1,
  }) {
    var bricks = <Brick>[];
    var id = startId;

    final normalHp = max(
      1,
      ((progress.levelIndex - 1) * 3) + ((progress.wavesSpawned + 1) ~/ 2),
    );
    var hp = normalHp;
    if (isBossWave) {
      hp = (normalHp * GameTuning.bossHpMultiplier).ceil();
    }

    final colorTier = isBossWave ? 8 : ((progress.wavesSpawned ~/ 2) % 8);

    for (var col = 0; col < columns; col++) {
      final shouldPlace = _shouldPlaceBrick(
        pattern: pattern,
        col: col,
        columns: columns,
        density: _rowDensity(progress),
      );

      if (!shouldPlace) {
        continue;
      }

      bricks.add(Brick(id: id, row: 0, col: col, hp: hp, colorTier: colorTier));
      id++;
    }

    if (bricks.length < minBrickCount) {
      bricks = _enforceMinimumBricks(
        bricks: bricks,
        columns: columns,
        minBrickCount: minBrickCount,
        startId: startId,
        hp: hp,
        colorTier: colorTier,
      );
    }

    return bricks;
  }

  List<Brick> generateRow({
    required int turnIndex,
    required int score,
    required int columns,
    required int baseHp,
    required double density,
    required int startId,
  }) {
    final bricks = <Brick>[];
    var id = startId;
    for (var col = 0; col < columns; col++) {
      if (_random.nextDouble() >= density) {
        continue;
      }
      final hp = baseHp + (turnIndex ~/ 2);
      bricks.add(
        Brick(
          id: id,
          row: 0,
          col: col,
          hp: hp,
          colorTier: (turnIndex ~/ 2) % 8,
        ),
      );
      id++;
    }
    if (bricks.isEmpty) {
      final forcedCol = _random.nextInt(columns);
      bricks.add(
        Brick(
          id: startId,
          row: 0,
          col: forcedCol,
          hp: max(1, baseHp),
          colorTier: 0,
        ),
      );
    }
    return bricks;
  }

  bool _shouldPlaceBrick({
    required WavePattern pattern,
    required int col,
    required int columns,
    required double density,
  }) {
    return switch (pattern) {
      WavePattern.wall => true,
      WavePattern.boss => true,
      WavePattern.pillars => col % 2 == 0,
      WavePattern.checkerboard => col % 2 == 0 || _random.nextDouble() < 0.25,
      WavePattern.random => _random.nextDouble() < density,
    };
  }

  double _rowDensity(LevelProgress progress) {
    final phase = progress.wavesSpawned / progress.wavesTotal;
    final base = GameTuning.rowDensity;
    final growth = 0.16 * phase;
    return (base + growth).clamp(0.45, 0.78);
  }

  List<Brick> _enforceMinimumBricks({
    required List<Brick> bricks,
    required int columns,
    required int minBrickCount,
    required int startId,
    required int hp,
    required int colorTier,
  }) {
    final usedCols = {for (final brick in bricks) brick.col};
    final allCols = List<int>.generate(columns, (index) => index)
      ..shuffle(_random);
    var id = bricks.fold<int>(startId - 1, (maxId, brick) {
      if (brick.id > maxId) {
        return brick.id;
      }
      return maxId;
    });

    final ensured = List<Brick>.from(bricks);
    for (final col in allCols) {
      if (ensured.length >= minBrickCount) {
        break;
      }
      if (usedCols.contains(col)) {
        continue;
      }
      id++;
      ensured.add(
        Brick(id: id, row: 0, col: col, hp: hp, colorTier: colorTier),
      );
      usedCols.add(col);
    }

    if (ensured.isEmpty) {
      ensured.add(
        Brick(
          id: startId,
          row: 0,
          col: _random.nextInt(columns),
          hp: hp,
          colorTier: colorTier,
        ),
      );
    }

    return ensured;
  }
}
