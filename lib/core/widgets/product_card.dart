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
          boxShadow:
              _isHovered ? AppColors.cardShadowMd : AppColors.cardShadowSm,
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
                  fit: StackFit.loose,
                  children: [
                    Positioned.fill(
                      child: Container(
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
                          child: Padding(
                            padding: p.title.toLowerCase().contains('milk') ||
                                    p.imageUrl.toLowerCase().contains('milk')
                                ? const EdgeInsets.all(12.0)
                                : EdgeInsets.zero,
                            child: p.imageUrl.isNotEmpty
                                ? (p.imageUrl.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: p.imageUrl,
                                        fit: p.title
                                                    .toLowerCase()
                                                    .contains('milk') ||
                                                p.imageUrl
                                                    .toLowerCase()
                                                    .contains('milk')
                                            ? BoxFit.contain
                                            : BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: AppColors.lightBlue,
                                          child: const Center(
                                            child: Icon(Icons.image_outlined,
                                                size: 32,
                                                color: AppColors.primaryBlue),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: AppColors.lightBlue,
                                          child: const Center(
                                            child: Icon(Icons.image_outlined,
                                                size: 32,
                                                color: AppColors.textSecondary),
                                          ),
                                        ),
                                      )
                                    : Image.asset(
                                        p.imageUrl,
                                        fit: p.title
                                                    .toLowerCase()
                                                    .contains('milk') ||
                                                p.imageUrl
                                                    .toLowerCase()
                                                    .contains('milk')
                                            ? BoxFit.contain
                                            : BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: AppColors.lightBlue,
                                          child: const Center(
                                            child: Icon(Icons.image_outlined,
                                                size: 32,
                                                color: AppColors.textSecondary),
                                          ),
                                        ),
                                      ))
                                : Container(
                                    color: AppColors.lightBlue,
                                    child: const Center(
                                      child: Icon(Icons.image_outlined,
                                          size: 32,
                                          color: AppColors.textSecondary),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // A2 Cow Milk Badge
                    if (p.isA2CowMilk)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.freshGreen,
                            borderRadius: AppSizes.borderSmall,
                            boxShadow: AppColors.cardShadowSm,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  size: 10, color: AppColors.textOnPrimary),
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
                    // Unit Tag (pill)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: const BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: AppSizes.borderSmall,
                      ),
                      child: Text(
                        p.unit,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),

                    // Product Title
                    Text(
                      p.title.isEmpty ? 'Product' : p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),

                    // Price & Add Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: PriceText(
                            price: p.price,
                            originalPrice: p.originalPrice,
                            priceFontSize: 16,
                            originalPriceFontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (widget.quantity == 0)
                          GestureDetector(
                            onTap: widget.onIncrement,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF005F38),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          )
                        else
                          QuantitySelector(
                            quantity: widget.quantity,
                            onIncrement: widget.onIncrement ?? () {},
                            onDecrement: widget.onDecrement ?? () {},
                            height: 30,
                            width: 80,
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
