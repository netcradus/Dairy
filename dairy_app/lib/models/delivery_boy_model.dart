import 'package:flutter/material.dart';

enum DeliveryStatus {
  available,
  onDuty,
  offDuty,
  breakTime,
}

enum DeliveryOrderStatus {
  pendingAcceptance,
  accepted,
  pickup,
  outForDelivery,
  delivered,
  cancelled,
  declined;

  String get statusLabel {
    switch (this) {
      case DeliveryOrderStatus.pendingAcceptance:
        return 'Pending Acceptance';
      case DeliveryOrderStatus.accepted:
        return 'Accepted';
      case DeliveryOrderStatus.pickup:
        return 'Pickup';
      case DeliveryOrderStatus.outForDelivery:
        return 'Out for Delivery';
      case DeliveryOrderStatus.delivered:
        return 'Delivered';
      case DeliveryOrderStatus.cancelled:
        return 'Cancelled';
      case DeliveryOrderStatus.declined:
        return 'Declined';
    }
  }

  Color get statusColor {
    switch (this) {
      case DeliveryOrderStatus.pendingAcceptance:
        return const Color(0xFFF59E0B);
      case DeliveryOrderStatus.accepted:
        return const Color(0xFF3D7FE8);
      case DeliveryOrderStatus.pickup:
        return const Color(0xFFA855F7);
      case DeliveryOrderStatus.outForDelivery:
        return const Color(0xFF0284C7);
      case DeliveryOrderStatus.delivered:
        return const Color(0xFF10B981);
      case DeliveryOrderStatus.cancelled:
      case DeliveryOrderStatus.declined:
        return const Color(0xFFE53935);
    }
  }
}

enum DeliveryRequestStatus {
  pending,
  accepted,
  declined,
  expired,
}

class DeliveryAgent {
  final String id;
  final String name;
  final String phone;
  final String vehicle;
  final String vehicleNumber;
  final String assignedZone;
  final DeliveryStatus status;
  final int totalDeliveriesToday;
  final int completedDeliveriesToday;
  final double earningsToday;
  final double rating;
  final String? profileImageUrl;

  const DeliveryAgent({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.vehicleNumber,
    required this.assignedZone,
    required this.status,
    required this.totalDeliveriesToday,
    required this.completedDeliveriesToday,
    required this.earningsToday,
    required this.rating,
    this.profileImageUrl,
  });

  DeliveryAgent copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicle,
    String? vehicleNumber,
    String? assignedZone,
    DeliveryStatus? status,
    int? totalDeliveriesToday,
    int? completedDeliveriesToday,
    double? earningsToday,
    double? rating,
    String? profileImageUrl,
  }) {
    return DeliveryAgent(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicle: vehicle ?? this.vehicle,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      assignedZone: assignedZone ?? this.assignedZone,
      status: status ?? this.status,
      totalDeliveriesToday: totalDeliveriesToday ?? this.totalDeliveriesToday,
      completedDeliveriesToday: completedDeliveriesToday ?? this.completedDeliveriesToday,
      earningsToday: earningsToday ?? this.earningsToday,
      rating: rating ?? this.rating,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class DeliveryOrder {
  final String id;
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String pickupLocation;
  final String pickupPhone;
  final List<String> items;
  final double amount;
  final double deliveryFee;
  final DeliveryOrderStatus status;
  final DateTime orderTime;
  final DateTime? acceptedTime;
  final DateTime? pickupTime;
  final DateTime? deliveredTime;
  final String distance;
  final String estimatedTime;

  const DeliveryOrder({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.pickupLocation,
    required this.pickupPhone,
    required this.items,
    required this.amount,
    required this.deliveryFee,
    required this.status,
    required this.orderTime,
    this.acceptedTime,
    this.pickupTime,
    this.deliveredTime,
    required this.distance,
    required this.estimatedTime,
  });

  DeliveryOrder copyWith({
    String? id,
    String? orderId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? pickupLocation,
    String? pickupPhone,
    List<String>? items,
    double? amount,
    double? deliveryFee,
    DeliveryOrderStatus? status,
    DateTime? orderTime,
    DateTime? acceptedTime,
    DateTime? pickupTime,
    DateTime? deliveredTime,
    String? distance,
    String? estimatedTime,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      items: items ?? this.items,
      amount: amount ?? this.amount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      status: status ?? this.status,
      orderTime: orderTime ?? this.orderTime,
      acceptedTime: acceptedTime ?? this.acceptedTime,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveredTime: deliveredTime ?? this.deliveredTime,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }
}

class DeliveryRequest {
  final String id;
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String pickupLocation;
  final String pickupPhone;
  final List<String> items;
  final double amount;
  final double deliveryFee;
  final String distance;
  final String estimatedTime;
  final DateTime requestTime;
  final int countdownSeconds;
  final DeliveryRequestStatus status;

  const DeliveryRequest({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.pickupLocation,
    required this.pickupPhone,
    required this.items,
    required this.amount,
    required this.deliveryFee,
    required this.distance,
    required this.estimatedTime,
    required this.requestTime,
    required this.countdownSeconds,
    this.status = DeliveryRequestStatus.pending,
  });

  DeliveryRequest copyWith({
    String? id,
    String? orderId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? pickupLocation,
    String? pickupPhone,
    List<String>? items,
    double? amount,
    double? deliveryFee,
    String? distance,
    String? estimatedTime,
    DateTime? requestTime,
    int? countdownSeconds,
    DeliveryRequestStatus? status,
  }) {
    return DeliveryRequest(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      items: items ?? this.items,
      amount: amount ?? this.amount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      requestTime: requestTime ?? this.requestTime,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      status: status ?? this.status,
    );
  }
}

class DeliveryEarnings {
  final DateTime date;
  final double baseEarnings;
  final double tips;
  final double bonuses;
  final int deliveriesCount;
  final double total;

  const DeliveryEarnings({
    required this.date,
    required this.baseEarnings,
    required this.tips,
    required this.bonuses,
    required this.deliveriesCount,
    required this.total,
  });
}

class DeliveryHistoryItem {
  final String orderId;
  final String customerName;
  final String status;
  final double earnings;
  final DateTime date;
  final String distance;

  const DeliveryHistoryItem({
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.earnings,
    required this.date,
    required this.distance,
  });
}