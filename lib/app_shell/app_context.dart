import '../capabilities/ads/ads_service.dart';
import '../capabilities/analytics/analytics_service.dart';
import '../capabilities/monetization/purchase_service.dart';
import '../capabilities/storage/local_storage_service.dart';

class AppContext {
  const AppContext({
    required this.analyticsService,
    required this.adsService,
    required this.purchaseService,
    required this.storageService,
  });

  final AnalyticsService analyticsService;
  final AdsService adsService;
  final PurchaseService purchaseService;
  final LocalStorageService storageService;
}
