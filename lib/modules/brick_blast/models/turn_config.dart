class TurnConfig {
  const TurnConfig({
    required this.fireIntervalSeconds,
    required this.ballSpeed,
    required this.returnSlideSpeed,
    required this.maxBounceCorrectionsPerFrame,
  });

  final double fireIntervalSeconds;
  final double ballSpeed;
  final double returnSlideSpeed;
  final int maxBounceCorrectionsPerFrame;
}
