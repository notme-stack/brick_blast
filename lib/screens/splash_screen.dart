import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../app_shell/app_router.dart';
import '../capabilities/storage/local_storage_service.dart';
import '../modules/brick_blast/module_entry.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _splashDuration = Duration(milliseconds: 2500);

  late final AnimationController _loadingController;
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _timer = Timer(_splashDuration, _navigateNext);
  }

  void _navigateNext() {
    if (_navigated || !mounted) {
      return;
    }
    _navigated = true;
    final storage = LocalStorageService();
    final hasCompletedLogin =
        storage.read<bool>(LocalStorageService.hasCompletedLoginKey) ?? false;
    final route = hasCompletedLogin
        ? BrickBlastModuleEntry.homeRoute
        : AppRouter.login;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF081534), Color(0xFF050D24)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final compact = width < 390;
              final contentWidth = width.clamp(260.0, 460.0).toDouble();
              final logoSize = compact
                  ? contentWidth * 0.35
                  : contentWidth * 0.32;
              final brickSize = compact ? 72.0 : 86.0;
              final blastSize = compact ? 72.0 : 86.0;
              final shooterSize = compact ? 26.0 : 30.0;
              final barWidth = contentWidth * 0.76;

              return Stack(
                children: [
                  const _SplashBackgroundShapes(),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LogoOrb(size: logoSize),
                          const SizedBox(height: 30),
                          Text(
                            'BRICK',
                            style: TextStyle(
                              fontSize: brickSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: const Color(0xFFDCE7FF),
                              height: 0.95,
                            ),
                          ),
                          Text(
                            'BLAST',
                            style: TextStyle(
                              fontSize: blastSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: const Color(0xFF6972FF),
                              height: 0.95,
                              shadows: const [
                                Shadow(
                                  color: Color(0xAA4B56FF),
                                  blurRadius: 26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'SHOOTER',
                            style: TextStyle(
                              fontSize: shooterSize,
                              fontWeight: FontWeight.w700,
                              letterSpacing: compact ? 8 : 10,
                              color: const Color(0xFF8EA1C2),
                            ),
                          ),
                          const SizedBox(height: 72),
                          _LoadingRail(
                            controller: _loadingController,
                            width: barWidth,
                          ),
                          const SizedBox(height: 18),
                          AnimatedBuilder(
                            animation: _loadingController,
                            builder: (context, child) {
                              final tick = (_loadingController.value * 3)
                                  .floor();
                              final dots = '.' * (tick + 1);
                              return Text(
                                'LOADING$dots',
                                style: TextStyle(
                                  fontSize: compact ? 22 : 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: const Color(0xFF596D94),
                                ),
                              );
                            },
                          ),
                        ],
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

class _LoadingRail extends StatelessWidget {
  const _LoadingRail({required this.controller, required this.width});

  final AnimationController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            width: width,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0x1F7D90BA),
              border: Border.all(color: const Color(0x338AA4DB)),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Align(
                alignment: Alignment(-1 + (2 * controller.value), 0),
                child: Container(
                  width: width * 0.55,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7F6BFF), Color(0xFFFF4FB0)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66346EFF),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LogoOrb extends StatelessWidget {
  const _LogoOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5D72FF), Color(0xFFE34E9E)],
        ),
      ),
      padding: EdgeInsets.all(size * 0.14),
      child: ClipOval(
        child: Image.asset(
          'assets/images/splash_logo.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _SplashBackgroundShapes extends StatelessWidget {
  const _SplashBackgroundShapes();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 90,
          left: 42,
          child: _BlurredShape(size: 150, borderRadius: 34),
        ),
        Positioned(
          top: 360,
          right: 58,
          child: _PlainShape(size: 86, borderRadius: 20),
        ),
        Positioned(bottom: 124, right: 12, child: _BlurredCircle(size: 220)),
        Positioned(
          bottom: 284,
          left: 32,
          child: _PlainShape(size: 58, borderRadius: 32, circle: true),
        ),
      ],
    );
  }
}

class _BlurredShape extends StatelessWidget {
  const _BlurredShape({required this.size, required this.borderRadius});

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 1.6, sigmaY: 1.6),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0x33B6CBF5), width: 2),
          color: const Color(0x081D3A62),
        ),
      ),
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  const _BlurredCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x24B8C8EA), width: 2),
          color: const Color(0x081B2E56),
        ),
      ),
    );
  }
}

class _PlainShape extends StatelessWidget {
  const _PlainShape({
    required this.size,
    required this.borderRadius,
    this.circle = false,
  });

  final double size;
  final double borderRadius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(borderRadius),
        color: const Color(0x1A2D3653),
      ),
    );
  }
}
