import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/onboarding_service.dart';

/// Provider for the OnboardingService instance
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

/// Async state provider for checking onboarding completion status
final onboardingStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingServiceProvider);
  return await service.isOnboardingCompleted();
});
