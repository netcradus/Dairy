import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_app/models/order.dart';
import 'package:dairy_app/models/address.dart';
import 'package:dairy_app/models/cart_item.dart';
import 'package:dairy_app/models/product.dart';
import 'package:dairy_app/models/delivery_boy_model.dart';
import 'package:dairy_app/models/order_model.dart' as admin_order;

void main() {
  group('Order Code Format & Generation Tests', () {
    final orderCodePattern = RegExp(r'^[A-Z]{3}[0-9]{3}$');

    test('generateRandomOrderCode produces valid 6-char LLLNNN code', () {
      for (int i = 0; i < 100; i++) {
        final code = Order.generateRandomOrderCode();
        expect(code.length, 6, reason: 'Code must be exactly 6 characters');
        expect(orderCodePattern.hasMatch(code), isTrue,
            reason: 'Code $code must match 3 uppercase letters followed by 3 numbers');
      }
    });

    test('formatFallbackOrderCode produces valid deterministic 6-char LLLNNN code', () {
      const docIds = [
        'qdGceFb4bFokrvU9wkUO',
        'GGhB3QDR2QU9jZQWGSEX',
        'n2mT73NMrn2UV2MgfSto',
        'abc123',
        'order_9999',
      ];

      for (final docId in docIds) {
        final code1 = Order.formatFallbackOrderCode(docId);
        final code2 = Order.formatFallbackOrderCode(docId);

        expect(code1, equals(code2), reason: 'Fallback must be deterministic');
        expect(code1.length, 6);
        expect(orderCodePattern.hasMatch(code1), isTrue,
            reason: 'Fallback code $code1 must match LLLNNN format');
      }
    });

    test('Order model preserves Firestore docId while providing displayOrderCode', () {
      const docId = 'qdGceFb4bFokrvU9wkUO';
      final order = Order(
        id: docId,
        orderCode: 'KRT482',
        items: const [
          CartItem(
            product: Product(
              id: 'p1',
              title: 'Fresh Milk',
              categoryId: 'c1',
              categoryName: 'Milk',
              price: 32.0,
              unit: '500 ml',
              imageUrl: '',
            ),
            quantity: 2,
          ),
        ],
        subtotal: 64.0,
        totalAmount: 64.0,
        status: OrderStatus.placed,
        orderDate: DateTime(2026, 9, 11, 8, 30),
        deliveryAddress: const Address(
          id: 'a1',
          label: 'Home',
          fullName: 'Test User',
          mobileNumber: '9876543210',
          houseFlat: '101',
          streetArea: 'MG Road',
          city: 'Indore',
          state: 'MP',
          pinCode: '452001',
        ),
      );

      expect(order.id, equals('qdGceFb4bFokrvU9wkUO'),
          reason: 'Internal Firestore doc ID must remain intact');
      expect(order.orderCode, equals('KRT482'));
      expect(order.displayOrderCode, equals('KRT482'));
    });

    test('Order model handles legacy documents without orderCode gracefully', () {
      const docId = 'GGhB3QDR2QU9jZQWGSEX';
      final rawFirestoreData = <String, dynamic>{
        'status': 'Pending',
        'subtotal': 100.0,
        'totalAmount': 100.0,
        'createdAt': '2026-09-11T08:30:00.000Z',
        'items': [],
      };

      final legacyOrder = Order.fromFirestore(rawFirestoreData, docId);

      expect(legacyOrder.id, equals(docId));
      expect(legacyOrder.orderCode.isNotEmpty, isTrue);
      expect(orderCodePattern.hasMatch(legacyOrder.displayOrderCode), isTrue);
      expect(legacyOrder.displayOrderCode.length, 6);
    });

    test('Order serialization preserves orderCode for Firestore write', () {
      const docId = 'test_doc_123';
      final order = Order(
        id: docId,
        orderCode: 'ABX071',
        items: const [],
        subtotal: 50.0,
        totalAmount: 50.0,
        status: OrderStatus.confirmed,
        orderDate: DateTime(2026, 9, 11),
        deliveryAddress: const Address(
          id: 'a1',
          label: 'Home',
          fullName: 'Customer',
          mobileNumber: '',
          houseFlat: '',
          streetArea: '',
          city: '',
          state: '',
          pinCode: '',
        ),
      );

      final firestoreMap = order.toFirestore();
      expect(firestoreMap['orderCode'], equals('ABX071'));

      final fullMap = order.toMap();
      expect(fullMap['id'], equals('test_doc_123'));
      expect(fullMap['orderCode'], equals('ABX071'));
    });

    test('DeliveryOrder and DairyOrder models display code properly', () {
      final deliveryOrder = DeliveryOrder(
        id: 'doc_deliv_123',
        orderId: 'doc_deliv_123',
        orderCode: 'QPM936',
        customerName: 'Aarav Patel',
        customerPhone: '9876543210',
        customerAddress: 'Vijay Nagar',
        pickupLocation: 'Hub',
        pickupPhone: '123',
        items: const ['Milk 500ml x2'],
        amount: 64.0,
        deliveryFee: 0.0,
        status: DeliveryOrderStatus.accepted,
        orderTime: DateTime(2026, 9, 11),
        distance: '2.5 km',
        estimatedTime: '20 mins',
      );

      expect(deliveryOrder.id, equals('doc_deliv_123'));
      expect(deliveryOrder.orderId, equals('doc_deliv_123'));
      expect(deliveryOrder.displayCode, equals('QPM936'));

      const adminOrderModel = admin_order.DairyOrder(
        id: 'doc_admin_456',
        orderCode: 'XYZ204',
        customerName: 'Neha Sharma',
        customerPhone: '9876543210',
        itemsSummary: 'Fresh Paneer 200g',
        amount: 85.0,
        status: admin_order.OrderStatus.preparing,
        deliverySlot: 'Today 7:30 AM',
        address: 'MG Road',
        time: '07:00 AM',
        paymentMode: 'Cash on Delivery',
      );

      expect(adminOrderModel.id, equals('doc_admin_456'));
      expect(adminOrderModel.orderCode, equals('XYZ204'));
      expect(adminOrderModel.displayCode, equals('XYZ204'));
    });
  });
}
