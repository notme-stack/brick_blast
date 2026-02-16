import 'analytics_service.dart';

class NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> params = const {},
  }) async {}
}
