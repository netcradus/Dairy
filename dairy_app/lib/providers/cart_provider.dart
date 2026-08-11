import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Cart State Notifier managing full CartItems map (productId -> CartItem)
class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  CartNotifier() : super({});

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
  }

  /// Remove item entirely
  void removeItem(String productId) {
    final newState = Map<String, CartItem>.from(state);
    newState.remove(productId);
    state = newState;
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
    }
  }

  /// Clear all items in cart
  void clearCart() {
    state = {};
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
