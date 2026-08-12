import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/formatters.dart';

/// Formatted Price Text Component with optional strike-through original price
class PriceText extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final double priceFontSize;
  final double originalPriceFontSize;
  final MainAxisAlignment alignment;

  const PriceText({
    super.key,
    required this.price,
    this.originalPrice,
    this.priceFontSize = 16.0,
    this.originalPriceFontSize = 12.0,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null && originalPrice! > price;

    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          AppFormatters.formatCurrency(price),
          style: TextStyle(
            fontSize: priceFontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (hasDiscount)
          Text(
            AppFormatters.formatCurrency(originalPrice!),
            style: TextStyle(
              fontSize: originalPriceFontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}
