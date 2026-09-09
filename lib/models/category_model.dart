import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';

class DairyCategory {
  final String id;
  final String name;
  final String description;
  final int productCount;
  final IconData icon;
  final Color color;
  final String emoji;
  final String imageUrl;

  const DairyCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.productCount,
    required this.icon,
    required this.color,
    required this.emoji,
    this.imageUrl = '',
  });

  String get resolvedImageUrl =>
      AppAssets.categoryImage(imageUrl: imageUrl, categoryKey: id) ?? '';

  DairyCategory copyWith({
    String? id,
    String? name,
    String? description,
    int? productCount,
    IconData? icon,
    Color? color,
    String? emoji,
    String? imageUrl,
  }) {
    return DairyCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productCount: productCount ?? this.productCount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class DairyPayment {
  final String id;
  final String customerName;
  final String orderOrWalletId;
  final double amount;
  final String
      method; // 'UPI', 'Razorpay', 'Cash On Delivery', 'Wallet Auto-Debit'
  final String status; // 'Success', 'Pending', 'Failed'
  final String timestamp;

  const DairyPayment({
    required this.id,
    required this.customerName,
    required this.orderOrWalletId,
    required this.amount,
    required this.method,
    required this.status,
    required this.timestamp,
  });
}
