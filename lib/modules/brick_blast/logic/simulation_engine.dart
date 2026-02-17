import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app_shell/feature_flags.dart';
import '../data/game_tuning.dart';
import '../models/ball.dart';
import '../models/brick.dart';
import '../models/game_phase.dart';
import '../models/game_state.dart';
import 'turn_resolver.dart';

class SimulationEngine {
  SimulationEngine({required TurnResolver turnResolver})
    : _turnResolver = turnResolver;

  final TurnResolver _turnResolver;

  GameState startAiming(GameState state, Offset pointer) {
    if (state.phase != GamePhase.idle) {
      return state;
    }

    final angle = _clampAngle(
      _angleFromPointer(Offset(state.launcher.x, state.launcher.y), pointer),
    );
    return state.copyWith(
      phase: GamePhase.aiming,
      launcher: state.launcher.copyWith(aimAngle: angle),
      isInputLocked: false,
    );
  }

  GameState updateAim(GameState state, Offset pointer) {
    if (state.phase != GamePhase.aiming) {
      return state;
    }

    final angle = _clampAngle(
      _angleFromPointer(Offset(state.launcher.x, state.launcher.y), pointer),
    );
    return state.copyWith(launcher: state.launcher.copyWith(aimAngle: angle));
  }

  GameState releaseFire(GameState state) {
    if (state.phase != GamePhase.aiming) {
      return state;
    }

    return state.copyWith(
      phase: GamePhase.firing,
      ballsToFire: state.ballCount,
      activeBallCount: 0,
      fireTimer: 0,
      isInputLocked: true,
    );
  }

  GameState startEndTurn(GameState state) {
    if (state.phase == GamePhase.gameOver) {
      return state;
    }

    final withPhase = state.copyWith(
      phase: GamePhase.endTurn,
      isInputLocked: true,
    );
    return _turnResolver.resolve(withPhase);
  }

  GameState tick(GameState state, double dt) {
    if (state.phase == GamePhase.idle ||
        state.phase == GamePhase.aiming ||
        state.phase == GamePhase.gameOver) {
      return state;
    }

    var next = state;

    if (next.phase == GamePhase.firing) {
      next = _fireFromQueue(next, dt);
      if (next.ballsToFire == 0) {
        next = next.copyWith(phase: GamePhase.busy);
      }
    }

    if (next.phase == GamePhase.busy || next.phase == GamePhase.firing) {
      next = _simulateBalls(next, dt);
      next = _mergeGroundedBalls(next, dt);

      final allMerged = next.balls.every(
        (ball) => ball.grounded && ball.merged,
      );
      if (allMerged && next.ballsToFire == 0 && next.activeBallCount == 0) {
        return startEndTurn(next);
      }

      final hasActiveBalls = next.balls.any((ball) => ball.active);
      if (!hasActiveBalls &&
          next.ballsToFire == 0 &&
          next.activeBallCount == 0) {
        // Recovery guard: force turn completion if no pending/active work
        // remains, even if a rare flag inconsistency prevents allMerged.
        return startEndTurn(next);
      }
    }

    return next;
  }

  GameState _fireFromQueue(GameState state, double dt) {
    var timer = state.fireTimer + dt;
    var ballsToFire = state.ballsToFire;
    var activeBallCount = state.activeBallCount;
    var balls = state.balls;

    while (ballsToFire > 0 &&
        timer >= GameTuning.turnConfig.fireIntervalSeconds) {
      timer -= GameTuning.turnConfig.fireIntervalSeconds;
      final launchIndex = balls.indexWhere(
        (ball) => !ball.active && !ball.grounded,
      );
      if (launchIndex < 0) {
        ballsToFire = 0;
        break;
      }

      final direction = _directionFromAngle(state.launcher.aimAngle);
      final launchSpeed =
          GameTuning.turnConfig.ballSpeed *
          state.launchSpeedMultiplier *
          (state.levelProgress.inCleanupPhase
              ? GameTuning.cleanupAssistSpeedMultiplier
              : 1.0);
      final velocity = direction * launchSpeed;

      final updated = List<Ball>.from(balls);
      final launchBall = updated[launchIndex];
      updated[launchIndex] = launchBall.copyWith(
        active: true,
        previousPosition: launchBall.position,
        velocity: velocity,
        flightTimeSeconds: 0,
      );
      balls = updated;
      ballsToFire--;
      activeBallCount++;
    }

    return state.copyWith(
      balls: balls,
      ballsToFire: ballsToFire,
      activeBallCount: activeBallCount,
      fireTimer: timer,
    );
  }

