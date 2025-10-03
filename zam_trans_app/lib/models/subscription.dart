enum SubscriptionTier {
  free,
  premium,
  pro,
}

class Subscription {
  final SubscriptionTier tier;
  final DateTime? expiryDate;
  final bool isActive;
  final List<String> availableLanguages;

  Subscription({
    required this.tier,
    this.expiryDate,
    required this.isActive,
    required this.availableLanguages,
  });

  static Subscription get freeSubscription => Subscription(
    tier: SubscriptionTier.free,
    isActive: true,
    availableLanguages: ['en', 'lun', 'bem'],
  );

  bool canAccessLanguage(String languageCode) {
    return availableLanguages.contains(languageCode);
  }

  String get tierName {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }
}
