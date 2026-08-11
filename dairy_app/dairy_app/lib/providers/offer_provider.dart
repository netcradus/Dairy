import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/offer.dart';

/// Sawariya Dairy Phase 7 — Offers StateNotifier
class OffersNotifier extends StateNotifier<List<Offer>> {
  OffersNotifier() : super(_seedOffers);

  static final List<Offer> _seedOffers = [
    Offer(
      id: 'o1',
      code: 'WELCOME10',
      title: 'Welcome to Sawariya Dairy',
      description: 'Flat 10% off on your first order. Fresh milk delivered to your door.',
      discountAmount: 10,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
    Offer(
      id: 'o2',
      code: 'FRESH50',
      title: 'Freshness Guarantee',
      description: 'Get ₹50 off on orders above ₹500. Taste the dairy difference.',
      discountAmount: 50,
      isPercentage: false,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
    ),
    Offer(
      id: 'o3',
      code: 'MILK15',
      title: 'Milk Lovers Delight',
      description: '15% off on all milk and milk product purchases this week.',
      discountAmount: 15,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
    ),
    Offer(
      id: 'o4',
      code: 'SUBSCRIBE20',
      title: 'Subscription Special',
      description: 'Save 20% on your first subscription. Set up auto-delivery.',
      discountAmount: 20,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 21)),
    ),
    Offer(
      id: 'o5',
      code: 'OLD75',
      title: 'Summer Cooler Sale',
      description: '₹75 off on summer essentials including buttermilk and lassi.',
      discountAmount: 75,
      isPercentage: false,
      expiryDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  /// Returns the active (non-expired) offer matching a coupon code, or null.
  Offer? findByCode(String code) {
    final normalized = code.trim().toUpperCase();
    final match = state.firstWhere(
      (o) => o.code == normalized,
      orElse: () => throw StateError('not found'),
    );
    return match.isExpired ? null : match;
  }
}

/// All offers.
final offersProvider =
    StateNotifierProvider<OffersNotifier, List<Offer>>((ref) {
  return OffersNotifier();
});

/// Active (non-expired) offers only.
final activeOffersProvider = Provider<List<Offer>>((ref) {
  return ref.watch(offersProvider).where((o) => !o.isExpired).toList();
});

/// Expired offers only.
final expiredOffersProvider = Provider<List<Offer>>((ref) {
  return ref.watch(offersProvider).where((o) => o.isExpired).toList();
});
