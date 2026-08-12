import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../models/product.dart';
import 'price_text.dart';
import 'quantity_selector.dart';

/// Production Responsive Product Card with Hover States & Quantity Controls
class ProductCard extends StatefulWidget {
  final Product product;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.quantity = 0,
    this.onIncrement,
    this.onDecrement,
    this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSizes.borderLarge,
          border: Border.all(
            color: _isHovered ? AppColors.primaryBlue : AppColors.border,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: AppSizes.borderLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Header with Discount/A2 Badges
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusLarge - 1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusLarge - 1),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: p.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.lightBlue,
                            child: const Center(
                              child: Icon(Icons.water_drop_outlined,
                                  color: AppColors.secondaryBlue, size: 32),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.lightBlue,
                            child: const Center(
                              child: Icon(Icons.opacity_rounded,
                                  color: AppColors.primaryBlue, size: 36),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Discount Tag
                    if (p.hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.discountTag,
                            borderRadius: AppSizes.borderSmall,
                          ),
                          child: Text(
                            '${p.discountPercentage}% OFF',
                            style: const TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                    // A2 Cow Milk Badge
                    if (p.isA2CowMilk)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.freshGreen,
                            borderRadius: AppSizes.borderSmall,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 10, color: AppColors.textOnPrimary),
                              SizedBox(width: 2),
                              Text(
                                'A2 PURE',
                                style: TextStyle(
                                  color: AppColors.textOnPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Info & Quantity Actions
              Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit Tag
                    Text(
                      p.unit,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Product Title
                    Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),

                    // Price & Add Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: PriceText(
                            price: p.price,
                            originalPrice: p.originalPrice,
                            priceFontSize: 15,
                            originalPriceFontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        QuantitySelector(
                          quantity: widget.quantity,
                          onIncrement: widget.onIncrement ?? () {},
                          onDecrement: widget.onDecrement ?? () {},
                          height: 32,
                          width: 85,
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
