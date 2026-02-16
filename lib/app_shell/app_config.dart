class AppConfig {
  const AppConfig({
    this.adsEnabled = false,
    this.analyticsEnabled = false,
    this.purchasesEnabled = false,
  });

  final bool adsEnabled;
  final bool analyticsEnabled;
  final bool purchasesEnabled;
}
