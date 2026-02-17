import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app_shell/feature_flags.dart';
import '../../../capabilities/analytics/analytics_service.dart';
import '../../../capabilities/storage/local_storage_service.dart';
import '../data/brick_row_generator.dart';
import '../data/game_tuning.dart';
import '../data/level_plan_builder.dart';
import '../models/ball.dart';
import '../models/brick.dart';
import '../models/game_phase.dart';
import '../models/game_state.dart';
import '../models/launcher.dart';
import '../models/level_progress.dart';
import '../models/projectile_style.dart';
import '../models/wave_pattern.dart';
import 'level_progression_service.dart';
import 'simulation_engine.dart';
import 'turn_resolver.dart';

class GameController extends ChangeNotifier {
  GameController({
    required LocalStorageService storageService,
    required AnalyticsService analyticsService,
    BrickRowGenerator? rowGenerator,
    LevelPlanBuilder? planBuilder,
    LevelProgressionService? progressionService,
    SimulationEngine? engine,
  }) : _storageService = storageService,
       _analyticsService = analyticsService,
       _rowGenerator = rowGenerator ?? BrickRowGenerator(),
       _planBuilder = planBuilder ?? const LevelPlanBuilder(),
       _progressionService =
           progressionService ?? const LevelProgressionService(),
       _engine =
           engine ??
           SimulationEngine(
             turnResolver: TurnResolver(
               rowGenerator: rowGenerator ?? BrickRowGenerator(),
               progressionService:
                   progressionService ?? const LevelProgressionService(),
             ),
           ) {
    _state = _buildInitialState();
    _loadPersistedProgress();
    _logGameStart();
    _logLevelStart();
  }

  final LocalStorageService _storageService;
  final AnalyticsService _analyticsService;
  final BrickRowGenerator _rowGenerator;
  final LevelPlanBuilder _planBuilder;
  final LevelProgressionService _progressionService;
  final SimulationEngine _engine;

  late GameState _state;
  double _accumulator = 0;

  static const double _fixedStep = 1 / 120;
  static const int _maxFixedStepsPerTick = 30;
  static const double _maxDeltaSecondsPerTick = 0.25;
  static const String bestScoreKey = 'brick_blast_best_score';
  static const String highestLevelKey = 'brick_blast_highest_level';
  static const String totalCoinsKey = 'brick_blast_total_coins';
  static const String projectileStyleKey = 'brick_blast_projectile_style';
  static const String resumeLevelKey = 'brick_blast_resume_level';
  static const String resumeBallCountKey = 'brick_blast_resume_ball_count';
  static const String resumeScoreKey = 'brick_blast_resume_score';
  static const String resumePaidBucketsKey = 'brick_blast_resume_paid_buckets';
  static const String resumeValidKey = 'brick_blast_resume_valid';

  GameState get state => _state;

  Future<void> _loadPersistedProgress() async {
    final best = _storageService.read<int>(bestScoreKey) ?? 0;
    final highest = _storageService.read<int>(highestLevelKey) ?? 1;
    final totalCoins = _storageService.read<int>(totalCoinsKey) ?? 0;
    final resumeValid = _storageService.read<bool>(resumeValidKey) ?? false;
    final resumeLevel = _storageService.read<int>(resumeLevelKey) ?? highest;
    final resumeBallCount =
        _storageService.read<int>(resumeBallCountKey) ??
        GameTuning.initialBallCount;
    final resumeScore = _storageService.read<int>(resumeScoreKey) ?? 0;
    final resumePaidBuckets =
        _storageService.read<int>(resumePaidBucketsKey) ?? 0;
    final styleName = _storageService.read<String>(projectileStyleKey);
    final projectileStyle = ProjectileStyle.values.firstWhere(
      (style) => style.name == styleName,
      orElse: () => ProjectileStyle.dotted,
    );
    final levelIndex = resumeValid
        ? max(1, resumeLevel)
        : max(1, max(highest, _state.levelProgress.levelIndex));
    final ballCount = resumeValid
        ? max(GameTuning.initialBallCount, resumeBallCount)
        : GameTuning.initialBallCount;
    final ballCap = GameTuning.maxBallsForLevel(levelIndex);
    final progressSeed = _planBuilder.buildForLevel(levelIndex);
    final prefill = _prefillLevel(
      progressSeed.copyWith(
        checkpointBallCount: ballCount,
        ballCapAtLevelStart: ballCap,
      ),
    );

    _state = _state.copyWith(
      bestScore: best,
      balls: _freshBalls(0.5, count: ballCount),
      levelProgress: prefill.progress,
      bricks: prefill.bricks,
      wavePatternLast: prefill.wavePattern,
      damageMultiplier: _progressionService.damageMultiplier(prefill.progress),
      highestLevelReached: max(highest, levelIndex),
      totalCoins: totalCoins,
      projectileStyle: projectileStyle,
      coinsEarnedThisLevel: 0,
      coinsPaidBucketsInRun: resumeValid ? resumePaidBuckets : 0,
      ballCount: ballCount,
      score: resumeValid ? max(0, resumeScore) : 0,
      levelEntryBallCount: ballCount,
      ballCapForLevel: ballCap,
      overflowBallsLastClear: 0,
      coinsFromOverflowLastClear: 0,
    );
    notifyListeners();
  }

