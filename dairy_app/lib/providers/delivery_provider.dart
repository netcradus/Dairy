import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/delivery_boy_model.dart';

class DeliveryNotifier extends StateNotifier<DeliveryAgent> {
  DeliveryNotifier() : super(_getMockAgent());

  static DeliveryAgent _getMockAgent() {
    return const DeliveryAgent(
      id: 'DEL-001',
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
    state = state.copyWith(
      status: newStatus,
      totalDeliveriesToday: newStatus == DeliveryStatus.onDuty ? 0 : state.totalDeliveriesToday,
      completedDeliveriesToday: newStatus == DeliveryStatus.onDuty ? 0 : state.completedDeliveriesToday,
      earningsToday: newStatus == DeliveryStatus.onDuty ? 0.0 : state.earningsToday,
    );
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
      completedDeliveriesToday: completedDeliveries ?? state.completedDeliveriesToday,
      earningsToday: earnings ?? state.earningsToday,
    );
  }
}

final deliveryAgentProvider = StateNotifierProvider<DeliveryNotifier, DeliveryAgent>((ref) {
  return DeliveryNotifier();
});

class DeliveryOrdersNotifier extends StateNotifier<List<DeliveryOrder>> {
  DeliveryOrdersNotifier() : super(_getMockOrders());

  static List<DeliveryOrder> _getMockOrders() {
    final now = DateTime.now();
    return [
      DeliveryOrder(
        id: 'DO-001',
        orderId: 'SD-9842',
        customerName: 'Priya Sharma',
        customerPhone: '+91 98765 43210',
        customerAddress: 'Flat 402, Sunshine Heights, MG Road, Vijay Nagar, Indore - 452010',
        pickupLocation: 'Sawariya Dairy Hub, Vijay Nagar',
        pickupPhone: '+91 731 400 5000',
        items: ['A2 Gir Cow Milk - 1L x 2', 'Fresh Paneer - 200g x 1'],
        amount: 180.0,
        deliveryFee: 30.0,
        status: DeliveryOrderStatus.pendingAcceptance,
        orderTime: now.subtract(const Duration(minutes: 5)),
        distance: '3.2 km',
        estimatedTime: '12 min',
      ),
      DeliveryOrder(
        id: 'DO-002',
        orderId: 'SD-9843',
        customerName: 'Amit Patel',
        customerPhone: '+91 98234 56789',
        customerAddress: 'Plot 15, Scheme 54, Near BRTS, Indore - 452010',
        pickupLocation: 'Sawariya Dairy Hub, Vijay Nagar',
        pickupPhone: '+91 731 400 5000',
        items: ['A2 Gir Cow Milk - 500ml x 4', 'Curd - 400g x 2'],
        amount: 220.0,
        deliveryFee: 25.0,
        status: DeliveryOrderStatus.pendingAcceptance,
        orderTime: now.subtract(const Duration(minutes: 10)),
        distance: '4.5 km',
        estimatedTime: '15 min',
      ),
    ];
  }

  void addOrder(DeliveryOrder order) {
    state = [order, ...state];
  }

  void updateOrderStatus(String orderId, DeliveryOrderStatus status) {
    state = state.map((order) {
      if (order.id == orderId) {
        final now = DateTime.now();
        return order.copyWith(
          status: status,
          acceptedTime: status == DeliveryOrderStatus.accepted ? now : order.acceptedTime,
          pickupTime: status == DeliveryOrderStatus.pickup ? now : order.pickupTime,
          deliveredTime: status == DeliveryOrderStatus.delivered ? now : order.deliveredTime,
        );
      }
      return order;
    }).toList();
  }

  void acceptOrder(String orderId) {
    updateOrderStatus(orderId, DeliveryOrderStatus.accepted);
  }

  void startPickup(String orderId) {
    updateOrderStatus(orderId, DeliveryOrderStatus.pickup);
  }

