import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'user_provider.dart';

/// Live Firestore stream of a user's orders, keyed by their user id.
final userOrdersStreamProvider =
    StreamProvider.autoDispose.family<List<Order>, String>((ref, userId) {
  return ref.watch(orderServiceProvider).streamOrdersForUser(userId);
});

// ---------------------------------------------------------------------------
// Firestore-backed customer providers
// ---------------------------------------------------------------------------

/// The currently authenticated Firebase user's uid, or null for guests.
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(userProvider);
  return user.id.isEmpty ? null : user.id;
});

/// All orders for the current user from Firestore.
final customerOrdersProvider = StreamProvider.autoDispose<List<Order>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const Stream.empty();
  }
  return ref.watch(orderServiceProvider).streamOrdersForUser(userId);
});

/// Upcoming orders for the current user from Firestore.
final customerUpcomingOrdersProvider = Provider<AsyncValue<List<Order>>>((ref) {
  return ref.watch(customerOrdersProvider).whenData(
        (orders) => orders.where((o) => o.isUpcoming).toList(),
      );
});

/// Completed orders for the current user from Firestore.
final customerCompletedOrdersProvider =
    Provider<AsyncValue<List<Order>>>((ref) {
  return ref.watch(customerOrdersProvider).whenData(
        (orders) => orders.where((o) => o.isCompleted).toList(),
      );
});

/// Cancelled orders for the current user from Firestore.
final customerCancelledOrdersProvider =
    Provider<AsyncValue<List<Order>>>((ref) {
  return ref.watch(customerOrdersProvider).whenData(
        (orders) => orders.where((o) => o.isCancelled).toList(),
      );
});
