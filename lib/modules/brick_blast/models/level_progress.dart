import 'level_type.dart';

class LevelProgress {
  const LevelProgress({
    required this.levelIndex,
    required this.levelType,
    required this.wavesTotal,
    required this.wavesSpawned,
    required this.inCleanupPhase,
    required this.bossSpawned,
    required this.levelCompleted,
  });

  final int levelIndex;
  final LevelType levelType;
  final int wavesTotal;
  final int wavesSpawned;
  final bool inCleanupPhase;
  final bool bossSpawned;
  final bool levelCompleted;

  LevelProgress copyWith({
    int? levelIndex,
    LevelType? levelType,
    int? wavesTotal,
    int? wavesSpawned,
    bool? inCleanupPhase,
    bool? bossSpawned,
    bool? levelCompleted,
  }) {
    return LevelProgress(
      levelIndex: levelIndex ?? this.levelIndex,
      levelType: levelType ?? this.levelType,
      wavesTotal: wavesTotal ?? this.wavesTotal,
      wavesSpawned: wavesSpawned ?? this.wavesSpawned,
      inCleanupPhase: inCleanupPhase ?? this.inCleanupPhase,
      bossSpawned: bossSpawned ?? this.bossSpawned,
      levelCompleted: levelCompleted ?? this.levelCompleted,
    );
  }
}
