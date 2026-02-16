import 'analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> params = const {},
  }) async {
    // Placeholder implementation until Firebase is wired.
  }
}
