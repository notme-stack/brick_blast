import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../capabilities/storage/local_storage_service.dart';
import '../modules/brick_blast/module_entry.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _continueAsGuest(BuildContext context) async {
    await LocalStorageService().write(
      LocalStorageService.hasCompletedLoginKey,
      true,
    );
    if (!context.mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, BrickBlastModuleEntry.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF081533), Color(0xFF03081B)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final sizeClass = _LoginSizeClass.fromHeight(height);
              final layoutScale = math
                  .min(height / 915, width / 440)
                  .clamp(0.75, 1.0);
              final contentWidth = math.min(width * 0.9, 520.0);

              final logoSize = sizeClass.logoSize * layoutScale;
              final titleSize = sizeClass.titleSize * layoutScale;
              final shooterSize = sizeClass.shooterSize * layoutScale;
              final buttonHeight = sizeClass.buttonHeight * layoutScale;
              final footerSize = sizeClass.footerSize * layoutScale;

              return Stack(
                children: [
                  _LoginAmbientBackground(scale: layoutScale),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18 * layoutScale,
                          vertical: 12 * layoutScale,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: sizeClass.topSpacing * layoutScale,
                            ),
                            _LoginBrandMark(size: logoSize),
                            SizedBox(
                              height: sizeClass.logoToTitleGap * layoutScale,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'BRICK',
                                style: TextStyle(
                                  color: const Color(0xFFE3EBFA),
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                  height: 0.9,
                                  letterSpacing: 0.8,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x353A4FAF),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'BLAST',
                                style: TextStyle(
                                  color: const Color(0xFF7079FF),
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                  height: 0.9,
                                  letterSpacing: 0.8,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xAA566CFF),
                                      blurRadius: 24,
                                    ),
                                    Shadow(
                                      color: Color(0x664B56EB),
                                      blurRadius: 42,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: sizeClass.titleToShooterGap * layoutScale,
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    thickness: 1.1,
                                    color: Color(0x335D72A2),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16 * layoutScale,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30 * layoutScale,
                                    vertical: 10 * layoutScale,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF040B24),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0x334D6BB8),
                                    ),
                                  ),
                                  child: Text(
                                    'SHOOTER',
                                    style: TextStyle(
                                      color: const Color(0xFF8FA5D2),
                                      fontSize: shooterSize,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 8.2 * layoutScale,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    thickness: 1.1,
                                    color: Color(0x335D72A2),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            _GuestActionButton(
                              height: buttonHeight,
                              compact: sizeClass == _LoginSizeClass.compact,
                              onTap: () => _continueAsGuest(context),
                            ),
                            SizedBox(height: 20 * layoutScale),
                            Text(
                              'v3.0.1 • No account required',
                              style: TextStyle(
                                color: const Color(0xFF3E4A68),
                                fontSize: footerSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: sizeClass.bottomSpacing * layoutScale,
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

enum _LoginSizeClass {
  compact,
  regular,
  tall;

  static _LoginSizeClass fromHeight(double height) {
    if (height < 760) {
      return _LoginSizeClass.compact;
    }
    if (height > 920) {
      return _LoginSizeClass.tall;
    }
    return _LoginSizeClass.regular;
  }

  double get logoSize => switch (this) {
    _LoginSizeClass.compact => 116,
    _LoginSizeClass.regular => 132,
    _LoginSizeClass.tall => 148,
  };

  double get titleSize => switch (this) {
    _LoginSizeClass.compact => 100,
    _LoginSizeClass.regular => 112,
    _LoginSizeClass.tall => 122,
  };

  double get shooterSize => switch (this) {
    _LoginSizeClass.compact => 36,
    _LoginSizeClass.regular => 39,
    _LoginSizeClass.tall => 42,
  };

  double get buttonHeight => switch (this) {
    _LoginSizeClass.compact => 94,
    _LoginSizeClass.regular => 102,
    _LoginSizeClass.tall => 110,
  };

  double get footerSize => switch (this) {
    _LoginSizeClass.compact => 17,
    _LoginSizeClass.regular => 18,
    _LoginSizeClass.tall => 19,
  };

  double get topSpacing => switch (this) {
    _LoginSizeClass.compact => 12,
    _LoginSizeClass.regular => 16,
    _LoginSizeClass.tall => 22,
  };

  double get logoToTitleGap => switch (this) {
    _LoginSizeClass.compact => 56,
    _LoginSizeClass.regular => 68,
    _LoginSizeClass.tall => 78,
  };

  double get titleToShooterGap => switch (this) {
    _LoginSizeClass.compact => 16,
    _LoginSizeClass.regular => 18,
    _LoginSizeClass.tall => 20,
  };

  double get bottomSpacing => switch (this) {
    _LoginSizeClass.compact => 8,
    _LoginSizeClass.regular => 14,
    _LoginSizeClass.tall => 20,
  };
}

class _GuestActionButton extends StatelessWidget {
  const _GuestActionButton({
    required this.height,
    required this.compact,
    required this.onTap,
  });

  final double height;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? height * 0.29 : height * 0.31;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(34),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2A3567), Color(0xFF222C57)],
              ),
              border: Border.all(color: const Color(0x664665B8), width: 1.3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x443C53A9),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * (height / 100)),
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'CONTINUE AS GUEST',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: const Color(0xFFE8EDF8),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: height * 0.44,
                    height: height * 0.44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x2EAFBDD8),
                      border: Border.all(color: const Color(0x446D84BB)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: height * 0.26,
                      color: const Color(0xFFDDE6F7),
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

class _LoginBrandMark extends StatelessWidget {
  const _LoginBrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final tileSize = size * 0.43;
    final gap = size * 0.03;

    return SizedBox(
      key: const Key('login-brand-mark'),
      width: size * 1.9,
      height: size * 1.9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.8,
            height: size * 1.8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x88746BFF), Color(0x003A3D7A)],
              ),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: gap,
              runSpacing: gap,
              children: [
                _BrandTile(color: const Color(0xFFE948A3), size: tileSize),
                _BrandTile(color: const Color(0xFF5D68E8), size: tileSize),
                _BrandTile(color: const Color(0xFFFD8A17), size: tileSize),
                _BrandTile(color: const Color(0xFF24B7AA), size: tileSize),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.94), color],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: size * 0.34,
            spreadRadius: 0.8,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.38,
          height: size * 0.38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x28FFFFFF),
          ),
        ),
      ),
    );
  }
}