  Future<void> _persistBestScore(int score) async {
    await _storageService.write(bestScoreKey, score);
  }

  Future<void> _persistHighestLevel(int level) async {
    await _storageService.write(highestLevelKey, level);
  }

  Future<void> _persistTotalCoins(int coins) async {
    await _storageService.write(totalCoinsKey, coins);
  }

  Future<void> _persistProjectileStyle(ProjectileStyle style) async {
    await _storageService.write(projectileStyleKey, style.name);
  }

  Future<void> _persistRunSnapshot({
    required int levelIndex,
    required int ballCount,
    required int score,
    required int coinsPaidBucketsInRun,
  }) async {
    await _storageService.write(resumeLevelKey, levelIndex);
    await _storageService.write(resumeBallCountKey, ballCount);
    await _storageService.write(resumeScoreKey, score);
    await _storageService.write(resumePaidBucketsKey, coinsPaidBucketsInRun);
    await _storageService.write(resumeValidKey, true);
  }

  Future<void> _clearRunSnapshot() async {
    await _storageService.write(resumeValidKey, false);
    await _storageService.write(resumeLevelKey, null);
    await _storageService.write(resumeBallCountKey, null);
    await _storageService.write(resumeScoreKey, null);
    await _storageService.write(resumePaidBucketsKey, null);
  }

  Future<void> _logGameStart() {
    return _analyticsService.logEvent(
      'game_start',
      params: {'module': 'brick_blast'},
    );
  }

  Future<void> _logTurnEnd() {
    return _analyticsService.logEvent(
      'turn_end',
      params: {'turn': _state.turnIndex, 'score': _state.score},
    );
  }

  Future<void> _logGameOver() {
    return _analyticsService.logEvent(
      'game_over',
      params: {
        'turn': _state.turnIndex,
        'score': _state.score,
        'level': _state.levelProgress.levelIndex,
      },
    );
  }

  Future<void> _logBestScoreUpdated(int score) {
    return _analyticsService.logEvent(
      'best_score_updated',
      params: {'score': score},
    );
  }

  Future<void> _logLevelStart() {
    return _analyticsService.logEvent(
      'level_start',
      params: {
        'level': _state.levelProgress.levelIndex,
        'type': _state.levelProgress.levelType.name,
      },
    );
  }

  Future<void> _logWaveSpawned() {
    return _analyticsService.logEvent(
      'wave_spawned',
      params: {
        'level': _state.levelProgress.levelIndex,
        'wave': _state.levelProgress.wavesSpawned,
        'pattern': _state.wavePatternLast.name,
      },
    );
  }

  Future<void> _logCleanupStart() {
    return _analyticsService.logEvent(
      'cleanup_start',
      params: {
        'level': _state.levelProgress.levelIndex,
        'waves_total': _state.levelProgress.wavesTotal,
      },
    );
  }

  Future<void> _logBossWaveStart() {
    return _analyticsService.logEvent(
      'boss_wave_start',
      params: {
        'level': _state.levelProgress.levelIndex,
        'wave': _state.levelProgress.wavesSpawned,
      },
    );
  }

