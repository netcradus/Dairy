import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/features/home/home_screen.dart';
import 'package:dairy_app/models/category.dart';
import 'package:dairy_app/providers/product_provider.dart';

void main() {
  testWidgets('HomeScreen renders without crashing',
      (WidgetTester tester) async {
    const testCategory = Category(
      id: 'cat_milk',
      title: 'Fresh Milk',
      subtitle: '100% Pure',
      imageUrl: 'assets/images/doodh.png',
      iconData: Icons.local_drink_rounded,
      backgroundColor: Color(0xFFEAF5FF),
      borderColor: Color(0xFF5B9BD5),
      titleColor: Color(0xFF0C1A30),
      itemCount: 8,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesProvider.overrideWith(
            (ref) => Stream.value([testCategory]),
          ),
        ],
        child: const MaterialApp(
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