  void startDelivery(String orderId) {
    updateOrderStatus(orderId, DeliveryOrderStatus.outForDelivery);
  }

  void completeDelivery(String orderId) {
    updateOrderStatus(orderId, DeliveryOrderStatus.delivered);
  }

  void declineOrder(String orderId) {
    updateOrderStatus(orderId, DeliveryOrderStatus.declined);
  }

  List<DeliveryOrder> get activeOrders => state
      .where((o) => o.status != DeliveryOrderStatus.delivered &&
                   o.status != DeliveryOrderStatus.cancelled &&
                   o.status != DeliveryOrderStatus.declined)
      .toList();

  List<DeliveryOrder> get completedOrders => state
      .where((o) => o.status == DeliveryOrderStatus.delivered)
      .toList();

  List<DeliveryOrder> get pendingOrders => state
      .where((o) => o.status == DeliveryOrderStatus.pendingAcceptance)
      .toList();
}

final deliveryOrdersProvider = StateNotifierProvider<DeliveryOrdersNotifier, List<DeliveryOrder>>((ref) {
  return DeliveryOrdersNotifier();
});

class DeliveryRequestsNotifier extends StateNotifier<List<DeliveryRequest>> {
  Timer? _timer;
  int _countdown = 30;

  DeliveryRequestsNotifier() : super(_getMockRequests()) {
    _startTimer();
  }

  static List<DeliveryRequest> _getMockRequests() {
    final now = DateTime.now();
    return [
      DeliveryRequest(
        id: 'DR-001',
        orderId: 'SD-9845',
        customerName: 'Suresh Verma',
        customerPhone: '+91 98765 43210',
        customerAddress: '201, Galaxy Apartment, Scheme 78, Indore - 452010',
        pickupLocation: 'Sawariya Dairy Hub, Vijay Nagar',
        pickupPhone: '+91 731 400 5000',
        items: ['Full Cream Milk - 1L x 3', 'Butter - 100g x 1'],
        amount: 195.0,
        deliveryFee: 30.0,
        distance: '2.8 km',
        estimatedTime: '10 min',
        requestTime: now,
        countdownSeconds: 30,
      ),
    ];
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      state = state.map((req) {
        if (req.status == DeliveryRequestStatus.pending) {
          final newCountdown = req.countdownSeconds - 1;
          if (newCountdown <= 0) {
            return req.copyWith(
              countdownSeconds: 0,
              status: DeliveryRequestStatus.expired,
            );
          }
          return req.copyWith(countdownSeconds: newCountdown);
        }
        return req;
      }).toList();
    });
  }

  void acceptRequest(String requestId) {
    state = state.map((req) {
      if (req.id == requestId) {
        return req.copyWith(status: DeliveryRequestStatus.accepted);
      }
      return req;
    }).toList();
  }

  void declineRequest(String requestId) {
    state = state.map((req) {
      if (req.id == requestId) {
        return req.copyWith(status: DeliveryRequestStatus.declined);
      }
      return req;
    }).toList();
  }

  void removeExpiredRequests() {
    state = state.where((req) => req.status != DeliveryRequestStatus.expired).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final deliveryRequestsProvider = StateNotifierProvider<DeliveryRequestsNotifier, List<DeliveryRequest>>((ref) {
  return DeliveryRequestsNotifier();
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

final deliveryEarningsProvider = StateNotifierProvider<DeliveryEarningsNotifier, List<DeliveryEarnings>>((ref) {
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

final deliveryHistoryProvider = StateNotifierProvider<DeliveryHistoryNotifier, List<DeliveryHistoryItem>>((ref) {
  return DeliveryHistoryNotifier();
});

class DeliveryPanelTabNotifier extends StateNotifier<int> {
  DeliveryPanelTabNotifier() : super(0);

  void setTab(int index) {
    state = index;
  }
}

final deliveryPanelTabProvider = StateNotifierProvider<DeliveryPanelTabNotifier, int>((ref) {
  return DeliveryPanelTabNotifier();
});