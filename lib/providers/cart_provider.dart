import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Cart State Notifier managing full CartItems map (productId -> CartItem)
///
/// On construction the notifier asynchronously restores any previously persisted
/// cart from [SharedPreferences].  A [_isRestoring] guard prevents the initial
/// empty state (`{}`) from overwriting saved data before restoration completes
/// and avoids restore/save loops.
class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  static const String _storageKey = 'cart_items';

  /// While true the notifier is still loading persisted data.
  /// All mutation methods skip persistence until this flips to false.
  bool _isRestoring = true;

  CartNotifier() : super({}) {
    unawaited(_restoreCart());
  }

  // ─── Restore ────────────────────────────────────────────────────────────

  Future<void> _restoreCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final items = CartItem.listFromJson(jsonStr);
        final map = <String, CartItem>{};
        for (final item in items) {
          map[item.product.id] = item;
        }
        // Guard: _isRestoring is still true, so _persist() will skip.
        state = map;
      }
    } catch (_) {
      // Silently fall back to an empty cart on any deserialization error.
    }
    _isRestoring = false;
  }

  // ─── Mutations ──────────────────────────────────────────────────────────

  /// Add a product or increase quantity
  void addItem(Product product, [int qty = 1]) {
    final existing = state[product.id];
    if (existing != null) {
      state = {
        ...state,
        product.id: existing.copyWith(quantity: existing.quantity + qty),
      };
    } else {
      state = {
        ...state,
        product.id: CartItem(product: product, quantity: qty),
      };
    }
    _persist();
  }

  /// Remove item entirely
  void removeItem(String productId) {
    final newState = Map<String, CartItem>.from(state);
    newState.remove(productId);
    state = newState;
    _persist();
  }

  /// Increment quantity of existing product
  void increment(Product product) {
    addItem(product, 1);
  }

  /// Decrement quantity or remove if quantity reaches 0
  void decrement(String productId) {
    final existing = state[productId];
    if (existing == null) return;

    if (existing.quantity <= 1) {
      removeItem(productId);
    } else {
      state = {
        ...state,
        productId: existing.copyWith(quantity: existing.quantity - 1),
      };
      _persist();
    }
  }

  /// Clear all items in cart
  void clearCart() {
    state = {};
    _persist();
  }

  // ─── Persistence ────────────────────────────────────────────────────────

  /// Persists the current cart to [SharedPreferences].
  /// Skipped while restoration is in progress to prevent the initial empty
  /// state from overwriting valid saved data.
  void _persist() {
    if (_isRestoring) return;
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = CartItem.listToJson(state.values.toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {
      // Persistence failures are non-fatal — the cart remains valid in memory.
    }
  }
}

/// Primary Cart StateProvider
final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartItem>>((ref) {
  return CartNotifier();
});

/// List of all items currently in cart
final cartItemsProvider = Provider<List<CartItem>>((ref) {
  final cartMap = ref.watch(cartProvider);
  return cartMap.values.toList();
});

/// Map of productId -> quantity (for fast lookup in ProductCard)
final cartQuantitiesProvider = Provider<Map<String, int>>((ref) {
  final cartMap = ref.watch(cartProvider);
  return cartMap.map((id, item) => MapEntry(id, item.quantity));
});

/// Total number of individual items in cart
final cartItemCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartItemsProvider);
  return cartItems.fold(0, (sum, item) => sum + item.quantity);
});

/// Subtotal of all items
final cartSubtotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartItemsProvider);
  return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
});

/// Delivery charge (fixed ₹30, free if subtotal > ₹500 or cart empty)
final cartDeliveryChargeProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal == 0) return 0.0;
  return subtotal >= 500.0 ? 0.0 : 30.0;
});

/// Discount (10% on subtotal > ₹500)
final cartDiscountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal >= 500.0) {
    return subtotal * 0.10;
  }
  return 0.0;
});

/// Grand total amount to pay
final cartGrandTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal == 0) return 0.0;
  final delivery = ref.watch(cartDeliveryChargeProvider);
  final discount = ref.watch(cartDiscountProvider);
  return (subtotal + delivery - discount).clamp(0.0, double.infinity);
});