  Future<void> _logLevelComplete() {
    return _analyticsService.logEvent(
      'level_complete',
      params: {
        'level': _state.levelProgress.levelIndex,
        'score': _state.score,
        'coins_earned_this_level': _state.coinsEarnedThisLevel,
        'total_coins': _state.totalCoins,
      },
    );
  }

  Future<void> _logCoinsAwarded(int coinsAwarded) {
    return _analyticsService.logEvent(
      'coins_awarded',
      params: {
        'level': _state.levelProgress.levelIndex,
        'coins_awarded': coinsAwarded,
        'total_coins': _state.totalCoins,
      },
    );
  }

  void onPointerDown(Offset normalizedPointer) {
    _updateState(_engine.startAiming(_state, normalizedPointer));
  }

  void onPointerMove(Offset normalizedPointer) {
    _updateState(_engine.updateAim(_state, normalizedPointer));
  }

  void onPointerUp() {
    _updateState(_engine.releaseFire(_state));
  }

  void triggerRecall() {
    if (!FeatureFlags.brickBlastRecallEnabled) {
      return;
    }
    if (_state.isRecalling) {
      return;
    }
    if (_state.phase != GamePhase.firing && _state.phase != GamePhase.busy) {
      return;
    }
    if (_state.nextLauncherX == null) {
      return;
    }
    final anchorX = _state.nextLauncherX!;
    final anchor = Offset(anchorX, GameTuning.launcherY);
    final normalizedBalls = _state.balls.map((ball) {
      if (ball.active || ball.grounded) {
        return ball;
      }
      return ball.copyWith(
        position: anchor,
        previousPosition: anchor,
        velocity: Offset.zero,
        grounded: true,
        merged: true,
        flightTimeSeconds: 0,
      );
    }).toList();
    final recalculatedActiveCount = normalizedBalls
        .where((ball) => ball.active)
        .length;
    _state = _state.copyWith(
      balls: normalizedBalls,
      isRecalling: true,
      ballsToFire: 0,
      activeBallCount: recalculatedActiveCount,
      phase: GamePhase.busy,
      recallButtonVisible: false,
      isInputLocked: true,
    );
    notifyListeners();
  }

  void tick(double deltaSeconds) {
    final boundedDelta = deltaSeconds.clamp(0, _maxDeltaSecondsPerTick);
    _accumulator += boundedDelta;
    var stateChanged = false;
    var previousTurn = _state.turnIndex;
    var previouslyGameOver = _state.phase == GamePhase.gameOver;
    var previousWaves = _state.levelProgress.wavesSpawned;
    var previousCleanup = _state.levelProgress.inCleanupPhase;
    var previousLevel = _state.levelProgress.levelIndex;
    var previousPendingLevelUp = _state.pendingLevelUpDialog;

    var simulatedSteps = 0;
    while (_accumulator >= _fixedStep &&
        simulatedSteps < _maxFixedStepsPerTick) {
      _accumulator -= _fixedStep;
      final updated = _engine.tick(_state, _fixedStep);
      if (!identical(updated, _state)) {
        _state = _updateBestScore(updated);
        stateChanged = true;
      }
      simulatedSteps++;
    }

    if (_accumulator >= _fixedStep) {
      // Drop stale backlog to avoid long catch-up stalls after frame hiccups.
      _accumulator = 0;
    }

    if (!stateChanged) {
      return;
    }

    if (_state.turnIndex != previousTurn) {
      _logTurnEnd();
    }
    if (!previouslyGameOver && _state.phase == GamePhase.gameOver) {
      _logGameOver();
    }
    if (_state.levelProgress.wavesSpawned != previousWaves) {
      _logWaveSpawned();
      if (_state.wavePatternLast == WavePattern.boss) {
        _logBossWaveStart();
      }
    }
    if (!previousCleanup && _state.levelProgress.inCleanupPhase) {
      _logCleanupStart();
    }
    if (!previousPendingLevelUp && _state.pendingLevelUpDialog) {
      final coinsAwarded = _awardCoinsOnLevelClear();
      if (coinsAwarded > 0) {
        _logCoinsAwarded(coinsAwarded);
      }
      _logLevelComplete();
    }
    if (_state.levelProgress.levelIndex > previousLevel) {
      final newHighest = max(
        _state.highestLevelReached,
        _state.levelProgress.levelIndex,
      );
      _state = _state.copyWith(highestLevelReached: newHighest);
      _persistHighestLevel(newHighest);
      _logLevelStart();
    }

    notifyListeners();
  }

