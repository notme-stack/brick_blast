class Launcher {
  const Launcher({required this.x, required this.y, required this.aimAngle});

  final double x;
  final double y;
  final double aimAngle;

  Launcher copyWith({double? x, double? y, double? aimAngle}) {
    return Launcher(
      x: x ?? this.x,
      y: y ?? this.y,
      aimAngle: aimAngle ?? this.aimAngle,
    );
  }
}
