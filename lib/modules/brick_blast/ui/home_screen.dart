import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../capabilities/storage/local_storage_service.dart';
import '../logic/game_controller.dart';
import '../module_entry.dart';

class BrickBlastHomeScreen extends StatefulWidget {
  const BrickBlastHomeScreen({super.key});

  @override
  State<BrickBlastHomeScreen> createState() => _BrickBlastHomeScreenState();
}

class _BrickBlastHomeScreenState extends State<BrickBlastHomeScreen> {
  final LocalStorageService _storage = LocalStorageService();

  int _totalCoins = 0;
  int _nextLevel = 1;

  int get _levelsCompleted => math.max(0, _nextLevel - 1);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _totalCoins = _storage.read<int>(GameController.totalCoinsKey) ?? 0;
      _nextLevel = _storage.read<int>(GameController.highestLevelKey) ?? 1;
    });
  }

  Future<void> _openGame() async {
    await Navigator.pushNamed(context, BrickBlastModuleEntry.gameRoute);
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF081533), Color(0xFF040A1D)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final sizeClass = _HomeSizeClass.fromHeight(height);
              final contentWidth = math.min(width * 0.92, 520.0);
              final layoutScale = math
                  .min(height / 860, width / 430)
                  .clamp(0.58, 1.0);
              const coreScale = 0.6;
              const statsScale = 0.6;
              const ctaScale = 0.6;
              final titleReadabilityFloor = sizeClass == _HomeSizeClass.compact
                  ? 34.0
                  : 36.0;
              final shooterReadabilityFloor = 12.0;
              final nextLevelReadabilityFloor = 12.0;
              final playReadabilityFloor = 22.0;

              final iconSize =
                  switch (sizeClass) {
                    _HomeSizeClass.compact => 220.0,
                    _HomeSizeClass.regular => 250.0,
                    _HomeSizeClass.tall => 274.0,
                  } *
                  layoutScale *
                  coreScale;
              final titleSize =
                  switch (sizeClass) {
                    _HomeSizeClass.compact => 66.0,
                    _HomeSizeClass.regular => 74.0,
                    _HomeSizeClass.tall => 80.0,
                  } *
                  layoutScale *
                  coreScale;
              final shooterSize =
                  switch (sizeClass) {
                    _HomeSizeClass.compact => 22.0,
                    _HomeSizeClass.regular => 26.0,
                    _HomeSizeClass.tall => 28.0,
                  } *
                  layoutScale *
                  coreScale;
              final playHeight =
                  switch (sizeClass) {
                    _HomeSizeClass.compact => 106.0,
                    _HomeSizeClass.regular => 114.0,
                    _HomeSizeClass.tall => 122.0,
                  } *
                  layoutScale *
                  ctaScale;
              final topInsetShift =
                  switch (sizeClass) {
                    _HomeSizeClass.compact => 14.0,
                    _HomeSizeClass.regular => 18.0,
                    _HomeSizeClass.tall => 24.0,
                  } *
                  layoutScale;
              final ctaTopMargin =
                  switch (sizeClass) {
                    _HomeSizeClass.compact => 10.0,
                    _HomeSizeClass.regular => 14.0,
                    _HomeSizeClass.tall => 18.0,
                  } *
                  layoutScale;
              final centerFlex = switch (sizeClass) {
                _HomeSizeClass.compact => 46,
                _HomeSizeClass.regular => 48,
                _HomeSizeClass.tall => 50,
              };
              final bottomFlex = switch (sizeClass) {
                _HomeSizeClass.compact => 22,
                _HomeSizeClass.regular => 24,
                _HomeSizeClass.tall => 26,
              };

              return Stack(
                children: [
                  const _HomeAmbientBackground(),
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: sizeClass.topPadding + topInsetShift,
                            ),
                            _HomeTopStats(
                              levelsCompleted: _levelsCompleted,
                              totalCoins: _totalCoins,
                              compact: sizeClass == _HomeSizeClass.compact,
                              scale: layoutScale * statsScale,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: centerFlex,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _HomeDiamondMark(size: iconSize),
                                          SizedBox(
                                            height:
                                                sizeClass.iconToTitleGap *
                                                layoutScale *
                                                coreScale,
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'BRICK BLAST',
                                              style: TextStyle(
                                                fontSize: titleSize.clamp(
                                                  titleReadabilityFloor,
                                                  double.infinity,
                                                ),
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.8,
                                                color: const Color(0xFFDDE6FB),
                                                shadows: const [
                                                  Shadow(
                                                    color: Color(0x553F5BDD),
                                                    blurRadius: 22,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                sizeClass.titleToShooterGap *
                                                layoutScale *
                                                coreScale,
                                          ),
                                          Text(
                                            'SHOOTER',
                                            style: TextStyle(
                                              fontSize: shooterSize.clamp(
                                                shooterReadabilityFloor,
                                                double.infinity,
                                              ),
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 9,
                                              color: const Color(0xFF8FA0C7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: bottomFlex,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: ctaTopMargin,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'NEXT LEVEL $_nextLevel',
                                              style: TextStyle(
                                                fontSize:
                                                    (sizeClass.nextLevelFontSize *
                                                            layoutScale *
                                                            ctaScale)
                                                        .clamp(
                                                          nextLevelReadabilityFloor,
                                                          double.infinity,
                                                        ),
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.9,
                                                color: const Color(0xFF8FA0C7),
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  sizeClass.nextLevelToPlayGap *
                                                  layoutScale *
                                                  ctaScale,
                                            ),
                                            _PlayButton(
                                              height: playHeight,
                                              minTextSize: playReadabilityFloor,
                                              onTap: _openGame,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:
                                  sizeClass.bottomPadding *
                                  layoutScale *
                                  ctaScale,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _HomeSizeClass {
  compact,
  regular,
  tall;

  static _HomeSizeClass fromHeight(double height) {
    if (height < 760) {
      return _HomeSizeClass.compact;
    }
    if (height > 920) {
      return _HomeSizeClass.tall;
    }
    return _HomeSizeClass.regular;
  }

  double get topPadding => switch (this) {
    _HomeSizeClass.compact => 8,
    _HomeSizeClass.regular => 10,
    _HomeSizeClass.tall => 12,
  };

  double get iconToTitleGap => switch (this) {
    _HomeSizeClass.compact => 34,
    _HomeSizeClass.regular => 44,
    _HomeSizeClass.tall => 50,
  };

  double get titleToShooterGap => switch (this) {
    _HomeSizeClass.compact => 6,
    _HomeSizeClass.regular => 8,
    _HomeSizeClass.tall => 10,
  };

  double get nextLevelFontSize => switch (this) {
    _HomeSizeClass.compact => 20,
    _HomeSizeClass.regular => 22,
    _HomeSizeClass.tall => 24,
  };

  double get nextLevelToPlayGap => switch (this) {
    _HomeSizeClass.compact => 12,
    _HomeSizeClass.regular => 14,
    _HomeSizeClass.tall => 16,
  };

  double get bottomPadding => switch (this) {
    _HomeSizeClass.compact => 6,
    _HomeSizeClass.regular => 8,
    _HomeSizeClass.tall => 10,
  };
}

class _HomeTopStats extends StatelessWidget {
  const _HomeTopStats({
    required this.levelsCompleted,
    required this.totalCoins,
    required this.compact,
    required this.scale,
  });

  final int levelsCompleted;
  final int totalCoins;
  final bool compact;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final valueSize = (compact ? 36.0 : 44.0) * scale;
    final iconSize = (compact ? 38.0 : 44.0) * scale;
    final coinSize = (compact ? 44.0 : 50.0) * scale;
    final groupGap = (compact ? 10.0 : 12.0) * scale;
    final rowPadding = (compact ? 6.0 : 10.0) * scale;

    return Row(
      key: const Key('home-top-stats-row'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: rowPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFA7B9FF),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33A7B9FF),
                      blurRadius: 12,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.star_rounded,
                  size: (compact ? 24 : 28) * scale,
                  color: const Color(0xFF1A2241),
                ),
              ),
              SizedBox(width: groupGap),
              Text(
                '$levelsCompleted',
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF1F6FF),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(right: rowPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CoinBadge(compact: compact, scale: scale, size: coinSize),
              SizedBox(width: groupGap),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatNumber(totalCoins),
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF1F6FF),
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({
    required this.compact,
    required this.scale,
    required this.size,
  });

  final bool compact;
  final double scale;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFDD73E), Color(0xFFF8A700)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x44FFC83A),
            blurRadius: 12,
            spreadRadius: 0.5,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        r'$',
        style: TextStyle(
          fontSize: (compact ? 22 : 24) * scale,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF5A3D0E),
        ),
      ),
    );
  }
}

class _HomeDiamondMark extends StatelessWidget {
  const _HomeDiamondMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final tileSize = size * 0.33;
    final center = size / 2;
    final offset = size * 0.23;

    return SizedBox(
      key: const Key('home-diamond-mark'),
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x5A656EFF), Color(0x003747A8)],
                ),
              ),
            ),
          ),
          _DiamondTile(
            center: Offset(center, center - offset),
            size: tileSize,
            color: const Color(0xFFE948A3),
          ),
          _DiamondTile(
            center: Offset(center - offset, center),
            size: tileSize,
            color: const Color(0xFFFD8A17),
          ),
          _DiamondTile(
            center: Offset(center + offset, center),
            size: tileSize,
            color: const Color(0xFF5D68E8),
          ),
          _DiamondTile(
            center: Offset(center, center + offset),
            size: tileSize,
            color: const Color(0xFF24B7AA),
          ),
        ],
      ),
    );
  }
}