  void restart() {
    // TODO(D-033 follow-up): expose this as explicit "Reset Run" UX action.
    _accumulator = 0;
    _state = _buildInitialState().copyWith(
      bestScore: _state.bestScore,
      totalCoins: _state.totalCoins,
      projectileStyle: _state.projectileStyle,
      highestLevelReached: _state.highestLevelReached,
      coinsPaidBucketsInRun: 0,
      coinsEarnedThisLevel: 0,
      launchSpeedMultiplier: 1.0,
      isRecalling: false,
      recallButtonVisible: false,
    );
    _logGameStart();
    _logLevelStart();
    _clearRunSnapshot();
    notifyListeners();
  }

  void restartLevelFromCheckpoint() {
    retryCurrentLevel();
  }

  void retryCurrentLevel() {
    final retryLevel = max(1, _state.levelProgress.levelIndex);
    final retryBallCount = max(
      GameTuning.initialBallCount,
      _state.levelEntryBallCount,
    );
    final retryBallCap = GameTuning.maxBallsForLevel(retryLevel);
    final progressSeed = _planBuilder
        .buildForLevel(retryLevel)
        .copyWith(
          checkpointBallCount: retryBallCount,
          ballCapAtLevelStart: retryBallCap,
          overflowBallsOnClear: 0,
        );
    final prefill = _prefillLevel(progressSeed);

    _accumulator = 0;
    _state = _state.copyWith(
      phase: GamePhase.idle,
      balls: _freshBalls(0.5, count: retryBallCount),
      ballsToFire: 0,
      activeBallCount: 0,
      clearNextLauncherX: true,
      launcher: Launcher(x: 0.5, y: GameTuning.launcherY, aimAngle: -90),
      bricks: prefill.bricks,
      turnIndex: 1,
      score: 0,
      ballCount: retryBallCount,
      isInputLocked: false,
      lastUpdateMicros: 0,
      fireTimer: 0,
      shouldShowGameOverDialog: false,
      levelProgress: prefill.progress,
      damageMultiplier: _progressionService.damageMultiplier(prefill.progress),
      wavePatternLast: prefill.wavePattern,
      pendingLevelUpDialog: false,
      coinsEarnedThisLevel: 0,
      coinsPaidBucketsInRun: 0,
      projectileStyle: _state.projectileStyle,
      highestLevelReached: max(_state.highestLevelReached, retryLevel),
      launchSpeedMultiplier: 1.0,
      levelEntryBallCount: retryBallCount,
      ballCapForLevel: retryBallCap,
      overflowBallsLastClear: 0,
      coinsFromOverflowLastClear: 0,
      isRecalling: false,
      recallButtonVisible: false,
    );

    _logGameStart();
    _logLevelStart();
    _clearRunSnapshot();
    notifyListeners();
  }

  void consumeGameOverDialog() {
    if (!_state.shouldShowGameOverDialog) {
      return;
    }
    _state = _state.copyWith(shouldShowGameOverDialog: false);
    notifyListeners();
  }

  void consumeLevelClearDialog() {
    if (!_state.pendingLevelUpDialog) {
      return;
    }
    _state = _state.copyWith(pendingLevelUpDialog: false);
    notifyListeners();
  }

  void confirmLevelClearUnlock() {
    if (!_state.pendingLevelUpDialog) {
      return;
    }

    final unlockedNext = _state.levelProgress.levelIndex + 1;
    final updatedHighest = max(_state.highestLevelReached, unlockedNext);
    if (updatedHighest == _state.highestLevelReached) {
      return;
    }

    _state = _state.copyWith(highestLevelReached: updatedHighest);
    _persistHighestLevel(updatedHighest);
    notifyListeners();
  }

