import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../models/product.dart';
import 'price_text.dart';
import 'quantity_selector.dart';
import 'product_image.dart';

/// Fresh Deals Special Card Widget — horizontal layout with product
/// image, deal badge, title, unit, price, and quantity controls.
class DealCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTap;

  const DealCard({
    super.key,
    required this.product,
    this.quantity = 0,
    this.onIncrement,
    this.onDecrement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderLarge,
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSizes.borderLarge,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Image
              Stack(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: ProductImage(
                      imageUrl: product.imageUrl,
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.saleRed,
                          borderRadius: AppSizes.borderSmall,
                        ),
                        child: Text(
                          '${product.discountPercentage}% OFF',
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSizes.p12),

              // Right Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: AppSizes.borderSmall,
                      ),
                      child: const Text(
                        'TODAY\'S DEAL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      product.unit,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PriceText(
                          price: product.price,
                          originalPrice: product.originalPrice,
                          priceFontSize: 14,
                        ),
                        QuantitySelector(
                          quantity: quantity,
                          onIncrement: onIncrement ?? () {},
                          onDecrement: onDecrement ?? () {},
                          height: 30,
                          width: 74,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
