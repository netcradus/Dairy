import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_app/models/subscription.dart';
import 'package:dairy_app/models/product.dart';

void main() {
  group('Task 2 Subscription Model & Firestore Serialization Tests', () {
    const testProduct = Product(
      id: 'prod_1',
      title: 'A2 Cow Milk 1L',
      price: 85.0,
      description: 'Fresh milk',
      imageUrl: 'https://firebasestorage.googleapis.com/test.jpg',
      categoryId: 'milk',
      categoryName: 'Milk',
      unit: '1L',
      inStock: true,
      rating: 4.8,
      reviewCount: 120,
      isFreshDeal: true,
      originalPrice: 95.0,
    );

    test('Subscription creates and serializes to Firestore correctly', () {
      final now = DateTime.now();
      final sub = Subscription(
        id: 'sub_test_1',
        product: testProduct,
        quantity: 2,
        frequency: SubscriptionFrequency.daily,
        status: SubscriptionStatus.active,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        nextDeliveryDate: now.add(const Duration(days: 1)),
        deliveryTimeSlot: 'Morning (6:00 AM - 9:00 AM)',
        includeIcePack: true,
        planId: 'plan_prod_1',
        planName: 'A2 Cow Milk Monthly Plan',
        autoRenew: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = sub.toFirestore();
      expect(map['id'], 'sub_test_1');
      expect(map['planId'], 'plan_prod_1');
      expect(map['planName'], 'A2 Cow Milk Monthly Plan');
      expect(map['status'], 'Active');
      expect(map['frequency'], 'Daily');
      expect(map['quantity'], 2);
      expect(map['autoRenew'], true);
      expect(map['deliveryTimeSlot'], 'Morning (6:00 AM - 9:00 AM)');
      expect(map['includeIcePack'], true);
      expect(map['product'], isNotNull);
      expect((map['product'] as Map<String, dynamic>)['id'], 'prod_1');
    });

    test('Subscription deserializes from Firestore data correctly', () {
      final now = DateTime.now();
      final data = {
        'id': 'sub_123',
        'planId': 'plan_milk_monthly',
        'planName': 'Daily Milk',
        'status': 'Active',
        'frequency': 'Alternate Days',
        'quantity': 1,
        'startDate': now.toIso8601String(),
        'endDate': now.add(const Duration(days: 14)).toIso8601String(),
        'nextDeliveryDate': now.add(const Duration(days: 2)).toIso8601String(),
        'deliveryTimeSlot': 'Evening (5:00 PM - 8:00 PM)',
        'includeIcePack': false,
        'autoRenew': true,
        'product': {
          'id': 'milk_1',
          'title': 'Buffalo Milk',
          'price': 90.0,
          'description': 'Pure buffalo milk',
          'imageUrl': 'buffalo.jpg',
          'category': 'milk',
          'categoryName': 'Milk',
          'unit': '1L',
          'isAvailable': true,
          'rating': 4.9,
          'reviewCount': 50,
        },
      };

      final sub = Subscription.fromMap(data, id: 'sub_123');
      expect(sub.id, 'sub_123');
      expect(sub.planId, 'plan_milk_monthly');
      expect(sub.planName, 'Daily Milk');
      expect(sub.status, SubscriptionStatus.active);
      expect(sub.frequency, SubscriptionFrequency.alternateDay);
      expect(sub.quantity, 1);
      expect(sub.includeIcePack, false);
      expect(sub.autoRenew, true);
      expect(sub.product.title, 'Buffalo Milk');
      expect(sub.isActiveAndValid, true);
    });

    test('Subscription safely handles null/missing dates and fallback status',
        () {
      final data = {
        'id': 'sub_minimal',
        'quantity': 1,
      };

      final sub = Subscription.fromMap(data, id: 'sub_minimal');
      expect(sub.id, 'sub_minimal');
      expect(sub.status, SubscriptionStatus.active);
      expect(sub.frequency, SubscriptionFrequency.daily);
      expect(sub.startDate, isNotNull);
      expect(sub.nextDeliveryDate, isNull);
    });

    test('Subscription lifecycle status transitions', () {
      final sub = Subscription(
        id: 'sub_lifecycle',
        product: testProduct,
        quantity: 1,
        frequency: SubscriptionFrequency.daily,
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
      );

      final paused = sub.copyWith(status: SubscriptionStatus.paused);
      expect(paused.status, SubscriptionStatus.paused);

      final cancelled = sub.copyWith(status: SubscriptionStatus.cancelled);
      expect(cancelled.status, SubscriptionStatus.cancelled);
      expect(cancelled.isCancelled, true);

      final resumed = cancelled.copyWith(status: SubscriptionStatus.active);
      expect(resumed.status, SubscriptionStatus.active);
    });
  });
}
