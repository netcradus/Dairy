import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/features/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: HomeScreen()),
        ),
      ),
    );

    await tester.pump();

    // Verify key home screen sections render.
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Fresh Milk'), findsWidgets);
  });
}
