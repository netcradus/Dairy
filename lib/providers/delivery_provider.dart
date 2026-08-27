import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/delivery_boy_model.dart';
import '../models/order.dart';
import '../services/delivery_tracking_service.dart';
import '../services/order_service.dart';

/// Maps a Firestore [Order] into the delivery panel's [DeliveryOrder] view
/// model. Active orders from the `orders` collection don't carry an assigned
/// agent yet, so pickup defaults to the Sawariya Dairy hub.
DeliveryOrder deliveryOrderFromOrder(Order order) {
  const hub = 'Sawariya Dairy Hub, Vijay Nagar';
  const hubPhone = '+91 731 400 5000';

  DeliveryOrderStatus status;
  switch (order.status) {
    case OrderStatus.placed:
      // A freshly placed order is a delivery request awaiting driver acceptance.
      status = DeliveryOrderStatus.pendingAcceptance;
    case OrderStatus.confirmed:
      status = DeliveryOrderStatus.accepted;
    case OrderStatus.preparing:
      status = DeliveryOrderStatus.pickup;
    case OrderStatus.outForDelivery:
      status = DeliveryOrderStatus.outForDelivery;
    case OrderStatus.delivered:
      status = DeliveryOrderStatus.delivered;
    case OrderStatus.cancelled:
      status = DeliveryOrderStatus.cancelled;
  }

  return DeliveryOrder(
    id: order.id,
    orderId: order.id,
    customerName: order.deliveryAddress.fullName,
    customerPhone: order.deliveryAddress.mobileNumber,
    customerAddress: order.deliveryAddress.fullAddressText,
    pickupLocation: hub,
    pickupPhone: hubPhone,
    items: order.items
        .map((ci) => '${ci.product.title} ${ci.product.unit} x${ci.quantity}')
        .toList(),
    amount: order.totalAmount,
    deliveryFee: order.deliveryCharge,
    status: status,
    orderTime: order.orderDate,
    distance: '—',
    estimatedTime: order.estimatedDeliveryTime.isNotEmpty
        ? order.estimatedDeliveryTime
        : '—',
  );
}

/// Returns the signed-in delivery agent's Firebase Auth uid, or an empty
/// string when unauthenticated (so agent-scoped streams fall back to only the
/// public pending orders).
String get _currentAgentId => FirebaseAuth.instance.currentUser?.uid ?? '';

/// Single source of truth for the delivery panel: a live Firestore stream of the
/// orders relevant to THIS agent — pending orders awaiting acceptance plus any
/// order already assigned to the agent — mapped into [DeliveryOrder]s. The
/// Requests, Active and History tabs all derive their lists from this one
/// stream.
final deliveryOrdersStreamProvider = StreamProvider<List<DeliveryOrder>>((ref) {
  final agentId = _currentAgentId;
  return ref
      .watch(orderServiceProvider)
      .streamDeliveryOrdersForAgent(agentId)
      .map((orders) => orders.map(deliveryOrderFromOrder).toList());
});

/// Live Firestore stream of the agent's active (accepted / in-progress) orders,
/// derived from the unified agent stream. Used by the Active tab and the
/// tracking map.
final deliveryActiveOrdersStreamProvider =
    StreamProvider.autoDispose<List<DeliveryOrder>>((ref) {
  final agentId = _currentAgentId;
  return ref
      .watch(orderServiceProvider)
      .streamDeliveryOrdersForAgent(agentId)
      .map((orders) => orders
          .map(deliveryOrderFromOrder)
          .where((o) =>
              o.status == DeliveryOrderStatus.accepted ||
              o.status == DeliveryOrderStatus.pickup ||
              o.status == DeliveryOrderStatus.outForDelivery)
          .toList());
});

/// Orders awaiting driver acceptance (Requests tab), derived from the unified
/// agent stream.
final deliveryRequestsStreamProvider =
    Provider.autoDispose<List<DeliveryOrder>>((ref) {
  final asyncOrders = ref.watch(deliveryOrdersStreamProvider);
  return asyncOrders.when(
    data: (orders) => orders
        .where((o) => o.status == DeliveryOrderStatus.pendingAcceptance)
        .toList(),
    loading: () => const [],
    error: (_, stackTrace) => const [],
  );
});

/// Completed / cancelled orders (History tab), derived from the unified agent
/// stream.
final deliveryHistoryStreamProvider =
    Provider.autoDispose<List<DeliveryOrder>>((ref) {
  final asyncOrders = ref.watch(deliveryOrdersStreamProvider);
  return asyncOrders.when(
    data: (orders) => orders
        .where((o) =>
            o.status == DeliveryOrderStatus.delivered ||
            o.status == DeliveryOrderStatus.cancelled)
        .toList(),
    loading: () => const [],
    error: (_, stackTrace) => const [],
  );
});

class DeliveryNotifier extends StateNotifier<DeliveryAgent> {
  final Ref _ref;

  DeliveryNotifier(this._ref) : super(_getMockAgent());

  /// Returns the signed-in delivery agent's Firebase Auth uid, falling back to a
  /// placeholder only when no user is authenticated (e.g. during local dev).
  static String get _agentId =>
      FirebaseAuth.instance.currentUser?.uid ?? 'unknown_agent';

  static DeliveryAgent _getMockAgent() {
    return DeliveryAgent(
      id: _agentId,
      name: 'Rajesh Kumar',
      phone: '+91 98765 43210',
      vehicle: 'Honda Activa',
      vehicleNumber: 'MP 09 AB 1234',
      assignedZone: 'Zone A - Vijay Nagar',
      status: DeliveryStatus.offDuty,
      totalDeliveriesToday: 0,
      completedDeliveriesToday: 0,
      earningsToday: 0.0,
      rating: 4.8,
      profileImageUrl: null,
    );
  }

