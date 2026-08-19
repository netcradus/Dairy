enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class DairyOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String itemsSummary;
  final double amount;
  final OrderStatus status;
  final String deliverySlot;
  final String address;
  final String time;
  final String paymentMode;

  const DairyOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.itemsSummary,
    required this.amount,
    required this.status,
    required this.deliverySlot,
    required this.address,
    required this.time,
    required this.paymentMode,
  });

  DairyOrder copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? itemsSummary,
    double? amount,
    OrderStatus? status,
    String? deliverySlot,
    String? address,
    String? time,
    String? paymentMode,
  }) {
    return DairyOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      itemsSummary: itemsSummary ?? this.itemsSummary,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      address: address ?? this.address,
      time: time ?? this.time,
      paymentMode: paymentMode ?? this.paymentMode,
    );
  }
}
