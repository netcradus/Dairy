import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/features/shop/shop_screen.dart';

void main() {
  testWidgets('ShopScreen renders products without layout errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ShopScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Header, search and filters should be present.
    expect(find.byType(TextField), findsOneWidget);
    // Product cards should render (best sellers / all products).
    expect(find.text('All Fresh Dairy Products'), findsOneWidget);
  });
}