  GameState _simulateBalls(GameState state, double dt) {
    if (state.isRecalling) {
      return _recallBalls(state, dt);
    }

    var score = state.score;
    var nextLauncherX = state.nextLauncherX;
    var activeBallCount = state.activeBallCount;
    var recallButtonVisible = state.recallButtonVisible;
    final floorY = GameTuning.launcherY;

    final subDt = dt / GameTuning.physicsSubsteps;
    final epsilon = GameTuning.collisionEpsilon;

    var balls = List<Ball>.from(state.balls);
    var bricks = List<Brick>.from(state.bricks);

    for (var i = 0; i < balls.length; i++) {
      final ball = balls[i];
      if (!ball.active) {
        continue;
      }

      var current = ball;
      var position = current.position;
      var previousPosition = current.previousPosition;
      var velocity = current.velocity;
      var flightTime = current.flightTimeSeconds;
      var landed = false;
      final hitBrickIds = <int>{};

      for (var step = 0; step < GameTuning.physicsSubsteps; step++) {
        previousPosition = position;
        position = position + (velocity * subDt);
        flightTime += subDt;

        if (position.dx <= current.radius) {
          position = Offset(current.radius + epsilon, position.dy);
          velocity = _enforceMinVelocity(
            Offset(velocity.dx.abs(), velocity.dy),
          );
        } else if (position.dx >= 1 - current.radius) {
          position = Offset(1 - current.radius - epsilon, position.dy);
          velocity = _enforceMinVelocity(
            Offset(-velocity.dx.abs(), velocity.dy),
          );
        }

        if (position.dy <= current.radius) {
          position = Offset(position.dx, current.radius + epsilon);
          velocity = Offset(
            velocity.dx,
            max(velocity.dy.abs(), GameTuning.minVerticalSpeedAfterTopBounce),
          );
        }

        final hitIndex = _firstHitBrickIndex(
          position,
          current.radius,
          bricks,
          hitBrickIds,
        );
        if (hitIndex != null) {
          final brick = bricks[hitIndex];
          hitBrickIds.add(brick.id);

          final rect = _brickRect(brick.row, brick.col);
          final hitSide =
              previousPosition.dx < rect.left ||
              previousPosition.dx > rect.right;
          velocity = _enforceMinVelocity(
            hitSide
                ? Offset(-velocity.dx, velocity.dy)
                : Offset(velocity.dx, -velocity.dy),
          );

          final damage = max(1, state.damageMultiplier.floor());
          final updatedHp = brick.hp - damage;
          if (updatedHp <= 0) {
            bricks.removeAt(hitIndex);
          } else {
            bricks[hitIndex] = brick.copyWith(hp: updatedHp);
          }

          score += 10 * damage;
        }

        final crossedFloor =
            previousPosition.dy < floorY && position.dy >= floorY;
        if (velocity.dy > 0 && crossedFloor) {
          landed = true;
          break;
        }

        if (flightTime >= GameTuning.maxBallFlightSeconds) {
          landed = true;
          break;
        }
      }

      if (landed) {
        var merged = false;
        var floorX = position.dx.clamp(
          GameTuning.minLauncherX,
          GameTuning.maxLauncherX,
        );

        if (nextLauncherX == null) {
          nextLauncherX = floorX;
          merged = true;
          floorX = nextLauncherX;
          if (FeatureFlags.brickBlastRecallEnabled &&
              (state.phase == GamePhase.firing ||
                  state.phase == GamePhase.busy) &&
              !state.isRecalling) {
            recallButtonVisible = true;
          }
        }

        current = current.copyWith(
          position: Offset(floorX, floorY),
          previousPosition: Offset(floorX, floorY),
          velocity: Offset.zero,
          active: false,
          grounded: true,
          merged: merged,
          flightTimeSeconds: 0,
        );
        activeBallCount = max(0, activeBallCount - 1);
      } else {
        current = current.copyWith(
          position: position,
          previousPosition: previousPosition,
          velocity: velocity,
          flightTimeSeconds: flightTime,
        );
      }

      balls[i] = current;
    }

    return state.copyWith(
      balls: balls,
      bricks: bricks,
      score: score,
      nextLauncherX: nextLauncherX,
      activeBallCount: activeBallCount,
      recallButtonVisible: recallButtonVisible,
    );
  }

