import 'purchase_service.dart';

class NoopPurchaseService implements PurchaseService {
  @override
  Future<void> buyPremium() async {}

  @override
  Future<bool> hasActiveSubscription() async => false;
}
