import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding Next button advances pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should start on page 0.
    expect(find.text('Fresh Dairy, Every Day'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap Next → page 1.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Pure Products, Trusted Quality'), findsOneWidget);

    // Tap Next → page 2.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Simple Shopping, Fresh Delivery'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
