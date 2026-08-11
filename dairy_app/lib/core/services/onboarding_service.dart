import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing Onboarding completion persistence
class OnboardingService {
  static const String _onboardingKey = 'onboarding_completed';

  /// Check if the user has already completed onboarding
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted([bool completed = true]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, completed);
  }

  /// Reset onboarding state (useful for testing or logout)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }
}
