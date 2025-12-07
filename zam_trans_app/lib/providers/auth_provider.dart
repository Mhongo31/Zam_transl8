import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/subscription.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  Subscription _subscription = Subscription.freeSubscription;
  bool _isLoading = false;

  User? get user => _user;
  Subscription get subscription => _subscription;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> initialize() async {
    _isLoading = true;
    // Don't notify during initialization - nothing is listening yet

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      // In a real app, you'd parse the JSON and create a User object
      _user = User(
        id: '1',
        name: 'Demo User',
        email: 'demo@example.com',
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
        streakDays: 5,
        totalTranslations: 150,
        favoriteLanguages: ['lun', 'bem'],
        languageProgress: {'lun': 75, 'bem': 45, 'nya': 20},
      );
    }

    _isLoading = false;
    // No need to notify - splash screen doesn't listen, and we navigate away after init
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    // Notify after the current frame is built
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _user = User(
      id: '1',
      name: 'Demo User',
      email: email,
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
      streakDays: 5,
      totalTranslations: 150,
      favoriteLanguages: ['lun', 'bem'],
      languageProgress: {'lun': 75, 'bem': 45, 'nya': 20},
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', 'demo_user');

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _user = null;
    _subscription = Subscription.freeSubscription;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    
    notifyListeners();
  }

  void updateSubscription(Subscription newSubscription) {
    _subscription = newSubscription;
    notifyListeners();
  }
}
