import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dairy_app/models/order.dart' as model;

/// Filter states for the delivery agent's order history view.
enum OrderHistoryFilter {
  all,
  completed,
  cancelled,
}

/// Currently selected history filter (All / Completed / Cancelled).
final orderHistoryFilterProvider =
    StateProvider<OrderHistoryFilter>((ref) => OrderHistoryFilter.all);

/// Live Firestore stream of the delivery agent's order history.
///
/// Queries `orders` where the agent is assigned, filters by the selected
/// [OrderHistoryFilter], and returns the results sorted by `createdAt`
/// (descending) via [model.Order.orderDate].
///
/// The family parameter is the agent's uid; watching [orderHistoryFilterProvider]
/// rebuilt this stream whenever the filter changes.
final deliveryHistoryStreamProvider =
    StreamProvider.family<List<model.Order>, String>((ref, agentId) {
  final filter = ref.watch(orderHistoryFilterProvider);

  return FirebaseFirestore.instance
      .collection('orders')
      .where('assignedAgentId', isEqualTo: agentId)
      .snapshots()
      .map((snap) {
    final orders = snap.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;
      return model.Order.fromFirestore(data, doc.id);
    })
        .whereType<model.Order>()
        .where((order) {
      if (filter == OrderHistoryFilter.completed) {
        return order.status == model.OrderStatus.delivered;
      }
      if (filter == OrderHistoryFilter.cancelled) {
        return order.status == model.OrderStatus.cancelled;
      }
      return true; // OrderHistoryFilter.all
    }).toList();

    // Sort descending by creation time (newest first).
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return orders;
  });
});