class _LoginAmbientBackground extends StatelessWidget {
  const _LoginAmbientBackground({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _OutlineArcPainter())),
        Positioned(
          top: 116 * scale,
          left: 42 * scale,
          child: _GlassShape(
            width: 166 * scale,
            height: 166 * scale,
            radius: 34 * scale,
            rotateDeg: -10,
          ),
        ),
        Positioned(
          top: 494 * scale,
          left: 142 * scale,
          child: _SparkDot(color: const Color(0xFFEC4F9C), size: 11 * scale),
        ),
        Positioned(
          top: 278 * scale,
          right: 88 * scale,
          child: _SparkDot(color: const Color(0xFF8EA2F7), size: 10 * scale),
        ),
        Positioned(
          top: 558 * scale,
          left: 60 * scale,
          child: _GlassShape(
            width: 170 * scale,
            height: 170 * scale,
            radius: 90 * scale,
          ),
        ),
        Positioned(
          right: 18 * scale,
          bottom: 108 * scale,
          child: _GlassShape(
            width: 206 * scale,
            height: 206 * scale,
            radius: 44 * scale,
            rotateDeg: -32,
          ),
        ),
      ],
    );
  }
}

class _OutlineArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x1D96AEE8);
    final topRect = Rect.fromCenter(
      center: Offset(size.width / 2, -110),
      width: size.width * 1.45,
      height: size.width * 0.7,
    );
    final bottomRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height + 130),
      width: size.width * 1.35,
      height: size.width * 0.7,
    );
    canvas.drawArc(topRect, math.pi * 0.02, math.pi * 0.96, false, paint);
    canvas.drawArc(bottomRect, -math.pi * 0.98, math.pi * 0.96, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkDot extends StatelessWidget {
  const _SparkDot({required this.color, required this.size});

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
            color: color.withValues(alpha: 0.5),
            blurRadius: size * 1.4,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _GlassShape extends StatelessWidget {
  const _GlassShape({
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
        imageFilter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: const Color(0x10293658),
            border: Border.all(color: const Color(0x2A8FA8D6), width: 2),
          ),
        ),
      ),
    );
  }
}
