import 'ball.dart';
import 'brick.dart';
import 'game_phase.dart';
import 'launcher.dart';
import 'level_progress.dart';
import 'projectile_style.dart';
import 'wave_pattern.dart';

class GameState {
  const GameState({
    required this.phase,
    required this.balls,
    required this.ballsToFire,
    required this.activeBallCount,
    required this.nextLauncherX,
    required this.launcher,
    required this.bricks,
    required this.turnIndex,
    required this.score,
    required this.ballCount,
    required this.isInputLocked,
    required this.lastUpdateMicros,
    required this.bestScore,
    required this.fireTimer,
    required this.shouldShowGameOverDialog,
    required this.levelProgress,
    required this.damageMultiplier,
    required this.wavePatternLast,
    required this.pendingLevelUpDialog,
    this.projectileStyle = ProjectileStyle.dotted,
    this.totalCoins = 0,
    this.coinsEarnedThisLevel = 0,
    this.coinsPaidBucketsInRun = 0,
    this.highestLevelReached = 1,
    this.launchSpeedMultiplier = 1.0,
    this.levelEntryBallCount = 10,
    this.ballCapForLevel = 30,
    this.overflowBallsLastClear = 0,
    this.coinsFromOverflowLastClear = 0,
  });

  final GamePhase phase;
  final List<Ball> balls;
  final int ballsToFire;
  final int activeBallCount;
  final double? nextLauncherX;
  final Launcher launcher;
  final List<Brick> bricks;
  final int turnIndex;
  final int score;
  final int ballCount;
  final bool isInputLocked;
  final int lastUpdateMicros;
  final int bestScore;
  final double fireTimer;
  final bool shouldShowGameOverDialog;
  final LevelProgress levelProgress;
  final double damageMultiplier;
  final WavePattern wavePatternLast;
  final bool pendingLevelUpDialog;
  final ProjectileStyle projectileStyle;
  final int totalCoins;
  final int coinsEarnedThisLevel;
  final int coinsPaidBucketsInRun;
  final int highestLevelReached;
  final double launchSpeedMultiplier;
  final int levelEntryBallCount;
  final int ballCapForLevel;
  final int overflowBallsLastClear;
  final int coinsFromOverflowLastClear;

  GameState copyWith({
    GamePhase? phase,
    List<Ball>? balls,
    int? ballsToFire,
    int? activeBallCount,
    double? nextLauncherX,
    bool clearNextLauncherX = false,
    Launcher? launcher,
    List<Brick>? bricks,
    int? turnIndex,
    int? score,
    int? ballCount,
    bool? isInputLocked,
    int? lastUpdateMicros,
    int? bestScore,
    double? fireTimer,
    bool? shouldShowGameOverDialog,
    LevelProgress? levelProgress,
    double? damageMultiplier,
    WavePattern? wavePatternLast,
    bool? pendingLevelUpDialog,
    ProjectileStyle? projectileStyle,
    int? totalCoins,
    int? coinsEarnedThisLevel,
    int? coinsPaidBucketsInRun,
    int? highestLevelReached,
    double? launchSpeedMultiplier,
    int? levelEntryBallCount,
    int? ballCapForLevel,
    int? overflowBallsLastClear,
    int? coinsFromOverflowLastClear,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      balls: balls ?? this.balls,
      ballsToFire: ballsToFire ?? this.ballsToFire,
      activeBallCount: activeBallCount ?? this.activeBallCount,
      nextLauncherX: clearNextLauncherX
          ? null
          : (nextLauncherX ?? this.nextLauncherX),
      launcher: launcher ?? this.launcher,
      bricks: bricks ?? this.bricks,
      turnIndex: turnIndex ?? this.turnIndex,
      score: score ?? this.score,
      ballCount: ballCount ?? this.ballCount,
      isInputLocked: isInputLocked ?? this.isInputLocked,
      lastUpdateMicros: lastUpdateMicros ?? this.lastUpdateMicros,
      bestScore: bestScore ?? this.bestScore,
      fireTimer: fireTimer ?? this.fireTimer,
      shouldShowGameOverDialog:
          shouldShowGameOverDialog ?? this.shouldShowGameOverDialog,
      levelProgress: levelProgress ?? this.levelProgress,
      damageMultiplier: damageMultiplier ?? this.damageMultiplier,
      wavePatternLast: wavePatternLast ?? this.wavePatternLast,
      pendingLevelUpDialog: pendingLevelUpDialog ?? this.pendingLevelUpDialog,
      projectileStyle: projectileStyle ?? this.projectileStyle,
      totalCoins: totalCoins ?? this.totalCoins,
      coinsEarnedThisLevel: coinsEarnedThisLevel ?? this.coinsEarnedThisLevel,
      coinsPaidBucketsInRun:
          coinsPaidBucketsInRun ?? this.coinsPaidBucketsInRun,
      highestLevelReached: highestLevelReached ?? this.highestLevelReached,
      launchSpeedMultiplier:
          launchSpeedMultiplier ?? this.launchSpeedMultiplier,
      levelEntryBallCount: levelEntryBallCount ?? this.levelEntryBallCount,
      ballCapForLevel: ballCapForLevel ?? this.ballCapForLevel,
      overflowBallsLastClear:
          overflowBallsLastClear ?? this.overflowBallsLastClear,
      coinsFromOverflowLastClear:
          coinsFromOverflowLastClear ?? this.coinsFromOverflowLastClear,
    );
  }
}
