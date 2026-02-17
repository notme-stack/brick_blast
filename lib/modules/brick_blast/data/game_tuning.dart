import '../models/turn_config.dart';

class GameTuning {
  static const int columns = 7;
  static const int maxRows = 10;
  static const int initialPrefillRows = 4;
  static const int initialBallCount = 10;
  static const double launcherY = 0.96;
  static const double minLauncherX = 0.07;
  static const double maxLauncherX = 0.93;
  static const double ballRadius = 0.012;
  static const double topPadding = 0.08;
  static const double rowHeight = 0.075;
  static const double horizontalPadding = 0.04;
  static const double rowDensity = 0.58;
  static const int baseBrickHp = 1;
  static const double minAimDegrees = -170;
  static const double maxAimDegrees = -10;

  static const bool useLevelProgression = true;
  static const bool easyProfileEnabled = true;
  static const int wallFrequency = 5;
  static const int wallWavesStartLevel = 6;
  static const double bossHpMultiplier = 2.5;
  static const double blitzDamageMultiplier = 2.0;
  static const double cleanupAssistSpeedMultiplier = 1.1;
  static const int physicsSubsteps = 3;
  static const double collisionEpsilon = 0.0005;
  static const double maxBallFlightSeconds = 12.0;
  static const double minVerticalSpeedAfterTopBounce = 0.22;
  static const double minBallVelocityMagnitude = 0.16;
  static const double turnSpeedGrowthMultiplier = 1.07;
  static const double maxLaunchSpeedMultiplier = 2.0;
  static const int finalWaveBannerDurationMs = 1400;
  static const List<int> blitzLevels = [3, 8, 13];

  static const TurnConfig turnConfig = TurnConfig(
    fireIntervalSeconds: 0.055,
    ballSpeed: 0.95,
    returnSlideSpeed: 1.5,
    maxBounceCorrectionsPerFrame: 2,
  );

  static double brickWidth(double boardWidth) {
    return (boardWidth * (1 - horizontalPadding * 2)) / columns;
  }

  static const double dangerLineYNormalized = launcherY - rowHeight;

  static double brickTopY(int row) {
    return topPadding + (row * rowHeight);
  }

  static double brickBottomY(int row) {
    return brickTopY(row) + rowHeight;
  }

  static bool isAtOrPastDangerLine(double brickBottom) {
    return brickBottom >= dangerLineYNormalized;
  }
}
