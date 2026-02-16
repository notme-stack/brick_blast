import 'ads_service.dart';

class NoopAdsService implements AdsService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showInterstitial() async {}
}
