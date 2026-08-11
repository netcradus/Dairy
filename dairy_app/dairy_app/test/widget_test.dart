import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/core/services/onboarding_service.dart';
import 'package:dairy_app/main.dart';
import 'package:dairy_app/providers/onboarding_provider.dart';

/// Fake onboarding service that reports onboarding as completed so the
/// splash screen navigates to the Login screen during tests.
class _FakeOnboardingService extends OnboardingService {
  @override
  Future<bool> isOnboardingCompleted() async => true;
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingServiceProvider.overrideWithValue(
            _FakeOnboardingService(),
          ),
        ],
        child: const SawariyaDairyApp(),
      ),
    );

    // Advance past the splash screen timer (2200ms) and settle animations.
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // After splash, onboarding is "completed" so we land on the Login screen.
    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
