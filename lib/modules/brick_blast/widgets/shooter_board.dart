import 'dart:math';

import 'package:flutter/material.dart';

import '../data/game_tuning.dart';
import '../models/game_phase.dart';
import '../models/game_state.dart';
import '../models/projectile_style.dart';
import '../models/wave_pattern.dart';

class ShooterBoard extends StatelessWidget {
  const ShooterBoard({
    super.key,
    required this.state,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
  });

  final GameState state;
  final ValueChanged<Offset> onPointerDown;
  final ValueChanged<Offset> onPointerMove;
  final VoidCallback onPointerUp;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            onPointerDown(_toNormalized(details.localPosition, size));
          },
          onPanUpdate: (details) {
            onPointerMove(_toNormalized(details.localPosition, size));
          },
          onPanEnd: (_) => onPointerUp(),
          child: CustomPaint(
            painter: _ShooterBoardPainter(state: state),
            size: size,
          ),
        );
      },
    );
  }

  Offset _toNormalized(Offset point, Size size) {
    final safeWidth = size.width <= 0 ? 1 : size.width;
    final safeHeight = size.height <= 0 ? 1 : size.height;
    return Offset(point.dx / safeWidth, point.dy / safeHeight);
  }
}

class TrajectorySegment {
  const TrajectorySegment({required this.start, required this.end});

  final Offset start;
  final Offset end;
}

double computeDangerLineYPx(Size size) {
  return GameTuning.dangerLineYNormalized * size.height;
}

List<TrajectorySegment> computeTwoSegmentTrajectory({
  required Offset start,
  required double aimAngleDegrees,
  Rect bounds = const Rect.fromLTWH(0, 0, 1, 1),
}) {
  final radians = aimAngleDegrees * pi / 180;
  final direction = Offset(cos(radians), sin(radians));
  final firstHit = _raycastToBounds(start, direction, bounds);
  if (firstHit == null) {
    return const [];
  }

  final reflected = _reflect(direction, firstHit.normal);
  final secondOrigin = firstHit.point + (reflected * 0.001);
  final secondHit = _raycastToBounds(secondOrigin, reflected, bounds);
  final secondEnd = secondHit?.point ?? (secondOrigin + reflected);

  return [
    TrajectorySegment(start: start, end: firstHit.point),
    TrajectorySegment(start: firstHit.point, end: secondEnd),
  ];
}

class _RayHit {
  const _RayHit({required this.point, required this.normal, required this.t});

  final Offset point;
  final Offset normal;
  final double t;
}

_RayHit? _raycastToBounds(Offset origin, Offset direction, Rect bounds) {
  if (direction.dx.abs() < 1e-6 && direction.dy.abs() < 1e-6) {
    return null;
  }

  final hits = <_RayHit>[];

  void tryHit(double t, Offset normal) {
    if (t <= 0) {
      return;
    }
    final point = origin + (direction * t);
    final inX =
        point.dx >= bounds.left - 1e-6 && point.dx <= bounds.right + 1e-6;
    final inY =
        point.dy >= bounds.top - 1e-6 && point.dy <= bounds.bottom + 1e-6;
    if (inX && inY) {
      hits.add(_RayHit(point: point, normal: normal, t: t));
    }
  }

  if (direction.dx.abs() > 1e-6) {
    final leftT = (bounds.left - origin.dx) / direction.dx;
    final rightT = (bounds.right - origin.dx) / direction.dx;
    tryHit(leftT, const Offset(1, 0));
    tryHit(rightT, const Offset(-1, 0));
  }

  if (direction.dy.abs() > 1e-6) {
    final topT = (bounds.top - origin.dy) / direction.dy;
    final bottomT = (bounds.bottom - origin.dy) / direction.dy;
    tryHit(topT, const Offset(0, 1));
    tryHit(bottomT, const Offset(0, -1));
  }

  if (hits.isEmpty) {
    return null;
  }

  hits.sort((a, b) => a.t.compareTo(b.t));
  return hits.first;
}

Offset _reflect(Offset direction, Offset normal) {
  final dot = direction.dx * normal.dx + direction.dy * normal.dy;
  return direction - (normal * (2 * dot));
}

class _ShooterBoardPainter extends CustomPainter {
  _ShooterBoardPainter({required this.state});

  final GameState state;

