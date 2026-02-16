import '../models/level_progress.dart';
import '../models/level_type.dart';

class LevelPlanBuilder {
  const LevelPlanBuilder();

  LevelProgress buildForLevel(int levelIndex) {
    final normalizedLevel = levelIndex < 1 ? 1 : levelIndex;
    final wavesTotal = 8 + (normalizedLevel * 2);

    return LevelProgress(
      levelIndex: normalizedLevel,
      levelType: LevelType.standard,
      wavesTotal: wavesTotal,
      wavesSpawned: 0,
      inCleanupPhase: false,
      bossSpawned: false,
      levelCompleted: false,
    );
  }
}