  void advanceToNextLevel() {
    final carryBallCount = _applyLevelClearBallCapTrim();
    final nextLevelIndex = _state.levelProgress.levelIndex + 1;
    final nextBallCap = GameTuning.maxBallsForLevel(nextLevelIndex);
    final nextProgressSeed = _planBuilder
        .buildForLevel(nextLevelIndex)
        .copyWith(
          checkpointBallCount: carryBallCount,
          ballCapAtLevelStart: nextBallCap,
          overflowBallsOnClear: 0,
        );
    final prefill = _prefillLevel(nextProgressSeed);

    _state = _state.copyWith(
      pendingLevelUpDialog: false,
      levelProgress: prefill.progress,
      damageMultiplier: _progressionService.damageMultiplier(prefill.progress),
      wavePatternLast: prefill.wavePattern,
      bricks: prefill.bricks,
      balls: _freshBalls(_state.launcher.x, count: carryBallCount),
      phase: GamePhase.idle,
      isInputLocked: false,
      ballsToFire: 0,
      activeBallCount: 0,
      clearNextLauncherX: true,
      fireTimer: 0,
      coinsEarnedThisLevel: 0,
      projectileStyle: _state.projectileStyle,
      highestLevelReached: max(_state.highestLevelReached, nextLevelIndex),
      launchSpeedMultiplier: 1.0,
      ballCount: carryBallCount,
      levelEntryBallCount: carryBallCount,
      ballCapForLevel: nextBallCap,
      isRecalling: false,
      recallButtonVisible: false,
    );

    _persistHighestLevel(_state.highestLevelReached);
    _clearRunSnapshot();
    _logLevelStart();
    notifyListeners();
  }

  void saveRunSnapshot({int? levelOverride}) {
    final level = max(1, levelOverride ?? _state.levelProgress.levelIndex);
    final levelBallCap = GameTuning.maxBallsForLevel(level);
    final balls = max(
      GameTuning.initialBallCount,
      min(_state.ballCount, levelBallCap),
    );
    _persistRunSnapshot(
      levelIndex: level,
      ballCount: balls,
      score: _state.score,
      coinsPaidBucketsInRun: _state.coinsPaidBucketsInRun,
    );
  }

  int applyLevelClearCarryover() {
    return _applyLevelClearBallCapTrim();
  }

  void clearRunSnapshot() {
    _clearRunSnapshot();
  }

  GameState _updateBestScore(GameState updated) {
    if (updated.score <= updated.bestScore) {
      return updated;
    }

    final withBest = updated.copyWith(
      bestScore: max(updated.score, updated.bestScore),
    );
    _persistBestScore(withBest.bestScore);
    _logBestScoreUpdated(withBest.bestScore);
    return withBest;
  }

  void _updateState(GameState updated) {
    if (identical(updated, _state)) {
      return;
    }
    _state = _updateBestScore(updated);
    notifyListeners();
  }

  void setProjectileStyle(ProjectileStyle style) {
    if (_state.projectileStyle == style) {
      return;
    }
    _state = _state.copyWith(projectileStyle: style);
    _persistProjectileStyle(style);
    notifyListeners();
  }

  int _awardCoinsOnLevelClear() {
    final scoreBuckets = _state.score ~/ 100;
    final newBuckets = scoreBuckets - _state.coinsPaidBucketsInRun;
    final coinsAwarded = max(0, newBuckets);

    if (coinsAwarded <= 0) {
      _state = _state.copyWith(coinsEarnedThisLevel: 0);
      return 0;
    }

    final totalCoins = _state.totalCoins + coinsAwarded;
    _state = _state.copyWith(
      totalCoins: totalCoins,
      coinsEarnedThisLevel: coinsAwarded,
      coinsPaidBucketsInRun: _state.coinsPaidBucketsInRun + coinsAwarded,
    );
    _persistTotalCoins(totalCoins);
    return coinsAwarded;
  }

  int _applyLevelClearBallCapTrim() {
    final level = _state.levelProgress.levelIndex;
    final cap = GameTuning.maxBallsForLevel(level);
    final overflow = max(0, _state.ballCount - cap);
    final carry = _state.ballCount - overflow;

    _state = _state.copyWith(
      ballCount: carry,
      balls: _freshBalls(_state.launcher.x, count: carry),
      overflowBallsLastClear: overflow,
      coinsFromOverflowLastClear: 0,
      levelProgress: _state.levelProgress.copyWith(
        overflowBallsOnClear: overflow,
      ),
    );
    return carry;
  }

