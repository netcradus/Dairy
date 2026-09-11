import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairy_app/features/shop/shop_screen.dart';
import 'package:dairy_app/models/product.dart';
import 'package:dairy_app/providers/product_provider.dart';

void main() {
  const testProduct = Product(
    id: 'prod_milk_01',
    title: 'Fresh Cow Milk',
    categoryId: 'cat_milk',
    categoryName: 'Milk',
    price: 60.0,
    originalPrice: 65.0,
    unit: '1 L',
    imageUrl: 'assets/images/doodh.png',
    rating: 4.9,
    reviewCount: 50,
    isA2CowMilk: true,
    description: 'Fresh farm cow milk',
  );

  testWidgets('ShopScreen renders products without layout errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allProductsStreamProvider
              .overrideWith((ref) => Stream.value([testProduct])),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ShopScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Header and category options should be present.
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);

    // Product card should render.
    expect(find.text('Fresh Cow Milk'), findsOneWidget);
  });
}
