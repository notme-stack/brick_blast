import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../capabilities/analytics/noop_analytics_service.dart';
import '../../../capabilities/storage/local_storage_service.dart';
import '../data/game_tuning.dart';
import '../logic/game_controller.dart';
import '../models/game_phase.dart';
import '../models/projectile_style.dart';
import '../models/wave_pattern.dart';
import '../module_entry.dart';
import '../widgets/shooter_board.dart';
import 'result_dialog.dart';

class BrickBlastGameScreen extends StatefulWidget {
  const BrickBlastGameScreen({super.key});

  @override
  State<BrickBlastGameScreen> createState() => _BrickBlastGameScreenState();
}

enum _PauseAction { close, restart, home }

class _BrickBlastGameScreenState extends State<BrickBlastGameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final GameController _controller;
  Duration _lastElapsed = Duration.zero;
  bool _showFinalWaveBanner = false;
  bool _finalWaveShownForLevel = false;
  bool _isPausedOverlayOpen = false;
  int _bannerLevel = 1;
  int _currentLevelStartScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      storageService: LocalStorageService(),
      analyticsService: NoopAnalyticsService(),
    )..addListener(_onControllerChanged);

    _bannerLevel = _controller.state.levelProgress.levelIndex;
    _currentLevelStartScore = 0;

    _ticker = createTicker((elapsed) {
      final delta = elapsed - _lastElapsed;
      _lastElapsed = elapsed;
      if (_isPausedOverlayOpen) {
        return;
      }
      _controller.tick(delta.inMicroseconds / Duration.microsecondsPerSecond);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }

    final state = _controller.state;

    if (state.levelProgress.levelIndex != _bannerLevel) {
      _bannerLevel = state.levelProgress.levelIndex;
      _finalWaveShownForLevel = false;
      _showFinalWaveBanner = false;
    }

    if (!_finalWaveShownForLevel &&
        state.levelProgress.inCleanupPhase &&
        state.wavePatternLast == WavePattern.boss) {
      _finalWaveShownForLevel = true;
      _showFinalWaveBanner = true;
      unawaited(
        Future<void>.delayed(
          const Duration(milliseconds: GameTuning.finalWaveBannerDurationMs),
          () {
            if (!mounted) {
              return;
            }
            setState(() {
              _showFinalWaveBanner = false;
            });
          },
        ),
      );
    }

    setState(() {});

    if (state.shouldShowGameOverDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showGameOverDialog();
        _controller.consumeGameOverDialog();
      });
      return;
    }

    if (state.pendingLevelUpDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showLevelCompleteDialog();
      });
    }
  }

  void _showGameOverDialog() {
    final state = _controller.state;
    final finalLevelScore = math.max(0, state.score - _currentLevelStartScore);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return GameOverResultDialog(
          finalScore: finalLevelScore,
          onHome: () {
            Navigator.of(context).pop();
            _goHome();
          },
          onPlayAgain: () {
            Navigator.of(context).pop();
            _controller.retryCurrentLevel();
            _currentLevelStartScore = 0;
          },
        );
      },
    );
  }

  void _showLevelCompleteDialog() {
    final state = _controller.state;
    final levelScore = math.max(0, state.score - _currentLevelStartScore);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return LevelClearResultDialog(
          level: state.levelProgress.levelIndex,
          levelScore: levelScore,
          coinsEarned: state.coinsEarnedThisLevel,
          totalCoins: state.totalCoins,
          onNextLevel: () {
            Navigator.of(context).pop();
            _controller.confirmLevelClearUnlock();
            _controller.advanceToNextLevel();
            _currentLevelStartScore = _controller.state.score;
          },
          onHome: () {
            Navigator.of(context).pop();
            _controller.confirmLevelClearUnlock();
            _goHome();
          },
        );
      },
    );
  }

  Future<void> _openPauseModal() async {
    if (_isPausedOverlayOpen) {
      return;
    }

    setState(() {
      _isPausedOverlayOpen = true;
    });

    _PauseAction action = _PauseAction.close;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xAA030712),
      builder: (context) {
        var selectedStyle = _controller.state.projectileStyle;
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = (screenWidth * 0.7).clamp(260.0, 420.0);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: dialogWidth,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 330;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1D2940), Color(0xFF19243A)],
                        ),
                        border: Border.all(
                          color: const Color(0xFF3A4D6E),
                          width: 1.4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000A1F),
                            blurRadius: 26,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(
                        compact ? 14 : 18,
                        compact ? 12 : 14,
                        compact ? 14 : 18,
                        compact ? 14 : 18,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'Paused',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: compact ? 20 : 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                  color: Colors.white,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.close),
                                  color: const Color(0xFF90A1BE),
                                  onPressed: () {
                                    action = _PauseAction.close;
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: compact ? 62 : 72,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F5BD5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(height: compact ? 12 : 14),
                          _PauseActionButton(
                            title: 'Restart Level',
                            icon: Icons.refresh,
                            color: const Color(0xFF4F46E5),
                            compact: compact,
                            onTap: () {
                              action = _PauseAction.restart;
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(height: compact ? 10 : 12),
                          _PauseActionButton(
                            title: 'Home',
                            icon: Icons.home,
                            color: const Color(0xFF334155),
                            compact: compact,
                            onTap: () {
                              action = _PauseAction.home;
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(height: compact ? 14 : 16),
                          Text(
                            'PROJECTILE STYLE',
                            style: TextStyle(
                              color: const Color(0xFF8EA0BE),
                              fontSize: compact ? 11 : 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ProjectileStyleCard(
                                  selected:
                                      selectedStyle == ProjectileStyle.dotted,
                                  title: 'Dotted Line',
                                  previewType: ProjectileStyle.dotted,
                                  compact: compact,
                                  onTap: () {
                                    _controller.setProjectileStyle(
                                      ProjectileStyle.dotted,
                                    );
                                    setDialogState(() {
                                      selectedStyle = ProjectileStyle.dotted;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ProjectileStyleCard(
                                  selected:
                                      selectedStyle ==
                                      ProjectileStyle.lightSabre,
                                  title: 'Light Sabre',
                                  previewType: ProjectileStyle.lightSabre,
                                  compact: compact,
                                  onTap: () {
                                    _controller.setProjectileStyle(
                                      ProjectileStyle.lightSabre,
                                    );
                                    setDialogState(() {
                                      selectedStyle =
                                          ProjectileStyle.lightSabre;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 12 : 14),
                          TextButton.icon(
                            onPressed: () {
                              action = _PauseAction.close;
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.play_arrow,
                              color: Color(0xFFD5DFEF),
                              size: compact ? 20 : 24,
                            ),
                            label: Text(
                              'Resume Game',
                              style: TextStyle(
                                color: Color(0xFFD5DFEF),
                                fontSize: compact ? 16 : 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isPausedOverlayOpen = false;
    });

    switch (action) {
      case _PauseAction.close:
        return;
      case _PauseAction.restart:
        _controller.restart();
        _currentLevelStartScore = 0;
      case _PauseAction.home:
        _goHome();
    }
  }

  void _goHome() {
    final navigator = Navigator.of(context);
    var reachedHome = false;
    navigator.popUntil((route) {
      final isHome = route.settings.name == BrickBlastModuleEntry.homeRoute;
      if (isHome) {
        reachedHome = true;
      }
      return isHome;
    });
    if (!reachedHome && mounted) {
      navigator.pushReplacementNamed(BrickBlastModuleEntry.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 430;
            final horizontalPadding = isCompact ? 12.0 : 20.0;
            final topPadding = isCompact ? 10.0 : 16.0;
            final hudInnerPadding = isCompact ? 14.0 : 18.0;
            final scoreValueSize = isCompact ? 24.0 : 32.0;
            final metricLabelSize = isCompact ? 14.0 : 16.0;
            final boardMaxWidth = isCompact ? 560.0 : 680.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                12,
              ),
              child: Column(
                children: [
                  _GameHud(
                    score: _formatScore(state.score),
                    wave:
                        '${state.levelProgress.wavesSpawned}/${state.levelProgress.wavesTotal}',
                    level: state.levelProgress.levelIndex,
                    scoreValueSize: scoreValueSize,
                    metricLabelSize: metricLabelSize,
                    innerPadding: hudInnerPadding,
                    onSettingsTap: _openPauseModal,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: boardMaxWidth),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ShooterBoard(
                                state: state,
                                onPointerDown:
                                    state.isInputLocked || _isPausedOverlayOpen
                                    ? (_) {}
                                    : _controller.onPointerDown,
                                onPointerMove:
                                    state.isInputLocked || _isPausedOverlayOpen
                                    ? (_) {}
                                    : _controller.onPointerMove,
                                onPointerUp:
                                    state.phase == GamePhase.aiming &&
                                        !_isPausedOverlayOpen
                                    ? _controller.onPointerUp
                                    : () {},
                              ),
                            ),
                            if (_showFinalWaveBanner)
                              Positioned(
                                top: 14,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFBBF24),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x66FBBF24),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'FINAL WAVE!',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameHud extends StatelessWidget {
  const _GameHud({
    required this.score,
    required this.wave,
    required this.level,
    required this.scoreValueSize,
    required this.metricLabelSize,
    required this.innerPadding,
    required this.onSettingsTap,
  });

  final String score;
  final String wave;
  final int level;
  final double scoreValueSize;
  final double metricLabelSize;
  final double innerPadding;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(innerPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A243A), Color(0xFF111A2E)],
        ),
        border: Border.all(color: const Color(0xFF2F3C5E), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCORE',
                  style: TextStyle(
                    color: const Color(0xFF9DAAC9),
                    fontWeight: FontWeight.w700,
                    fontSize: metricLabelSize,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: scoreValueSize,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water, size: 16, color: Color(0xFF6366F1)),
                    const SizedBox(width: 6),
                    Text(
                      wave,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: scoreValueSize * 0.82,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'LEVEL $level',
                  style: TextStyle(
                    color: const Color(0xFF9DAAC9),
                    fontWeight: FontWeight.w700,
                    fontSize: metricLabelSize,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: onSettingsTap,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E2A46),
                border: Border.all(color: const Color(0xFF3C4A6A)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.settings, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseActionButton extends StatelessWidget {
  const _PauseActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.compact,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          height: compact ? 52 : 58,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: compact ? 24 : 28),
              SizedBox(width: compact ? 8 : 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectileStyleCard extends StatelessWidget {
  const _ProjectileStyleCard({
    required this.selected,
    required this.title,
    required this.previewType,
    required this.compact,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final ProjectileStyle previewType;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          height: compact ? 130 : 146,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2A3560) : const Color(0xFF23324A),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4F5BD5)
                  : const Color(0xFF314763),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              if (selected)
                const BoxShadow(
                  color: Color(0x553B82F6),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
            ],
          ),
          child: Stack(
            children: [
              if (selected)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Color(0xFF4ADE80),
                  ),
                ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (previewType == ProjectileStyle.dotted)
                      Column(
                        children: List.generate(
                          6,
                          (i) => Container(
                            width: compact ? 3 : 4,
                            height: compact ? 6 : 8,
                            margin: EdgeInsets.only(bottom: compact ? 2 : 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDE8FF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: compact ? 4 : 6,
                        height: compact ? 48 : 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xAA22D3EE),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: compact ? 10 : 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF97A7C2),
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatScore(int score) {
  final raw = score.toString();
  if (raw.length <= 3) {
    return raw;
  }
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final indexFromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}
