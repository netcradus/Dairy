import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/address.dart';
import '../models/cart_item.dart';

/// Creates and persists customer orders in Cloud Firestore.
///
/// A new order document is written to the `orders` collection with the user's
/// id, the delivery address, the cart line items, the computed totals, and a
/// status of 'Pending'.
class OrderService {
  final FirebaseFirestore _firestore;

  OrderService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Pricing rules (mirror the cart provider so the service is self-contained).
  static const double freeDeliveryThreshold = 500.0;
  static const double deliveryCharge = 30.0;
  static const double discountRate = 0.10;

  /// Computes subtotal, delivery charge, discount, and grand total for [items].
  ({double subtotal, double deliveryCharge, double discount, double total})
      computeTotals(List<CartItem> items) {
    final subtotal =
        items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final delivery = subtotal == 0
        ? 0.0
        : (subtotal >= freeDeliveryThreshold ? 0.0 : deliveryCharge);
    final discount =
        subtotal >= freeDeliveryThreshold ? subtotal * discountRate : 0.0;
    final total = (subtotal + delivery - discount).clamp(0.0, double.infinity);
    return (
      subtotal: subtotal,
      deliveryCharge: delivery,
      discount: discount,
      total: total,
    );
  }

  /// Writes a new order to Firestore from the provided cart [items] and returns
  /// the created [Order] (with its generated id).
  Future<Order> placeOrder({
    required String userId,
    required List<CartItem> items,
    required Address deliveryAddress,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('Cannot place an order with an empty cart.');
    }

    final totals = computeTotals(items);
    final docRef = _firestore.collection('orders').doc();
    final now = DateTime.now();

    final order = Order(
      id: docRef.id,
      items: items,
      subtotal: totals.subtotal,
      deliveryCharge: totals.deliveryCharge,
      discount: totals.discount,
      totalAmount: totals.total,
      status: OrderStatus.placed,
      orderDate: now,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );

    await docRef.set({
      'userId': userId,
      'status': 'Pending',
      'items': items
          .map((item) => {
                'productId': item.product.id,
                'title': item.product.title,
                'unit': item.product.unit,
                'price': item.product.price,
                'quantity': item.quantity,
                'totalPrice': item.totalPrice,
                'imageUrl': item.product.imageUrl,
              })
          .toList(),
      'subtotal': totals.subtotal,
      'deliveryCharge': totals.deliveryCharge,
      'discount': totals.discount,
      'totalAmount': totals.total,
      'deliveryAddress': {
        'fullName': deliveryAddress.fullName,
        'mobileNumber': deliveryAddress.mobileNumber,
        'houseFlat': deliveryAddress.houseFlat,
        'streetArea': deliveryAddress.streetArea,
        'city': deliveryAddress.city,
        'state': deliveryAddress.state,
        'pinCode': deliveryAddress.pinCode,
        'label': deliveryAddress.label,
        'fullAddressText': deliveryAddress.fullAddressText,
      },
      'paymentMethod': paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return order;
  }

  /// Live stream of a user's orders, newest first.
  Stream<List<Order>> streamOrdersForUser(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Order.fromFirestore(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.orderDate.compareTo(a.orderDate)));
  }

  /// Updates an order's status in Firestore.
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': orderStatusToString(status)});
  }

  /// Cancels an order by setting its status to [OrderStatus.cancelled].
  Future<void> cancelOrder(String orderId) =>
      updateOrderStatus(orderId, OrderStatus.cancelled);

  /// Live stream of all active (not yet delivered/cancelled) orders from the
  /// `orders` collection. Used by the delivery panel and tracking map.
  ///
  /// Status filtering is done client-side to avoid requiring a composite index.
  Stream<List<Order>> streamActiveOrders() {
    const activeStatuses = {'Pending', 'confirmed', 'preparing', 'outForDelivery'};
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Order.fromFirestore(d.data(), d.id))
            .where((o) => activeStatuses.contains(orderStatusToString(o.status)))
            .toList()
          ..sort((a, b) => b.orderDate.compareTo(a.orderDate)));
  }
}

/// Provides a singleton [OrderService].
final orderServiceProvider = Provider<OrderService>((ref) => OrderService());
