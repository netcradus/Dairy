import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../models/cart_item.dart';
import '../localization/app_language.dart';
import 'category_image.dart';
import 'price_text.dart';
import 'quantity_selector.dart';

/// Reusable Cart Item Tile for Sawariya Dairy Cart & Checkout Screens
class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final bool isCompact;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final product = cartItem.product;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderMedium,
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Thumbnail
          Container(
            width: isCompact ? 56 : 68,
            height: isCompact ? 56 : 68,
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: AppSizes.borderSmall,
            ),
            child: Center(
              child: CategoryImage(
                imageUrl: cartItem.product.imageUrl,
                size: isCompact ? 56 : 68,
                radius: AppSizes.radiusSmall,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.p12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isCompact ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                PriceText(
                  price: product.price,
                  originalPrice: product.originalPrice,
                  priceFontSize: isCompact ? 13 : 15,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSizes.p8),

          // Quantity Selector & Actions
          if (!isCompact) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: onRemove,
                  tooltip: tr('Remove'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                QuantitySelector(
                  quantity: cartItem.quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                  height: 32,
                  width: 84,
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: AppSizes.borderSmall,
              ),
              child: Text(
                '${tr('Qty')}: ${cartItem.quantity}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
