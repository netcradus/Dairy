import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Quantity Selector Component (- QTY +) with blue round + / Add button.
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double height;
  final double width;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.height = 36.0,
    this.width = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: onIncrement,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
            shape: RoundedRectangleBorder(
              borderRadius: AppSizes.borderCapsule,
            ),
          ),
          child: const Icon(Icons.add, size: 20),
        ),
      );
    }

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderCapsule,
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.remove, size: 16, color: AppColors.primaryBlue),
            onPressed: onDecrement,
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
