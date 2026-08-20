import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/earning_model.dart';
import 'earnings_service.dart';

/// Creates and persists customer orders in Cloud Firestore.
///
/// A new order document is written to the `orders` collection with the user's
/// id, the delivery address, the cart line items, the computed totals, and a
/// status of 'Pending'.
class OrderService {
  final FirebaseFirestore _firestore;
  final EarningsService _earningsService;

  /// Commission credited to the agent, as a fraction of the order subtotal,
  /// when an order is delivered. Tune this to match your payout policy.
  static const double agentEarningRate = 0.10;

  OrderService({
    FirebaseFirestore? firestore,
    EarningsService? earningsService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _earningsService = earningsService ?? EarningsService();

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

  /// Updates an order's status in Firestore. When the status becomes
  /// [OrderStatus.delivered], the assigned agent's earnings are logged.
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': orderStatusToString(status)});
    } catch (e) {
      throw Exception('Failed to update order status for $orderId: $e');
    }

    if (status == OrderStatus.delivered) {
      // Earnings logging is best-effort: a failure here must not roll back the
      // successful status update above.
      await _logEarningForDeliveredOrder(orderId);
    }
  }

  /// Credits the assigned agent's earnings for a delivered order. Reads the
  /// order document to obtain the agent id and totals, then writes an
  /// [EarningModel] keyed by the order id (preventing duplicates). Any failure
  /// is swallowed so the delivery itself is not affected.
  Future<void> _logEarningForDeliveredOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      final data = doc.data();
      if (data == null) return;

      final assignedAgentId = (data['assignedAgentId'] as String?);
      if (assignedAgentId == null || assignedAgentId.isEmpty) return;

      final order = Order.fromFirestore(data, doc.id);
      final amountEarned = order.subtotal * agentEarningRate;

      final earning = EarningModel(
        id: orderId,
        agentId: assignedAgentId,
        orderId: orderId,
        amountEarned: amountEarned,
        tipAmount: 0.0,
        deliveryFee: order.deliveryCharge,
        timestamp: DateTime.now(),
        status: EarningStatus.pending,
      );

      await _earningsService.logEarning(earning);
    } catch (e) {
      debugPrint('Warning: failed to log earnings for order $orderId: $e');
    }
  }

  /// Cancels an order by setting its status to [OrderStatus.cancelled].
  Future<void> cancelOrder(String orderId) =>
      updateOrderStatus(orderId, OrderStatus.cancelled);

  /// Live stream of active (accepted / in-progress) orders from the `orders`
  /// collection, used by the delivery panel Active tab and the tracking map.
  /// Orders that are still `Pending` (awaiting driver acceptance) are excluded
  /// here and handled by the Requests flow instead.
  ///
  /// Status filtering is done client-side to avoid requiring a composite index.
  Stream<List<Order>> streamActiveOrders() {
    const activeStatuses = {'confirmed', 'preparing', 'outForDelivery'};
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Order.fromFirestore(d.data(), d.id))
            .where((o) => activeStatuses.contains(orderStatusToString(o.status)))
            .toList()
          ..sort((a, b) => b.orderDate.compareTo(a.orderDate)));
  }

  /// Live stream of ALL orders in the `orders` collection (every status),
  /// newest first. This is the single source of truth for the delivery panel:
  /// the Requests, Active and History tabs all derive their lists from it.
  Stream<List<Order>> streamAllDeliveryOrders() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Order.fromFirestore(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.orderDate.compareTo(a.orderDate)));
  }

  /// Live stream of the orders relevant to a delivery agent: any order that is
  /// still `pending` (awaiting acceptance) OR already assigned to [agentId].
  /// Filtering is done client-side to avoid requiring a composite index.
  Stream<List<Order>> streamDeliveryOrdersForAgent(String agentId) {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Order.fromFirestore(d.data(), d.id))
            .where((o) =>
                o.status == OrderStatus.placed ||
                (o.assignedAgentId != null && o.assignedAgentId == agentId))
            .toList()
          ..sort((a, b) => b.orderDate.compareTo(a.orderDate)));
  }

  /// Accepts an order on behalf of a delivery agent. Persists the acceptance to
  /// Firestore as the single source of truth: the order moves from `pending` to
  /// `accepted`, is bound to [agentId], and records the acceptance time.
  ///
  /// Throws if the write fails so callers can surface a graceful error.
  Future<void> acceptOrder(String orderId, String agentId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'accepted',
      'assignedAgentId': agentId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Releases an order an agent had accepted: clears the assignment and returns
  /// it to `pending` so it can be picked up by another agent.
  Future<void> declineOrder(String orderId, String agentId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'pending',
      'assignedAgentId': null,
      'acceptedAt': null,
    });
  }
}

/// Provides a singleton [OrderService], injecting the [EarningsService] so
/// deliveries automatically credit agent earnings.
final orderServiceProvider = Provider<OrderService>((ref) => OrderService(
      earningsService: ref.watch(earningsServiceProvider),
    ));
