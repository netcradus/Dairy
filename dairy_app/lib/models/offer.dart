import 'package:flutter/material.dart';

/// Offer Model for Sawariya Dairy
class Offer {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountAmount;
  final bool isPercentage;
  final DateTime expiryDate;

  const Offer({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountAmount,
    this.isPercentage = false,
    required this.expiryDate,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  String get discountDisplay => isPercentage
      ? '$discountAmount% OFF'
      : '₹${discountAmount.toStringAsFixed(0)} OFF';

  Color get iconBackgroundColor {
    if (isExpired) return const Color(0xFFF1F5F9);
    if (isPercentage) return const Color(0xFFEEF7FF);
    return const Color(0xFFF0FDF4);
  }

  Color get iconColor {
    if (isExpired) return const Color(0xFF98A2B3);
    if (isPercentage) return const Color(0xFF0284C7);
    return const Color(0xFF10B981);
  }
}
