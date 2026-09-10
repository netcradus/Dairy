import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_app/features/checkout/checkout_screen.dart';
import 'package:dairy_app/features/product/product_details_screen.dart';
import 'package:dairy_app/models/product.dart';
import 'package:dairy_app/providers/cart_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testProduct = Product(
    id: 'prod_lassi_01',
    title: 'Fresh Lassi',
    categoryId: 'cat_lassi',
    categoryName: 'Lassi',
    price: 35.0,
    originalPrice: 40.0,
    unit: '250 ml',
    imageUrl: 'assets/images/las.png',
    rating: 4.8,
    reviewCount: 42,
    isA2CowMilk: true,
    description: 'Refreshing sweet creamy lassi',
  );

  Widget createTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: ProductDetailsScreen(product: testProduct),
      ),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Buy Now & Quantity Flow Tests', () {
    testWidgets(
        'Test 1: Quantity = 1 -> Click Buy Now -> Checkout has quantity 1',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Ensure QuantitySelector shows 1
      expect(find.text('1'), findsOneWidget);

      // Tap Buy Now
      final buyNowFinder = find.widgetWithText(ElevatedButton, 'Buy Now');
      expect(buyNowFinder, findsOneWidget);
      await tester.tap(buyNowFinder);
      await tester.pumpAndSettle();

      // Verify CheckoutScreen is opened
      expect(find.byType(CheckoutScreen), findsOneWidget);

      // Verify CartNotifier has exact quantity 1
      final cart = container.read(cartProvider);
      expect(cart[testProduct.id]?.quantity, equals(1));
    });

    testWidgets(
        'Test 2: Quantity = 2 -> Click Buy Now -> Checkout has quantity 2',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Tap '+' to increase quantity to 2
      final incFinder = find.byIcon(Icons.add);
      expect(incFinder, findsOneWidget);
      await tester.tap(incFinder);
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);

      // Tap Buy Now
      final buyNowFinder = find.widgetWithText(ElevatedButton, 'Buy Now');
      await tester.tap(buyNowFinder);
      await tester.pumpAndSettle();

      // Verify CheckoutScreen and Cart quantity = 2
      expect(find.byType(CheckoutScreen), findsOneWidget);
      final cart = container.read(cartProvider);
      expect(cart[testProduct.id]?.quantity, equals(2));
    });

    testWidgets(
        'Test 3: Quantity = 3 -> Click Buy Now -> Checkout has quantity 3',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Tap '+' twice to increase quantity to 3
      final incFinder = find.byIcon(Icons.add);
      await tester.tap(incFinder);
      await tester.pumpAndSettle();
      await tester.tap(incFinder);
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);

      // Tap Buy Now
      final buyNowFinder = find.widgetWithText(ElevatedButton, 'Buy Now');
      await tester.tap(buyNowFinder);
      await tester.pumpAndSettle();

      // Verify CheckoutScreen and Cart quantity = 3
      expect(find.byType(CheckoutScreen), findsOneWidget);
      final cart = container.read(cartProvider);
      expect(cart[testProduct.id]?.quantity, equals(3));
    });

    testWidgets(
        'Test 4: Product exists in cart with qty 1 -> Open details with qty 1 -> Buy Now produces qty 1 (not 2)',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Pre-populate cart with quantity 1
      container.read(cartProvider.notifier).addItem(testProduct, 1);
      expect(container.read(cartProvider)[testProduct.id]?.quantity, equals(1));

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Page opens with selected quantity 1
      expect(find.text('1'), findsWidgets);

      // Click Buy Now
      final buyNowFinder = find.widgetWithText(ElevatedButton, 'Buy Now');
      await tester.tap(buyNowFinder);
      await tester.pumpAndSettle();

      // Expected: quantity must remain exactly 1, not 2
      final cart = container.read(cartProvider);
      expect(cart[testProduct.id]?.quantity, equals(1));
    });

    testWidgets(
        'Test 5: Click Buy Now and return to product page -> displayed quantity is preserved and does not auto-increment',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Set quantity to 2
      final incFinder = find.byIcon(Icons.add);
      await tester.tap(incFinder);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);

      // Tap Buy Now
      final buyNowFinder = find.widgetWithText(ElevatedButton, 'Buy Now');
      await tester.tap(buyNowFinder);
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutScreen), findsOneWidget);

      // Pop back to product details
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      // Verify product page still shows quantity 2 and was not incremented
      expect(find.byType(ProductDetailsScreen), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets(
        'Test 6: Click Add to Cart with quantity 1 -> adds expected quantity without breaking cart',
        (tester) async {
      setupScreenSize(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Tap Add to Cart
      final addToCartFinder =
          find.widgetWithText(OutlinedButton, 'Add to Cart');
      expect(addToCartFinder, findsOneWidget);
      await tester.tap(addToCartFinder);
      await tester.pumpAndSettle();

      // Cart now contains 1 item
      final cart = container.read(cartProvider);
      expect(cart[testProduct.id]?.quantity, equals(1));

      // SnackBar shows confirmation
      expect(find.text('Added Fresh Lassi to your Cart!'), findsOneWidget);
    });
  });
}
