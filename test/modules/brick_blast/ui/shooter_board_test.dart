import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:brick_blast/modules/brick_blast/data/game_tuning.dart';
import 'package:brick_blast/modules/brick_blast/widgets/shooter_board.dart';

void main() {
  test('trajectory helper returns two reflected segments within bounds', () {
    final segments = computeTwoSegmentTrajectory(
      start: const Offset(0.5, 0.96),
      aimAngleDegrees: -30,
      bounds: const Rect.fromLTWH(0, 0, 1, 1),
    );

    expect(segments.length, 2);
    expect(segments.first.start.dx, closeTo(0.5, 0.0001));
    expect(segments.first.start.dy, closeTo(0.96, 0.0001));

    for (final segment in segments) {
      expect(segment.end.dx, inInclusiveRange(0.0, 1.0));
      expect(segment.end.dy, inInclusiveRange(0.0, 1.0));
    }
  });

  test('danger line pixel Y uses shared normalized tuning value', () {
    const size = Size(600, 1000);
    final y = computeDangerLineYPx(size);
    expect(y, closeTo(GameTuning.dangerLineYNormalized * size.height, 0.0001));
  });
}
