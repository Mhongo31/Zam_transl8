import 'package:flutter/material.dart';
import '../models/subscription.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final List<String> languages;
  final SubscriptionTier tier;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.languages,
    required this.tier,
  });
}

class SubscriptionProvider with ChangeNotifier {
  Subscription _currentSubscription = Subscription.freeSubscription;
  List<SubscriptionPlan> _availablePlans = [];

  Subscription get currentSubscription => _currentSubscription;
  List<SubscriptionPlan> get availablePlans => _availablePlans;

  void initialize() {
    _availablePlans = [
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        description: 'Access to all Zambian languages',
        monthlyPrice: 4.99,
        yearlyPrice: 49.99,
        tier: SubscriptionTier.premium,
        features: [
          'All Zambian languages',
          'Offline translation',
          'Advanced learning exercises',
          'Progress tracking',
          'Ad-free experience',
        ],
        languages: ['en', 'lun', 'bem', 'nya', 'ton', 'loz'],
      ),
      SubscriptionPlan(
        id: 'pro',
        name: 'Pro',
        description: 'Premium + AI-powered features',
        monthlyPrice: 9.99,
        yearlyPrice: 99.99,
        tier: SubscriptionTier.pro,
        features: [
          'Everything in Premium',
          'AI conversation practice',
          'Personalized learning paths',
          'Voice recognition',
          'Cultural context explanations',
          'Priority support',
        ],
        languages: ['en', 'lun', 'bem', 'nya', 'ton', 'loz', 'kau'],
      ),
    ];
  }

  Future<bool> subscribeToPlan(String planId, bool isYearly) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final plan = _availablePlans.firstWhere((p) => p.id == planId);
    
    _currentSubscription = Subscription(
      tier: plan.tier,
      expiryDate: DateTime.now().add(Duration(days: isYearly ? 365 : 30)),
      isActive: true,
      availableLanguages: plan.languages,
    );

    notifyListeners();
    return true;
  }

  void updateSubscription(Subscription subscription) {
    _currentSubscription = subscription;
    notifyListeners();
  }

  bool canAccessLanguage(String languageCode) {
    return _currentSubscription.canAccessLanguage(languageCode);
  }
}
