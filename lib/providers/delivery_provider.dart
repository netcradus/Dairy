import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models/delivery_boy_model.dart';
import '../models/earning_model.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../services/delivery_tracking_service.dart';
import '../services/earnings_service.dart';
import '../services/order_service.dart';
import 'user_provider.dart';

/// Maps a Firestore [Order] into the delivery panel's [DeliveryOrder] view
/// model. Active orders from the `orders` collection don't carry an assigned
/// agent yet, so pickup defaults to the Sawariya Dairy hub.
DeliveryOrder deliveryOrderFromOrder(Order order) {
  const hub = 'Sawariya Dairy Hub, Vijay Nagar';
  const hubPhone = '+91 731 400 5000';

  DeliveryOrderStatus status = DeliveryOrderStatus.pendingAcceptance;
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
    latitude: order.deliveryAddress.latitude,
    longitude: order.deliveryAddress.longitude,
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
      .map<List<DeliveryOrder>>((List<Order> orders) =>
          orders.map<DeliveryOrder>(deliveryOrderFromOrder).toList());
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
      .map<List<DeliveryOrder>>((List<Order> orders) => orders
          .map<DeliveryOrder>(deliveryOrderFromOrder)
          .where((DeliveryOrder o) =>
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
  final User _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _subscription;

  DeliveryNotifier(this._ref, this._user) : super(_getDefaultAgent(_user)) {
    _listenToAgentDoc();
  }

  static DeliveryAgent _getDefaultAgent(User user) {
    return DeliveryAgent(
      id: user.id.isNotEmpty ? user.id : 'unknown_agent',
      name: user.name.isNotEmpty ? user.name : 'Rajesh Kumar',
      phone: user.phone.isNotEmpty ? user.phone : '+91 98765 43210',
      vehicle: 'Honda Activa',
      vehicleNumber: 'MP 09 AB 1234',
      assignedZone: 'Zone A - Vijay Nagar',
      status: DeliveryStatus.offDuty,
      totalDeliveriesToday: 0,
      completedDeliveriesToday: 0,
      earningsToday: 0.0,
      rating: 4.8,
      profileImageUrl: user.profileImageUrl,
    );
  }

  Future<void> _populateAgentProfileDoc({bool isNew = false}) async {
    if (_user.id.isEmpty) return;
    try {
      final docRef = _firestore.collection('delivery_agents').doc(_user.id);
      await docRef.set({
        'uid': _user.id,
        'name': _user.name.isNotEmpty ? _user.name : 'Rajesh Kumar',
        'phone': _user.phone.isNotEmpty ? _user.phone : '+91 7777777777',
        'email': (_user.email?.isNotEmpty ?? false)
            ? _user.email!
            : 'delivery@sawariyadairy.com',
        'vehicle': 'Honda Activa',
        'vehicleType': 'Honda Activa',
        'vehicleNumber': 'MP 09 AB 1234',
        'assignedZone': 'Zone A - Vijay Nagar',
        'profileImageUrl': _user.profileImageUrl,
        'rating': 4.8,
        if (isNew) ...{
          'isOnline': false,
          'isOnDuty': false,
          'totalDeliveriesToday': 0,
          'completedDeliveriesToday': 0,
          'earningsToday': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void _listenToAgentDoc() {
    _subscription?.cancel();
    if (_user.id.isEmpty) return;

    _subscription = _firestore
        .collection('delivery_agents')
        .doc(_user.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          // If profile fields are missing, populate them in the background
          if (data['name'] == null ||
              data['phone'] == null ||
              data['vehicle'] == null) {
            _populateAgentProfileDoc();
          }

          final isOnline = data['isOnline'] ?? data['isOnDuty'] ?? false;
          state = DeliveryAgent(
            id: _user.id,
            name: data['name'] ??
                (_user.name.isNotEmpty ? _user.name : 'Rajesh Kumar'),
            phone: data['phone'] ??
                (_user.phone.isNotEmpty ? _user.phone : '+91 98765 43210'),
            vehicle: data['vehicle'] ?? data['vehicleType'] ?? 'Honda Activa',
            vehicleNumber: data['vehicleNumber'] ?? 'MP 09 AB 1234',
            assignedZone: data['assignedZone'] ?? 'Zone A - Vijay Nagar',
            status: isOnline ? DeliveryStatus.onDuty : DeliveryStatus.offDuty,
            totalDeliveriesToday: (data['totalDeliveriesToday'] ?? 0) as int,
            completedDeliveriesToday:
                (data['completedDeliveriesToday'] ?? 0) as int,
            earningsToday: ((data['earningsToday'] ?? 0.0) as num).toDouble(),
            rating: ((data['rating'] ?? 4.8) as num).toDouble(),
            profileImageUrl: data['profileImageUrl'] ?? _user.profileImageUrl,
          );
        }
      } else {
        // Document does not exist, populate new profile doc
        _populateAgentProfileDoc(isNew: true);
      }
    }, onError: (_) {
      // Ignore background errors
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> toggleDuty() async {
    if (_user.id.isEmpty) return;

    final isOnline = state.status != DeliveryStatus.onDuty;
    final newStatus = isOnline ? DeliveryStatus.onDuty : DeliveryStatus.offDuty;

    // Optimistically update local state
    state = state.copyWith(status: newStatus);

    try {
      await _firestore.collection('delivery_agents').doc(_user.id).set({
        'isOnline': isOnline,
        'isOnDuty': isOnline,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update legacy tracking service
      await _ref
          .read(deliveryTrackingServiceProvider)
          .updateAgentOnlineStatus(_user.id, isOnline);
    } catch (_) {}
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
  final user = ref.watch(userProvider);
  return DeliveryNotifier(ref, user);
});

class DeliveryEarningsNotifier extends StateNotifier<List<DeliveryEarnings>> {
  final Ref _ref;
  StreamSubscription<List<EarningModel>>? _subscription;

  DeliveryEarningsNotifier(this._ref) : super(const []) {
    _listenToEarnings();
  }

  void _listenToEarnings() {
    _subscription?.cancel();
    final agentId = _currentAgentId;
    if (agentId.isEmpty) return;

    _subscription = _ref
        .read(earningsServiceProvider)
        .getAgentEarnings(agentId)
        .listen((earningModels) {
      state = _groupEarningsByDate(earningModels);
    }, onError: (_) {
      // Gracefully maintain state on connection error
    });
  }

  static List<DeliveryEarnings> _groupEarningsByDate(List<EarningModel> models) {
    if (models.isEmpty) return const [];

    final Map<String, List<EarningModel>> byDay = {};
    for (final m in models) {
      final d = m.timestamp;
      final dayKey =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      byDay.putIfAbsent(dayKey, () => []).add(m);
    }

    final sortedKeys = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((key) {
      final dayList = byDay[key]!;
      final date = dayList.first.timestamp;
      final base = dayList.fold(0.0, (acc, e) => acc + e.amountEarned);
      final tips = dayList.fold(0.0, (acc, e) => acc + e.tipAmount);
      final count = dayList.length;
      return DeliveryEarnings(
        date: date,
        baseEarnings: base,
        tips: tips,
        bonuses: 0.0,
        deliveriesCount: count,
        total: base + tips,
      );
    }).toList();
  }

  void addEarnings(DeliveryEarnings earnings) {
    state = [earnings, ...state.take(30)].toList();
  }

  double get todayTotal {
    final now = DateTime.now();
    for (final e in state) {
      if (e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day) {
        return e.total;
      }
    }
    return 0.0;
  }

  int get todayDeliveries {
    final now = DateTime.now();
    for (final e in state) {
      if (e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day) {
        return e.deliveriesCount;
      }
    }
    return 0;
  }

  double get weekTotal {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return state
        .where((e) => e.date.isAfter(sevenDaysAgo))
        .fold(0.0, (acc, e) => acc + e.total);
  }

  int get weekDeliveries {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return state
        .where((e) => e.date.isAfter(sevenDaysAgo))
        .fold(0, (acc, e) => acc + e.deliveriesCount);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final deliveryEarningsProvider =
    StateNotifierProvider<DeliveryEarningsNotifier, List<DeliveryEarnings>>(
        (ref) {
  return DeliveryEarningsNotifier(ref);
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
