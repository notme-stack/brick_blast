abstract class PurchaseService {
  Future<bool> hasActiveSubscription();
  Future<void> buyPremium();
}
