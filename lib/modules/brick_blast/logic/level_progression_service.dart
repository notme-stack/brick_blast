import '../data/game_tuning.dart';
import '../models/level_progress.dart';
import '../models/level_type.dart';
import '../models/wave_pattern.dart';

class LevelProgressionService {
  const LevelProgressionService();

  WavePattern determineNextPattern(LevelProgress progress) {
    if (isBossWave(progress)) {
      return WavePattern.boss;
    }

    final nextWaveNumber = progress.wavesSpawned + 1;
    final canUseWallWaves =
        progress.levelIndex >= GameTuning.wallWavesStartLevel;
    if (canUseWallWaves && nextWaveNumber % GameTuning.wallFrequency == 0) {
      return WavePattern.wall;
    }

    final bucket = nextWaveNumber % 3;
    if (bucket == 1) {
      return WavePattern.random;
    }
    if (bucket == 2) {
      return WavePattern.pillars;
    }
    return WavePattern.checkerboard;
  }

  bool shouldSpawnWave(LevelProgress progress) {
    return !progress.inCleanupPhase;
  }

  bool isBossWave(LevelProgress progress) {
    return progress.wavesSpawned + 1 == progress.wavesTotal;
  }

  LevelProgress onWaveSpawned(
    LevelProgress progress, {
    required bool bossWave,
  }) {
    final spawned = progress.wavesSpawned + 1;
    final cleanup = spawned >= progress.wavesTotal;
    return progress.copyWith(
      wavesSpawned: spawned,
      bossSpawned: progress.bossSpawned || bossWave,
      inCleanupPhase: cleanup,
    );
  }

  LevelProgress markLevelComplete(LevelProgress progress) {
    return progress.copyWith(levelCompleted: true);
  }

  double damageMultiplier(LevelProgress progress) {
    return progress.levelType == LevelType.blitz
        ? GameTuning.blitzDamageMultiplier
        : 1.0;
  }

  double launchSpeedMultiplier(LevelProgress progress) {
    if (!progress.inCleanupPhase) {
      return 1.0;
    }
    return GameTuning.cleanupAssistSpeedMultiplier;
  }
}
