import 'address.dart';
import 'cart_item.dart';

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing Fresh';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

/// Order Model for Sawariya Dairy Phase 7
class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final Address deliveryAddress;
  final String paymentMethod;
  final String estimatedDeliveryTime;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    this.deliveryCharge = 0.0,
    this.discount = 0.0,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.deliveryAddress,
    this.paymentMethod = 'Cash on Delivery',
    this.estimatedDeliveryTime = 'Today by 7:30 AM',
  });

  bool get isUpcoming =>
      status == OrderStatus.placed ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.preparing ||
      status == OrderStatus.outForDelivery;

  bool get isCompleted => status == OrderStatus.delivered;

  bool get isCancelled => status == OrderStatus.cancelled;

  bool get canCancel =>
      status == OrderStatus.placed || status == OrderStatus.confirmed;

  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryCharge,
    double? discount,
    double? totalAmount,
    OrderStatus? status,
    DateTime? orderDate,
    Address? deliveryAddress,
    String? paymentMethod,
    String? estimatedDeliveryTime,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
    );
  }
}
