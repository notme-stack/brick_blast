import 'dart:math' as math;

import '../models/turn_config.dart';

class GameTuning {
  static const int maxWavesPerLevel = 60;
  static const int columns = 7;
  static const int maxRows = 10;
  static const int initialPrefillRows = 4;
  static const int initialBallCount = 15;
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
  static const double recallHomingSpeed = 2.4;
  static const double recallSnapEpsilon = 0.003;
  static const double recallButtonBottomInset = 18;
  static const double recallButtonLeftInset = 14;
  static const double turnSpeedGrowthMultiplier = 1.07;
  static const double maxLaunchSpeedMultiplier = 2.0;
  static const int finalWaveBannerDurationMs = 1400;
  static const List<int> blitzLevels = [3, 8, 13];

  static const TurnConfig turnConfig = TurnConfig(
    fireIntervalSeconds: 0.055,
    ballSpeed: 1.425,
    returnSlideSpeed: 1.5,
    maxBounceCorrectionsPerFrame: 2,
  );

  static int wavesForLevel(int level) {
    final normalizedLevel = level < 1 ? 1 : level;
    final raw = 10 + (6 * math.log(normalizedLevel)).floor();
    return raw.clamp(10, maxWavesPerLevel);
  }

  static int maxBallsForLevel(int level) {
    final normalizedLevel = level < 1 ? 1 : level;
    final raw = 30 + (35 * math.log(normalizedLevel)).floor();
    return raw < 30 ? 30 : raw;
  }

  static int baseHpForWave(int level, int waveNumber) {
    final normalizedLevel = level < 1 ? 1 : level;
    final normalizedWave = waveNumber < 1 ? 1 : waveNumber;
    return (normalizedLevel * 3) + normalizedWave;
  }

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