  GameState _recallBalls(GameState state, double dt) {
    final targetX = state.nextLauncherX;
    if (targetX == null) {
      return state.copyWith(isRecalling: false, recallButtonVisible: false);
    }

    final target = Offset(targetX, GameTuning.launcherY);
    final step = GameTuning.recallHomingSpeed * dt;
    final balls = List<Ball>.from(state.balls);
    var changed = false;

    for (var i = 0; i < balls.length; i++) {
      final ball = balls[i];
      if (!ball.active) {
        continue;
      }

      final toTarget = target - ball.position;
      final distance = toTarget.distance;
      if (distance <= GameTuning.recallSnapEpsilon || distance <= step) {
        balls[i] = ball.copyWith(
          position: target,
          previousPosition: target,
          velocity: Offset.zero,
          active: false,
          grounded: true,
          merged: true,
          flightTimeSeconds: 0,
        );
        changed = true;
        continue;
      }

      final direction = toTarget / distance;
      final nextPosition = ball.position + (direction * step);
      balls[i] = ball.copyWith(
        position: nextPosition,
        previousPosition: ball.position,
        velocity: Offset.zero,
        flightTimeSeconds: 0,
      );
      changed = true;
    }

    if (!changed) {
      return state.copyWith(recallButtonVisible: false);
    }

    final activeBallCount = balls.where((ball) => ball.active).length;
    return state.copyWith(
      balls: balls,
      activeBallCount: activeBallCount,
      recallButtonVisible: false,
    );
  }

  GameState _mergeGroundedBalls(GameState state, double dt) {
    if (state.nextLauncherX == null) {
      return state;
    }

    var changed = false;
    final targetX = state.nextLauncherX!;
    final speed = GameTuning.turnConfig.returnSlideSpeed;
    final step = speed * dt;
    final balls = List<Ball>.from(state.balls);

    for (var i = 0; i < balls.length; i++) {
      final ball = balls[i];
      if (!ball.grounded || ball.merged) {
        continue;
      }

      final delta = targetX - ball.position.dx;
      if (delta.abs() <= 0.002) {
        balls[i] = ball.copyWith(
          position: Offset(targetX, GameTuning.launcherY),
          previousPosition: Offset(targetX, GameTuning.launcherY),
          merged: true,
        );
        changed = true;
        continue;
      }

      final direction = delta.sign;
      final nextX = ball.position.dx + (direction * step);
      final shouldSnap = (targetX - nextX).sign != direction;
      final x = shouldSnap ? targetX : nextX;

      balls[i] = ball.copyWith(
        position: Offset(x, GameTuning.launcherY),
        previousPosition: Offset(x, GameTuning.launcherY),
        merged: x == targetX,
      );
      changed = true;
    }

    if (!changed) {
      return state;
    }

    return state.copyWith(balls: balls);
  }

  int? _firstHitBrickIndex(
    Offset position,
    double radius,
    List<Brick> bricks,
    Set<int> skipIds,
  ) {
    for (var i = 0; i < bricks.length; i++) {
      final brick = bricks[i];
      if (skipIds.contains(brick.id)) {
        continue;
      }
      final rect = _brickRect(brick.row, brick.col);
      if (_circleIntersectsRect(position, radius, rect)) {
        return i;
      }
    }
    return null;
  }

  Rect _brickRect(int row, int col) {
    final width = (1 - GameTuning.horizontalPadding * 2) / GameTuning.columns;
    final left = GameTuning.horizontalPadding + (col * width);
    final top = GameTuning.topPadding + (row * GameTuning.rowHeight);
    return Rect.fromLTWH(left, top, width, GameTuning.rowHeight);
  }

  bool _circleIntersectsRect(Offset center, double radius, Rect rect) {
    final closestX = center.dx.clamp(rect.left, rect.right);
    final closestY = center.dy.clamp(rect.top, rect.bottom);
    final dx = center.dx - closestX;
    final dy = center.dy - closestY;
    return dx * dx + dy * dy <= radius * radius;
  }

  double _angleFromPointer(Offset origin, Offset pointer) {
    final dx = pointer.dx - origin.dx;
    final dy = pointer.dy - origin.dy;
    return atan2(dy, dx) * 180 / pi;
  }

  double _clampAngle(double angle) {
    return angle.clamp(GameTuning.minAimDegrees, GameTuning.maxAimDegrees);
  }

  Offset _directionFromAngle(double angleDegrees) {
    final radians = angleDegrees * pi / 180;
    return Offset(cos(radians), sin(radians));
  }

  Offset _enforceMinVelocity(Offset velocity) {
    final speed = velocity.distance;
    if (speed >= GameTuning.minBallVelocityMagnitude || speed == 0) {
      return velocity;
    }
    final scale = GameTuning.minBallVelocityMagnitude / speed;
    return velocity * scale;
  }
}