class _DiamondTile extends StatelessWidget {
  const _DiamondTile({
    required this.center,
    required this.size,
    required this.color,
  });

  final Offset center;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - (size / 2),
      top: center.dy - (size / 2),
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.94), color],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.26),
                blurRadius: size * 0.3,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: Center(
              child: Container(
                width: size * 0.36,
                height: size * 0.36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x33FFFFFF),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.height,
    required this.minTextSize,
    required this.onTap,
  });

  final double height;
  final double minTextSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF666BD8), Color(0xFF4044B5)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x664D5BE0),
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: height * 0.42,
                  ),
                  SizedBox(width: height * 0.08),
                  Text(
                    'PLAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (height * 0.42).clamp(
                        minTextSize,
                        double.infinity,
                      ),
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
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

class _HomeAmbientBackground extends StatelessWidget {
  const _HomeAmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _ArcOutlinePainter())),
        const Positioned(
          top: 160,
          left: 42,
          child: _BlurGlass(
            width: 148,
            height: 148,
            radius: 34,
            rotateDeg: -10,
          ),
        ),
        const Positioned(
          top: 490,
          left: 42,
          child: _Spark(color: Color(0xFFD6499D), size: 10),
        ),
        const Positioned(
          top: 670,
          right: 56,
          child: _BlurGlass(width: 150, height: 150, radius: 100),
        ),
      ],
    );
  }
}

class _ArcOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x1894ABE6);
    final topRect = Rect.fromCenter(
      center: Offset(size.width / 2, -84),
      width: size.width * 1.45,
      height: size.width * 0.72,
    );
    final bottomRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height + 88),
      width: size.width * 1.45,
      height: size.width * 0.72,
    );
    canvas.drawArc(topRect, math.pi * 0.03, math.pi * 0.94, false, paint);
    canvas.drawArc(bottomRect, -math.pi * 0.97, math.pi * 0.94, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlurGlass extends StatelessWidget {
  const _BlurGlass({
    required this.width,
    required this.height,
    required this.radius,
    this.rotateDeg = 0,
  });

  final double width;
  final double height;
  final double radius;
  final double rotateDeg;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotateDeg * (math.pi / 180),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 1.3, sigmaY: 1.3),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: const Color(0x102A355A),
            border: Border.all(color: const Color(0x2C90A8D5), width: 2),
          ),
        ),
      ),
    );
  }
}

class _Spark extends StatelessWidget {
  const _Spark({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: size * 1.5,
            spreadRadius: 2,
          ),
        ],
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
    buffer.write(raw[i]);
    final remaining = raw.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}
