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
    this.checkpointBallCount = 0,
    this.ballCapAtLevelStart = 0,
    this.overflowBallsOnClear = 0,
  });

  final int levelIndex;
  final LevelType levelType;
  final int wavesTotal;
  final int wavesSpawned;
  final bool inCleanupPhase;
  final bool bossSpawned;
  final bool levelCompleted;
  final int checkpointBallCount;
  final int ballCapAtLevelStart;
  final int overflowBallsOnClear;

  LevelProgress copyWith({
    int? levelIndex,
    LevelType? levelType,
    int? wavesTotal,
    int? wavesSpawned,
    bool? inCleanupPhase,
    bool? bossSpawned,
    bool? levelCompleted,
    int? checkpointBallCount,
    int? ballCapAtLevelStart,
    int? overflowBallsOnClear,
  }) {
    return LevelProgress(
      levelIndex: levelIndex ?? this.levelIndex,
      levelType: levelType ?? this.levelType,
      wavesTotal: wavesTotal ?? this.wavesTotal,
      wavesSpawned: wavesSpawned ?? this.wavesSpawned,
      inCleanupPhase: inCleanupPhase ?? this.inCleanupPhase,
      bossSpawned: bossSpawned ?? this.bossSpawned,
      levelCompleted: levelCompleted ?? this.levelCompleted,
      checkpointBallCount: checkpointBallCount ?? this.checkpointBallCount,
      ballCapAtLevelStart: ballCapAtLevelStart ?? this.ballCapAtLevelStart,
      overflowBallsOnClear: overflowBallsOnClear ?? this.overflowBallsOnClear,
    );
  }
}
