import 'dart:math';

import 'package:flutter/material.dart';

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
  static const String bestScoreKey = 'brick_blast_best_score';
  static const String highestLevelKey = 'brick_blast_highest_level';
  static const String totalCoinsKey = 'brick_blast_total_coins';
  static const String projectileStyleKey = 'brick_blast_projectile_style';

  GameState get state => _state;

  Future<void> _loadPersistedProgress() async {
    final best = _storageService.read<int>(bestScoreKey) ?? 0;
    final highest = _storageService.read<int>(highestLevelKey) ?? 1;
    final totalCoins = _storageService.read<int>(totalCoinsKey) ?? 0;
    final styleName = _storageService.read<String>(projectileStyleKey);
    final projectileStyle = ProjectileStyle.values.firstWhere(
      (style) => style.name == styleName,
      orElse: () => ProjectileStyle.dotted,
    );
    final levelIndex = max(1, max(highest, _state.levelProgress.levelIndex));
    final progressSeed = _planBuilder.buildForLevel(levelIndex);
    final prefill = _prefillLevel(progressSeed);

    _state = _state.copyWith(
      bestScore: best,
      levelProgress: prefill.progress,
      bricks: prefill.bricks,
      wavePatternLast: prefill.wavePattern,
      damageMultiplier: _progressionService.damageMultiplier(prefill.progress),
      highestLevelReached: highest,
      totalCoins: totalCoins,
      projectileStyle: projectileStyle,
      coinsEarnedThisLevel: 0,
      coinsPaidBucketsInRun: 0,
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

  void tick(double deltaSeconds) {
    _accumulator += deltaSeconds;
    var stateChanged = false;
    var previousTurn = _state.turnIndex;
    var previouslyGameOver = _state.phase == GamePhase.gameOver;
    var previousWaves = _state.levelProgress.wavesSpawned;
    var previousCleanup = _state.levelProgress.inCleanupPhase;
    var previousLevel = _state.levelProgress.levelIndex;
    var previousPendingLevelUp = _state.pendingLevelUpDialog;

    while (_accumulator >= _fixedStep) {
      _accumulator -= _fixedStep;
      final updated = _engine.tick(_state, _fixedStep);
      if (!identical(updated, _state)) {
        _state = _updateBestScore(updated);
        stateChanged = true;
      }
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
    _accumulator = 0;
    _state = _buildInitialState().copyWith(
      bestScore: _state.bestScore,
      totalCoins: _state.totalCoins,
      projectileStyle: _state.projectileStyle,
      highestLevelReached: _state.highestLevelReached,
      coinsPaidBucketsInRun: 0,
      coinsEarnedThisLevel: 0,
    );
    _logGameStart();
    _logLevelStart();
    notifyListeners();
  }

  void consumeGameOverDialog() {
    if (!_state.shouldShowGameOverDialog) {
      return;
    }
    _state = _state.copyWith(shouldShowGameOverDialog: false);
    notifyListeners();
  }

  void advanceToNextLevel() {
    if (!_state.pendingLevelUpDialog) {
      return;
    }

    final nextLevelIndex = _state.levelProgress.levelIndex + 1;
    final nextProgressSeed = _planBuilder.buildForLevel(nextLevelIndex);
    final prefill = _prefillLevel(nextProgressSeed);

    _state = _state.copyWith(
      pendingLevelUpDialog: false,
      levelProgress: prefill.progress,
      damageMultiplier: _progressionService.damageMultiplier(prefill.progress),
      wavePatternLast: prefill.wavePattern,
      bricks: prefill.bricks,
      balls: _freshBalls(_state.launcher.x, count: _state.ballCount),
      phase: GamePhase.idle,
      isInputLocked: false,
      ballsToFire: 0,
      activeBallCount: 0,
      clearNextLauncherX: true,
      fireTimer: 0,
      coinsEarnedThisLevel: 0,
      projectileStyle: _state.projectileStyle,
      highestLevelReached: max(_state.highestLevelReached, nextLevelIndex),
    );

    _persistHighestLevel(_state.highestLevelReached);
    _logLevelStart();
    notifyListeners();
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
    final progressSeed = _planBuilder.buildForLevel(1);
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
