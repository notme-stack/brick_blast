import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  const ResultDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPlayAgain,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPlayAgain;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        TextButton(onPressed: onBack, child: const Text('Back')),
        FilledButton(onPressed: onPlayAgain, child: const Text('Play Again')),
      ],
    );
  }
}

class GameOverResultDialog extends StatelessWidget {
  const GameOverResultDialog({
    super.key,
    required this.finalScore,
    required this.onPlayAgain,
    required this.onHome,
  });

  final int finalScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 780 || size.width < 390;
    final dialogWidth = math.min(size.width - 28, 330.0);
    final maxDialogHeight = size.height - 36;

    return Dialog(
      key: const Key('game-over-dialog'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          maxWidth: dialogWidth,
        ),
        child: SizedBox(
          width: dialogWidth,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF131C33), Color(0xFF0A1228)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x5A3044AA),
                  blurRadius: 44,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 12 : 14,
                isCompact ? 12 : 14,
                isCompact ? 12 : 14,
                isCompact ? 12 : 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: const Color(0xFFD9E3FF),
                      fontSize: isCompact ? 28 : 32,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.6,
                      shadows: const [
                        Shadow(color: Color(0x553B82F6), blurRadius: 18),
                      ],
                    ),
                  ),
                  SizedBox(height: isCompact ? 9 : 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A2742), Color(0xFF121E36)],
                      ),
                      border: Border.all(color: const Color(0xFF30405F)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33040A18),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isCompact ? 8 : 10,
                        isCompact ? 8 : 10,
                        isCompact ? 8 : 10,
                        isCompact ? 8 : 10,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color(0xFF2A3554),
                              border: Border.all(
                                color: const Color(0xFF3B4A6B),
                              ),
                            ),
                            child: Text(
                              'RESULT',
                              style: TextStyle(
                                color: const Color(0xFFAAB8DA),
                                fontSize: isCompact ? 11 : 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                          SizedBox(height: isCompact ? 8 : 9),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 14 : 16,
                              vertical: isCompact ? 11 : 13,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF232F48), Color(0xFF1A263E)],
                              ),
                              border: Border.all(
                                color: const Color(0xFF33445F),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'FINAL SCORE',
                                  style: TextStyle(
                                    color: const Color(0xFFAAB8DA),
                                    fontSize: isCompact ? 13 : 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: isCompact ? 5 : 6),
                                Text(
                                  _formatNumber(finalScore),
                                  style: TextStyle(
                                    color: const Color(0xFFF2F6FF),
                                    fontSize: isCompact ? 34 : 38,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isCompact ? 8 : 9),
                          _PrimaryCtaButton(
                            title: 'PLAY AGAIN',
                            icon: Icons.refresh_rounded,
                            onTap: onPlayAgain,
                            compact: isCompact,
                          ),
                          SizedBox(height: isCompact ? 7 : 8),
                          _SecondaryCtaButton(
                            title: 'HOME',
                            icon: Icons.home_rounded,
                            onTap: onHome,
                            compact: isCompact,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelClearResultDialog extends StatelessWidget {
  const LevelClearResultDialog({
    super.key,
    required this.level,
    required this.levelScore,
    required this.coinsEarned,
    required this.totalCoins,
    required this.onNextLevel,
    required this.onHome,
  });

  final int level;
  final int levelScore;
  final int coinsEarned;
  final int totalCoins;
  final VoidCallback onNextLevel;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 780 || size.width < 390;
    final dialogWidth = math.min(size.width - 28, 330.0);
    final maxDialogHeight = size.height - 36;

    return Dialog(
      key: const Key('level-clear-dialog'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight,
          maxWidth: dialogWidth,
        ),
        child: SizedBox(
          width: dialogWidth,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF131C33), Color(0xFF0A1228)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x5A3044AA),
                  blurRadius: 44,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 12 : 14,
                isCompact ? 12 : 14,
                isCompact ? 12 : 14,
                isCompact ? 12 : 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LEVEL CLEARED!',
                    style: TextStyle(
                      color: const Color(0xFFD9E3FF),
                      fontSize: isCompact ? 26 : 30,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.6,
                      shadows: const [
                        Shadow(color: Color(0x553B82F6), blurRadius: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    key: const Key('level-clear-stars'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _GlowStar(size: 32),
                      SizedBox(width: 8),
                      _GlowStar(size: 42),
                      SizedBox(width: 8),
                      _GlowStar(size: 32),
                    ],
                  ),
                  SizedBox(height: isCompact ? 8 : 9),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A2742), Color(0xFF121E36)],
                      ),
                      border: Border.all(color: const Color(0xFF30405F)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33040A18),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isCompact ? 8 : 10,
                        isCompact ? 8 : 10,
                        isCompact ? 8 : 10,
                        isCompact ? 8 : 10,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color(0xFF2A3554),
                              border: Border.all(
                                color: const Color(0xFF3B4A6B),
                              ),
                            ),
                            child: Text(
                              'MISSION COMPLETE',
                              style: TextStyle(
                                color: const Color(0xFFAAB8DA),
                                fontSize: isCompact ? 11 : 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                          SizedBox(height: isCompact ? 8 : 9),
                          Text(
                            'Level $level',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 28 : 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: isCompact ? 8 : 9),
                          _ResultStatRow(
                            icon: const _FlagBadge(),
                            label: 'Score',
                            value: _formatNumber(levelScore),
                            compact: isCompact,
                          ),
                          SizedBox(height: isCompact ? 7 : 8),
                          _ResultStatRow(
                            icon: const _CoinBadge(),
                            label: 'Coins Earned',
                            value: '+${_formatNumber(coinsEarned)}',
                            compact: isCompact,
                            emphasizeValue: true,
                          ),
                          SizedBox(height: isCompact ? 7 : 8),
                          _ResultStatRow(
                            icon: const _CoinBadge(),
                            label: 'Total Coins',
                            value: _formatNumber(totalCoins),
                            compact: isCompact,
                          ),
                          SizedBox(height: isCompact ? 10 : 12),
                          _PrimaryCtaButton(
                            title: 'NEXT LEVEL',
                            icon: Icons.arrow_forward_rounded,
                            onTap: onNextLevel,
                            compact: isCompact,
                          ),
                          SizedBox(height: isCompact ? 8 : 10),
                          _SecondaryCtaButton(
                            title: 'HOME',
                            icon: Icons.home_rounded,
                            onTap: onHome,
                            compact: isCompact,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStatRow extends StatelessWidget {
  const _ResultStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.compact,
    this.emphasizeValue = false,
  });

  final Widget icon;
  final String label;
  final String value;
  final bool compact;
  final bool emphasizeValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232F48), Color(0xFF1A263E)],
        ),
        border: Border.all(color: const Color(0xFF33445F)),
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFFC8D4EE),
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: emphasizeValue
                  ? const Color(0xFFFFC736)
                  : const Color(0xFFF2F6FF),
              fontSize: compact ? 18 : 21,
              fontWeight: FontWeight.w800,
              shadows: emphasizeValue
                  ? const [Shadow(color: Color(0x66FFC736), blurRadius: 10)]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowStar extends StatelessWidget {
  const _GlowStar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      size: size,
      color: const Color(0xFFFFD12E),
      shadows: const [
        Shadow(color: Color(0x77FFD12E), blurRadius: 16),
        Shadow(color: Color(0x44FFC400), blurRadius: 24),
      ],
    );
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF35427A),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.flag, color: Color(0xFFB7C4FF), size: 20),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFCD955), Color(0xFFF1A80A)],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x55FDBA3B), blurRadius: 12, spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        r'$',
        style: TextStyle(
          color: Color(0xFF6A4711),
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.compact,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _CtaButtonShell(
      onTap: onTap,
      compact: compact,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF6768E2), Color(0xFF4D44D1)],
      ),
      borderColor: const Color(0xAA7A82FF),
      glow: const Color(0x554E52E8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: compact ? 22 : 24),
        ],
      ),
    );
  }
}

class _SecondaryCtaButton extends StatelessWidget {
  const _SecondaryCtaButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.compact,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _CtaButtonShell(
      onTap: onTap,
      compact: compact,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF24314E), Color(0xFF1B2740)],
      ),
      borderColor: const Color(0xAA3E506C),
      glow: const Color(0x22040A18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFD4DDF2), size: compact ? 22 : 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFFD4DDF2),
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButtonShell extends StatelessWidget {
  const _CtaButtonShell({
    required this.onTap,
    required this.compact,
    required this.gradient,
    required this.borderColor,
    required this.glow,
    required this.child,
  });

  final VoidCallback onTap;
  final bool compact;
  final Gradient gradient;
  final Color borderColor;
  final Color glow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          height: compact ? 46 : 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: gradient,
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: glow,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

String _formatNumber(int value) {
  final raw = value.toString();
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
