import 'package:flutter/foundation.dart';

class FeatureFlags {
  static const bool _brickBlastRecallEnabledDefault = bool.fromEnvironment(
    'BRICK_BLAST_RECALL_ENABLED',
    defaultValue: true,
  );

  static bool? _brickBlastRecallEnabledOverride;

  static bool get brickBlastRecallEnabled =>
      _brickBlastRecallEnabledOverride ?? _brickBlastRecallEnabledDefault;

  @visibleForTesting
  static void setBrickBlastRecallEnabledOverride(bool? value) {
    _brickBlastRecallEnabledOverride = value;
  }
}
