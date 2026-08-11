import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/quantity_selector.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';

/// Sawariya Dairy Phase 5 & 6 — Product Details Screen
class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartQuantities = ref.watch(cartQuantitiesProvider);
    final quantity = cartQuantities[product.id] ?? 0;
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(product.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.error : AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite
                      ? 'Added ${product.title} to Favorites'
                      : 'Removed from Favorites'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalPadding,
          vertical: AppSizes.p16,
        ),
        child: ResponsiveContainer(
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Big Image Banner
                    Expanded(
                      flex: 1,
                      child: _buildImageSection(product),
                    ),
                    const SizedBox(width: AppSizes.p32),

                    // Right: Info & Actions
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderInfo(product),
                          const SizedBox(height: AppSizes.p16),
                          _buildPriceSection(product),
                          const SizedBox(height: AppSizes.p20),
                          _buildQuantityAndCart(context, ref, product, quantity),
                          const SizedBox(height: AppSizes.p24),
                          _buildFeaturesAndDescription(product),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(product),
                    const SizedBox(height: AppSizes.p20),
                    _buildHeaderInfo(product),
                    const SizedBox(height: AppSizes.p16),
                    _buildPriceSection(product),
                    const SizedBox(height: AppSizes.p20),
                    _buildQuantityAndCart(context, ref, product, quantity),
                    const SizedBox(height: AppSizes.p24),
                    _buildFeaturesAndDescription(product),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageSection(Product product) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderLarge,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Stack(
        children: [
          Center(
            child: ProductImage(
              imageUrl: product.imageUrl,
              height: 220,
              width: 220,
            ),
          ),

          // Discount Tag
          if (product.hasDiscount)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.saleRed,
                  borderRadius: AppSizes.borderSmall,
                ),
                child: Text(
                  '${product.discountPercentage}% OFF',
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // 100% Farm Fresh badge
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: AppSizes.borderSmall,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 14, color: AppColors.primaryBlue),
                    SizedBox(width: 4),
                    Text(
                      '100% Farm Fresh Guaranteed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: AppSizes.borderSmall,
          ),
          child: Text(
            product.categoryName.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 4),
            Text(
              '${product.rating}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${product.reviewCount} customer reviews)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSizes.borderSmall,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Pack: ${product.unit}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(Product product) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderMedium,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Price (Inclusive of all taxes)',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              PriceText(
                price: product.price,
                originalPrice: product.originalPrice,
                priceFontSize: 22,
              ),
            ],
          ),
          if (product.hasDiscount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.freshGreen.withValues(alpha: 0.1),
                borderRadius: AppSizes.borderSmall,
                border: Border.all(color: AppColors.freshGreen.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Save ₹${(product.originalPrice! - product.price).toStringAsFixed(0)} today!',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.freshGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndCart(
      BuildContext context, WidgetRef ref, Product product, int currentQty) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Select Quantity:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSizes.p16),
            QuantitySelector(
              quantity: currentQty > 0 ? currentQty : 1,
              onIncrement: () {
                ref.read(cartProvider.notifier).increment(product);
              },
              onDecrement: () {
                if (currentQty > 0) {
                  ref.read(cartProvider.notifier).decrement(product.id);
                }
              },
              height: 40,
              width: 110,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p16),
        Row(
          children: [
            // Add to Cart Button (solid blue capsule)
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product.title} to your Cart!'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'VIEW CART',
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CartScreen()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSizes.borderCapsule,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p12),

            // Buy Now Button (light blue outlined capsule)
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(product, 1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text(
                    'Buy Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue,
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSizes.borderCapsule,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesAndDescription(Product product) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Description & Quality Standards',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description.isNotEmpty
                ? product.description
                : 'Sawariya Dairy products are harvested and processed under strict hygienic conditions. Guaranteed 100% natural without any added preservatives or adulterants.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Quality badge pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillBadge(label: '100% Pure'),
              _pillBadge(label: 'No Preservatives'),
              _pillBadge(label: 'Farm Fresh'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillBadge({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: AppSizes.borderCapsule,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