  static const List<Color> _brickColors = [
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFFA3E635),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawBricks(canvas, size);
    _drawTrajectory(canvas, size);
    _drawBalls(canvas, size);
    _drawLauncher(canvas, size);
    _drawDangerLine(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.08)
      ..strokeWidth = 1;
    const step = 36.0;
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawBricks(Canvas canvas, Size size) {
    final isBossWave = state.wavePatternLast == WavePattern.boss;

    for (final brick in state.bricks) {
      final rect = _brickRectPx(size, brick.row, brick.col);
      final radius = const Radius.circular(8);
      final color = isBossWave
          ? const Color(0xFFFBBF24)
          : _brickColors[brick.colorTier % _brickColors.length];
      final fillPaint = Paint()..color = color.withValues(alpha: 0.95);

      if (isBossWave) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFBBF24).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(1.5), radius),
          glowPaint,
        );
      }

      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), fillPaint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isBossWave ? 2.4 : 1.2
        ..color = isBossWave
            ? const Color(0xFFFDE68A)
            : Colors.white.withValues(alpha: 0.25);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), borderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${brick.hp}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawBalls(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final fillPaint = Paint()..color = const Color(0xFF38BDF8);

    for (final ball in state.balls) {
      final center = Offset(
        ball.position.dx * size.width,
        ball.position.dy * size.height,
      );
      final radius = ball.radius * min(size.width, size.height);
      canvas.drawCircle(center, radius + 1.2, glowPaint);
      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  void _drawLauncher(Canvas canvas, Size size) {
    final center = Offset(
      state.launcher.x * size.width,
      state.launcher.y * size.height,
    );

    final shell = Paint()..color = Colors.white;
    canvas.drawCircle(center, 12, shell);

    final inner = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, 9.5, inner);

    final countPainter = TextPainter(
      text: TextSpan(
        text: '${state.ballCount}',
        style: const TextStyle(
          color: Color(0xFF38BDF8),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    countPainter.paint(
      canvas,
      Offset(
        center.dx - countPainter.width / 2,
        center.dy - countPainter.height / 2,
      ),
    );
  }

  void _drawTrajectory(Canvas canvas, Size size) {
    if (state.phase != GamePhase.aiming) {
      return;
    }

    final start = Offset(state.launcher.x, state.launcher.y);
    final segments = computeTwoSegmentTrajectory(
      start: start,
      aimAngleDegrees: state.launcher.aimAngle,
      bounds: const Rect.fromLTWH(0, 0, 1, 1),
    );

    final paint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    for (final segment in segments) {
      final startPx = Offset(
        segment.start.dx * size.width,
        segment.start.dy * size.height,
      );
      final endPx = Offset(
        segment.end.dx * size.width,
        segment.end.dy * size.height,
      );
      if (state.projectileStyle == ProjectileStyle.lightSabre) {
        _drawLightSabreLine(canvas, start: startPx, end: endPx);
      } else {
        _drawDashedLine(canvas, start: startPx, end: endPx, paint: paint);
      }
    }
  }

  void _drawDashedLine(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required Paint paint,
  }) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance <= 0) {
      return;
    }

    final dir = delta / distance;
    const dashLen = 10.0;
    const gapLen = 7.0;
    var drawn = 0.0;
    while (drawn < distance) {
      final dashStart = start + (dir * drawn);
      final dashEnd = start + (dir * min(drawn + dashLen, distance));
      canvas.drawLine(dashStart, dashEnd, paint);
      drawn += dashLen + gapLen;
    }
  }

  void _drawDangerLine(Canvas canvas, Size size) {
    final dangerY = computeDangerLineYPx(size);
    final paint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.35)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, dangerY), Offset(size.width, dangerY), paint);
  }

  void _drawLightSabreLine(
    Canvas canvas, {
    required Offset start,
    required Offset end,
  }) {
    final glow = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.48)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    final core = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, glow);
    canvas.drawLine(start, end, core);
  }

  Rect _brickRectPx(Size size, int row, int col) {
    final width = (1 - GameTuning.horizontalPadding * 2) / GameTuning.columns;
    final left = (GameTuning.horizontalPadding + col * width) * size.width;
    final top =
        (GameTuning.topPadding + row * GameTuning.rowHeight) * size.height;
    return Rect.fromLTWH(
      left,
      top,
      width * size.width,
      GameTuning.rowHeight * size.height,
    );
  }

  @override
  bool shouldRepaint(covariant _ShooterBoardPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
