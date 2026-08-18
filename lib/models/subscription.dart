import '../models/product.dart';

/// Subscription delivery frequency for Sawariya Dairy
enum SubscriptionFrequency {
  daily,
  alternateDay,
  weekly,
}

extension SubscriptionFrequencyExtension on SubscriptionFrequency {
  String get label {
    switch (this) {
      case SubscriptionFrequency.daily:
        return 'Daily';
      case SubscriptionFrequency.alternateDay:
        return 'Alternate Day';
      case SubscriptionFrequency.weekly:
        return 'Weekly';
    }
  }

  /// Approximate number of deliveries per month
  int get deliveriesPerMonth {
    switch (this) {
      case SubscriptionFrequency.daily:
        return 30;
      case SubscriptionFrequency.alternateDay:
        return 15;
      case SubscriptionFrequency.weekly:
        return 4;
    }
  }
}

/// Subscription status
enum SubscriptionStatus { active, paused, cancelled }

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get label {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Subscription Model for Sawariya Dairy (Phase 7)
///
/// Represents a recurring dairy product delivery tied to a base product.
class Subscription {
  final String id;
  final Product product;
  final int quantity;
  final SubscriptionFrequency frequency;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? nextDeliveryDate;
  final DateTime? endDate;
  final String deliveryTimeSlot;
  final bool includeIcePack;
  final double discountRate;

  const Subscription({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.frequency = SubscriptionFrequency.daily,
    this.status = SubscriptionStatus.active,
    required this.startDate,
    this.nextDeliveryDate,
    this.endDate,
    this.deliveryTimeSlot = 'Morning (6:00 AM - 9:00 AM)',
    this.includeIcePack = true,
    this.discountRate = 0.10,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPaused => status == SubscriptionStatus.paused;
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  /// Base price per delivery (before discount)
  double get pricePerDelivery => product.price * quantity;

  /// Discount amount per delivery
  double get discountPerDelivery => pricePerDelivery * discountRate;

  /// Price after discount per delivery
  double get priceAfterDiscountPerDelivery =>
      (pricePerDelivery - discountPerDelivery).clamp(0.0, double.infinity);

  /// Estimated monthly cost
  double get monthlyCost =>
      priceAfterDiscountPerDelivery * frequency.deliveriesPerMonth;

  Subscription copyWith({
    String? id,
    Product? product,
    int? quantity,
    SubscriptionFrequency? frequency,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? nextDeliveryDate,
    DateTime? endDate,
    String? deliveryTimeSlot,
    bool? includeIcePack,
    double? discountRate,
  }) {
    return Subscription(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      nextDeliveryDate: nextDeliveryDate ?? this.nextDeliveryDate,
      endDate: endDate ?? this.endDate,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      includeIcePack: includeIcePack ?? this.includeIcePack,
      discountRate: discountRate ?? this.discountRate,
    );
  }
}
