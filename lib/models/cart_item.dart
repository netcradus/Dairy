import 'dart:convert';

import 'product.dart';

/// CartItem Model for Sawariya Dairy
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() => {
        'product': product.toMap(),
        'quantity': quantity,
      };

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(
          Map<String, dynamic>.from(map['product'] as Map? ?? {})),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  static List<CartItem> listFromJson(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list
        .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static String listToJson(List<CartItem> items) {
    return jsonEncode(items.map((e) => e.toMap()).toList());
  }
}