  void toggleDuty() {
    final newStatus = state.status == DeliveryStatus.offDuty
        ? DeliveryStatus.onDuty
        : DeliveryStatus.offDuty;
    final isOnline = newStatus == DeliveryStatus.onDuty;
    state = state.copyWith(
      status: newStatus,
      totalDeliveriesToday:
          newStatus == DeliveryStatus.onDuty ? 0 : state.totalDeliveriesToday,
      completedDeliveriesToday: newStatus == DeliveryStatus.onDuty
          ? 0
          : state.completedDeliveriesToday,
      earningsToday:
          newStatus == DeliveryStatus.onDuty ? 0.0 : state.earningsToday,
    );
    // Persist the evaluated duty state so Firestore never keeps a stale
    // `isOnline` value (e.g. staying `true` after the agent goes offline).
    _ref
        .read(deliveryTrackingServiceProvider)
        .updateAgentOnlineStatus(state.id, isOnline);
  }

  void startBreak() {
    state = state.copyWith(status: DeliveryStatus.breakTime);
  }

  void endBreak() {
    state = state.copyWith(status: DeliveryStatus.onDuty);
  }

  void updateStats({
    int? totalDeliveries,
    int? completedDeliveries,
    double? earnings,
  }) {
    state = state.copyWith(
      totalDeliveriesToday: totalDeliveries ?? state.totalDeliveriesToday,
      completedDeliveriesToday:
          completedDeliveries ?? state.completedDeliveriesToday,
      earningsToday: earnings ?? state.earningsToday,
    );
  }
}

final deliveryAgentProvider =
    StateNotifierProvider<DeliveryNotifier, DeliveryAgent>((ref) {
  return DeliveryNotifier(ref);
});

class DeliveryEarningsNotifier extends StateNotifier<List<DeliveryEarnings>> {
  DeliveryEarningsNotifier() : super(_getMockEarnings());

  static List<DeliveryEarnings> _getMockEarnings() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final base = 200.0 + (index * 50.0);
      final tips = 20.0 + (index * 5.0);
      final bonuses = index % 3 == 0 ? 50.0 : 0.0;
      final count = 8 + index;
      return DeliveryEarnings(
        date: date,
        baseEarnings: base,
        tips: tips,
        bonuses: bonuses,
        deliveriesCount: count,
        total: base + tips + bonuses,
      );
    });
  }

  void addEarnings(DeliveryEarnings earnings) {
    state = [earnings, ...state.take(30)].toList();
  }

  double get todayTotal => state.isNotEmpty ? state.first.total : 0.0;
  int get todayDeliveries => state.isNotEmpty ? state.first.deliveriesCount : 0;
  double get weekTotal => state.fold(0.0, (sum, e) => sum + e.total);
  int get weekDeliveries => state.fold(0, (sum, e) => sum + e.deliveriesCount);
}

final deliveryEarningsProvider =
    StateNotifierProvider<DeliveryEarningsNotifier, List<DeliveryEarnings>>(
        (ref) {
  return DeliveryEarningsNotifier();
});

class DeliveryHistoryNotifier extends StateNotifier<List<DeliveryHistoryItem>> {
  DeliveryHistoryNotifier() : super(_getMockHistory());

  static List<DeliveryHistoryItem> _getMockHistory() {
    final now = DateTime.now();
    return [
      DeliveryHistoryItem(
        orderId: 'SD-9840',
        customerName: 'Rahul Singh',
        status: 'Delivered',
        earnings: 45.0,
        date: now.subtract(const Duration(hours: 2)),
        distance: '3.2 km',
      ),
      DeliveryHistoryItem(
        orderId: 'SD-9839',
        customerName: 'Meena Gupta',
        status: 'Delivered',
        earnings: 38.0,
        date: now.subtract(const Duration(hours: 4)),
        distance: '2.5 km',
      ),
      DeliveryHistoryItem(
        orderId: 'SD-9838',
        customerName: 'Vikash Kumar',
        status: 'Delivered',
        earnings: 52.0,
        date: now.subtract(const Duration(hours: 6)),
        distance: '4.1 km',
      ),
      DeliveryHistoryItem(
        orderId: 'SD-9837',
        customerName: 'Anita Devi',
        status: 'Delivered',
        earnings: 41.0,
        date: now.subtract(const Duration(days: 1)),
        distance: '3.8 km',
      ),
      DeliveryHistoryItem(
        orderId: 'SD-9836',
        customerName: 'Rohit Sharma',
        status: 'Delivered',
        earnings: 47.0,
        date: now.subtract(const Duration(days: 1, hours: 2)),
        distance: '2.9 km',
      ),
    ];
  }

  void addToHistory(DeliveryHistoryItem item) {
    state = [item, ...state];
  }
}

final deliveryHistoryProvider =
    StateNotifierProvider<DeliveryHistoryNotifier, List<DeliveryHistoryItem>>(
        (ref) {
  return DeliveryHistoryNotifier();
});

class DeliveryPanelTabNotifier extends StateNotifier<int> {
  DeliveryPanelTabNotifier() : super(0);

  void setTab(int index) {
    state = index;
  }
}

final deliveryPanelTabProvider =
    StateNotifierProvider<DeliveryPanelTabNotifier, int>((ref) {
  return DeliveryPanelTabNotifier();
});
