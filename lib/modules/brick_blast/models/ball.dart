import 'package:flutter/material.dart';

class Ball {
  const Ball({
    required this.id,
    required this.position,
    required this.previousPosition,
    required this.velocity,
    required this.radius,
    required this.active,
    required this.grounded,
    required this.merged,
    required this.flightTimeSeconds,
  });

  final int id;
  final Offset position;
  final Offset previousPosition;
  final Offset velocity;
  final double radius;
  final bool active;
  final bool grounded;
  final bool merged;
  final double flightTimeSeconds;

  Ball copyWith({
    int? id,
    Offset? position,
    Offset? previousPosition,
    Offset? velocity,
    double? radius,
    bool? active,
    bool? grounded,
    bool? merged,
    double? flightTimeSeconds,
  }) {
    return Ball(
      id: id ?? this.id,
      position: position ?? this.position,
      previousPosition: previousPosition ?? this.previousPosition,
      velocity: velocity ?? this.velocity,
      radius: radius ?? this.radius,
      active: active ?? this.active,
      grounded: grounded ?? this.grounded,
      merged: merged ?? this.merged,
      flightTimeSeconds: flightTimeSeconds ?? this.flightTimeSeconds,
    );
  }
}
