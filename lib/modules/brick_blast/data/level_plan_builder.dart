import '../models/level_progress.dart';
import '../models/level_type.dart';
import 'game_tuning.dart';

class LevelPlanBuilder {
  const LevelPlanBuilder();

  LevelProgress buildForLevel(int levelIndex) {
    final normalizedLevel = levelIndex < 1 ? 1 : levelIndex;
    final wavesTotal = GameTuning.wavesForLevel(normalizedLevel);

    return LevelProgress(
      levelIndex: normalizedLevel,
      levelType: LevelType.standard,
      wavesTotal: wavesTotal,
      wavesSpawned: 0,
      inCleanupPhase: false,
      bossSpawned: false,
      levelCompleted: false,
      checkpointBallCount: GameTuning.initialBallCount,
      ballCapAtLevelStart: GameTuning.maxBallsForLevel(normalizedLevel),
      overflowBallsOnClear: 0,
    );
  }
}
