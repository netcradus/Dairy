import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Cart State Notifier managing the full CartItems map (productId -> CartItem).
///
/// Features:
/// - Real-time two-way synchronization with Firestore subcollection: `users/{uid}/cart/{productId}`.
/// - Optimistic local updates for zero-latency UI response.
/// - Local cache fallback via [SharedPreferences] for instant startup.
/// - Account isolation: User A's cart is preserved in Firestore on logout and restored on login.
/// - Multi-device / browser-refresh persistence.
class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  static const String _storageKey = 'cart_items';
  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;

  StreamSubscription<fb.User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSubscription;
  String? _currentUid;
  bool _isRestoring = true;

  CartNotifier([FirebaseFirestore? firestore, fb.FirebaseAuth? auth])
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance,
        super({}) {
    _init();
  }

  void _init() {
    unawaited(_restoreLocalCart());
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid.isNotEmpty) {
      _currentUid = currentUser.uid;
      _listenToFirestoreCart(currentUser.uid);
    }
    _authSubscription = _auth.authStateChanges().listen((user) {
      _handleAuthChange(user);
    });
  }

  // ─── Local Restore ─────────────────────────────────────────────────────────

  Future<void> _restoreLocalCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final items = CartItem.listFromJson(jsonStr);
        final map = <String, CartItem>{};
        for (final item in items) {
          if (item.product.id.isNotEmpty) {
            map[item.product.id] = item;
          }
        }
        if (_isRestoring && state.isEmpty) {
          state = map;
        }
      }
    } catch (_) {
      // Silently fall back to empty state on deserialization error
    }
    _isRestoring = false;
  }

  // ─── Auth Lifecycle & Firestore Listener ───────────────────────────────────

  void _handleAuthChange(fb.User? user) {
    final newUid = user?.uid;
    if (newUid == _currentUid) return;

    _currentUid = newUid;
    _cartSubscription?.cancel();
    _cartSubscription = null;

    if (newUid != null && newUid.isNotEmpty) {
      _listenToFirestoreCart(newUid);
    } else {
      // User logged out: clear local memory without deleting Firestore data
      clearLocalCart();
    }
  }

  void _listenToFirestoreCart(String uid) {
    _cartSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      final Map<String, CartItem> remoteCart = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        try {
          var item = CartItem.fromMap(data);
          if (item.product.id.isEmpty) {
            item = item.copyWith(
              product: item.product.copyWith(id: doc.id),
            );
          }
          if (item.product.id.isNotEmpty) {
            remoteCart[item.product.id] = item;
          }
        } catch (e) {
          debugPrint('Warning: Failed to parse cart document ${doc.id}: $e');
        }
      }
      _isRestoring = false;
      state = remoteCart;
      _saveToPrefs();
    }, onError: (e) {
      debugPrint('Warning: Cart Firestore sync error: $e');
    });
  }

  // ─── Mutations ──────────────────────────────────────────────────────────

  /// Add a product or increase quantity
  void addItem(Product product, [int qty = 1]) {
    final existing = state[product.id];
    final newQuantity = (existing?.quantity ?? 0) + qty;

    final updatedItem = (existing != null)
        ? existing.copyWith(quantity: newQuantity)
        : CartItem(product: product, quantity: qty);

    state = {
      ...state,
      product.id: updatedItem,
    };
    _saveToPrefs();

    if (_currentUid != null && _currentUid!.isNotEmpty) {
      _syncItemToFirestore(_currentUid!, updatedItem);
    }
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
      final updatedItem = existing.copyWith(quantity: existing.quantity - 1);
      state = {
        ...state,
        productId: updatedItem,
      };
      _saveToPrefs();

      if (_currentUid != null && _currentUid!.isNotEmpty) {
        _syncItemToFirestore(_currentUid!, updatedItem);
      }
    }
  }

  /// Remove item entirely
  void removeItem(String productId) {
    final newState = Map<String, CartItem>.from(state);
    newState.remove(productId);
    state = newState;
    _saveToPrefs();

    if (_currentUid != null && _currentUid!.isNotEmpty) {
      _deleteItemFromFirestore(_currentUid!, productId);
    }
  }

  /// Clear all items in cart (used after successful checkout or when user explicitly taps Clear Cart)
  void clearCart() {
    final uidToClear = _currentUid;
    state = {};
    _saveToPrefs();

    if (uidToClear != null && uidToClear.isNotEmpty) {
      _clearFirestoreCart(uidToClear);
    }
  }

  /// Clears only local in-memory cart and cache on logout (preserves Firestore records for next login)
  void clearLocalCart() {
    state = {};
    _saveToPrefs();
  }

  // ─── Firestore Operations ────────────────────────────────────────────────

  Future<void> _syncItemToFirestore(String uid, CartItem item) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(item.product.id);

      await docRef.set({
        'productId': item.product.id,
        'quantity': item.quantity,
        'product': item.product.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Warning: Failed to sync cart item ${item.product.id} to Firestore: $e');
    }
  }

  Future<void> _deleteItemFromFirestore(String uid, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId)
          .delete();
    } catch (e) {
      debugPrint('Warning: Failed to delete cart item $productId from Firestore: $e');
    }
  }

  Future<void> _clearFirestoreCart(String uid) async {
    try {
      final collectionRef =
          _firestore.collection('users').doc(uid).collection('cart');
      final snap = await collectionRef.get();
      if (snap.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Warning: Failed to clear Firestore cart for $uid: $e');
    }
  }

  // ─── Local Persistence ────────────────────────────────────────────────────

  Future<void> _saveToPrefs() async {
    if (_isRestoring) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = CartItem.listToJson(state.values.toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cartSubscription?.cancel();
    super.dispose();
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
