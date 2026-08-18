import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import 'address.dart';
import 'cart_item.dart';
import 'product.dart';

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

  /// Creates an [Order] from a Firestore document map.
  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    final itemsData = (data['items'] as List?) ?? [];
    final items = itemsData.map((raw) {
      final m = raw as Map<String, dynamic>;
      final product = Product(
        id: (m['productId'] as String?) ?? '',
        title: (m['title'] as String?) ?? '',
        categoryId: (m['categoryId'] as String?) ?? '',
        categoryName: (m['categoryName'] as String?) ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        unit: (m['unit'] as String?) ?? '',
        imageUrl: (m['imageUrl'] as String?) ?? '',
      );
      return CartItem(
        product: product,
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();

    final addr = data['deliveryAddress'] as Map<String, dynamic>?;
    final deliveryAddress = addr == null
        ? const Address(
            id: '',
            label: 'Home',
            fullName: 'Customer',
            mobileNumber: '',
            houseFlat: '',
            streetArea: '',
            city: '',
            state: '',
            pinCode: '',
          )
        : Address(
            id: (addr['id'] as String?) ?? '',
            label: (addr['label'] as String?) ?? 'Home',
            fullName: (addr['fullName'] as String?) ?? '',
            mobileNumber: (addr['mobileNumber'] as String?) ?? '',
            houseFlat: (addr['houseFlat'] as String?) ?? '',
            streetArea: (addr['streetArea'] as String?) ?? '',
            city: (addr['city'] as String?) ?? '',
            state: (addr['state'] as String?) ?? '',
            pinCode: (addr['pinCode'] as String?) ?? '',
            isDefault: (addr['isDefault'] as bool?) ?? false,
          );

    final created = data['createdAt'];
    final orderDate = created is Timestamp ? created.toDate() : DateTime.now();

    return Order(
      id: id,
      items: items,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (data['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: orderStatusFromString((data['status'] as String?) ?? 'Pending'),
      orderDate: orderDate,
      deliveryAddress: deliveryAddress,
      paymentMethod: (data['paymentMethod'] as String?) ?? 'Cash on Delivery',
      estimatedDeliveryTime: (data['estimatedDeliveryTime'] as String?) ?? '',
    );
  }
}

/// Maps a stored status string to an [OrderStatus].
OrderStatus orderStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
    case 'placed':
      return OrderStatus.placed;
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'preparing':
      return OrderStatus.preparing;
    case 'out for delivery':
    case 'outfordelivery':
      return OrderStatus.outForDelivery;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.placed;
  }
}

/// Maps an [OrderStatus] to the string stored in Firestore.
String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.placed:
      return 'Pending';
    case OrderStatus.confirmed:
      return 'confirmed';
    case OrderStatus.preparing:
      return 'preparing';
    case OrderStatus.outForDelivery:
      return 'outForDelivery';
    case OrderStatus.delivered:
      return 'delivered';
    case OrderStatus.cancelled:
      return 'cancelled';
  }
}
