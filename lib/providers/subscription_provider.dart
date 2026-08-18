import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../repositories/product_repository.dart';

/// Builds seed subscriptions from the existing product catalog (Phase 7)
List<Subscription> _buildSeedSubscriptions() {
  final repo = ProductRepository();
  final milk = repo.getFreshDeals().first;
  final a2Milk = repo.getA2MilkProducts().first;
  final ghee = repo.getFreshDeals().elementAt(1);

  final now = DateTime.now();
  DateTime nextAt(int hour, {int offsetDays = 0}) {
    return DateTime(now.year, now.month, now.day + offsetDays, hour, 0);
  }

  return [
    Subscription(
      id: 'sub_1',
      product: a2Milk,
      quantity: 2,
      frequency: SubscriptionFrequency.daily,
      status: SubscriptionStatus.active,
      startDate: now.subtract(const Duration(days: 5)),
      nextDeliveryDate: nextAt(6),
    ),
    Subscription(
      id: 'sub_2',
      product: milk,
      quantity: 1,
      frequency: SubscriptionFrequency.alternateDay,
      status: SubscriptionStatus.active,
      startDate: now.subtract(const Duration(days: 10)),
      nextDeliveryDate: nextAt(6),
    ),
    Subscription(
      id: 'sub_3',
      product: ghee,
      quantity: 1,
      frequency: SubscriptionFrequency.weekly,
      status: SubscriptionStatus.active,
      startDate: now.subtract(const Duration(days: 7)),
      nextDeliveryDate: nextAt(8, offsetDays: 1),
      deliveryTimeSlot: 'Evening (6:00 PM - 8:00 PM)',
      includeIcePack: false,
    ),
  ];
}

class SubscriptionsNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionsNotifier() : super(_buildSeedSubscriptions());

  void pause(String id) {
    state = state
        .map((s) => s.id == id
            ? s.copyWith(status: SubscriptionStatus.paused)
            : s)
        .toList();
  }

  void resume(String id) {
    state = state
        .map((s) => s.id == id
            ? s.copyWith(status: SubscriptionStatus.active)
            : s)
        .toList();
  }

  void cancel(String id) {
    state = state
        .map((s) => s.id == id
            ? s.copyWith(
                status: SubscriptionStatus.cancelled,
                endDate: DateTime.now(),
              )
            : s)
        .toList();
  }

  void updateFrequency(String id, SubscriptionFrequency frequency) {
    state = state
        .map((s) => s.id == id
            ? s.copyWith(frequency: frequency)
            : s)
        .toList();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity < 1) return;
    state = state
        .map((s) => s.id == id ? s.copyWith(quantity: quantity) : s)
        .toList();
  }

  void addSubscription(Subscription subscription) {
    state = [subscription, ...state];
  }
}

final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, List<Subscription>>(
  (ref) => SubscriptionsNotifier(),
);

final activeSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  return ref.watch(subscriptionsProvider).where((s) => s.isActive).toList();
});