  List<Ball> _freshBalls(double launcherX, {int? count}) {
    final ballCount = count ?? GameTuning.initialBallCount;
    return List<Ball>.generate(
      ballCount,
      (index) => Ball(
        id: index,
        position: Offset(launcherX, GameTuning.launcherY),
        previousPosition: Offset(launcherX, GameTuning.launcherY),
        velocity: Offset.zero,
        radius: GameTuning.ballRadius,
        active: false,
        grounded: false,
        merged: false,
        flightTimeSeconds: 0,
      ),
    );
  }

  _PrefillResult _prefillLevel(LevelProgress seedProgress) {
    final bricks = <Brick>[];
    var progress = seedProgress;
    var wavePattern = WavePattern.random;
    var nextId = 1;

    final prefillRows = min(GameTuning.initialPrefillRows, progress.wavesTotal);

    for (var rowIndex = 0; rowIndex < prefillRows; rowIndex++) {
      if (!_progressionService.shouldSpawnWave(progress)) {
        break;
      }

      final isBossWave = _progressionService.isBossWave(progress);
      final pattern = _progressionService.determineNextPattern(progress);
      final rowBricks = _rowGenerator
          .generateWaveRow(
            progress: progress,
            pattern: pattern,
            isBossWave: isBossWave,
            columns: GameTuning.columns,
            startId: nextId,
            minBrickCount: 3,
          )
          .map((brick) => brick.copyWith(row: rowIndex))
          .toList();

      if (rowBricks.isNotEmpty) {
        final maxId = rowBricks.fold<int>(
          nextId,
          (acc, brick) => brick.id > acc ? brick.id : acc,
        );
        nextId = maxId + 1;
      }

      bricks.addAll(rowBricks);
      progress = _progressionService.onWaveSpawned(
        progress,
        bossWave: isBossWave,
      );
      wavePattern = pattern;
    }

    return _PrefillResult(
      bricks: bricks,
      progress: progress,
      wavePattern: wavePattern,
    );
  }

  GameState _buildInitialState() {
    final launcher = Launcher(x: 0.5, y: GameTuning.launcherY, aimAngle: -90);
    final level = 1;
    final ballCap = GameTuning.maxBallsForLevel(level);
    final progressSeed = _planBuilder
        .buildForLevel(level)
        .copyWith(
          checkpointBallCount: GameTuning.initialBallCount,
          ballCapAtLevelStart: ballCap,
          overflowBallsOnClear: 0,
        );
    final prefill = _prefillLevel(progressSeed);

    return GameState(
      phase: GamePhase.idle,
      balls: _freshBalls(launcher.x),
      ballsToFire: 0,
      activeBallCount: 0,
      nextLauncherX: null,
      launcher: launcher,
      bricks: prefill.bricks,
      turnIndex: 1,
      score: 0,
      ballCount: GameTuning.initialBallCount,
      isInputLocked: false,
      lastUpdateMicros: 0,
      bestScore: 0,
      fireTimer: 0,
      shouldShowGameOverDialog: false,
      levelProgress: prefill.progress,
      damageMultiplier: _progressionService.damageMultiplier(prefill.progress),
      wavePatternLast: prefill.wavePattern,
      pendingLevelUpDialog: false,
      totalCoins: 0,
      coinsEarnedThisLevel: 0,
      coinsPaidBucketsInRun: 0,
      highestLevelReached: 1,
      launchSpeedMultiplier: 1.0,
      levelEntryBallCount: GameTuning.initialBallCount,
      ballCapForLevel: ballCap,
      overflowBallsLastClear: 0,
      coinsFromOverflowLastClear: 0,
      isRecalling: false,
      recallButtonVisible: false,
    );
  }
}

class _PrefillResult {
  const _PrefillResult({
    required this.bricks,
    required this.progress,
    required this.wavePattern,
  });

  final List<Brick> bricks;
  final LevelProgress progress;
  final WavePattern wavePattern;
}
