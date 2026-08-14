import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/widgets/category_card.dart';
import '../../core/widgets/category_image.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/promo_banner.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/product_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../models/product.dart';


/// Sawariya Dairy — Home / Dashboard Discovery Screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroBanners = ref.watch(heroBannersProvider);
    final categories = ref.watch(categoriesProvider);
    final bestSellers = ref.watch(bestSellersProvider);
    final cartQuantities = ref.watch(cartQuantitiesProvider);

    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.p20),

              // ─── Welcome Header ───────────────────────────────────────
              const _WelcomeHeader(),

              const SizedBox(height: AppSizes.p16),

              // ─── Trust Badges Strip ──────────────────────────────────
              const _TrustBadgesStrip(),

              const SizedBox(height: AppSizes.p24),

              // ─── 1. Hero Promotional Banner Carousel ─────────────────
              if (heroBanners.isNotEmpty)
                HeroBannerCarousel(
                  banners: heroBanners,
                  onTap: () {
                    ref.read(navigationProvider.notifier).setIndex(1);
                  },
                ),

              const SizedBox(height: AppSizes.p24),

              // ─── 2. Categories Section ────────────────────────────────
              SectionHeader(
                title: AppStrings.categories,
                subtitle: 'Farm fresh dairy essentials delivered daily',
                onViewAllTap: () {
                  ref.read(navigationProvider.notifier).setIndex(1);
                },
              ),
              const SizedBox(height: AppSizes.p12),
              SizedBox(
                height: 116,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSizes.p12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return CategoryCard(
                      category: cat,
                      onTap: () {
                        ref.read(navigationProvider.notifier).setIndex(1);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSizes.p24),

              // ─── 3. Track Order CTA ───────────────────────────────────
              _TrackOrderCard(
                onTrackTap: () =>
                    ref.read(navigationProvider.notifier).setIndex(2),
              ),

              const SizedBox(height: AppSizes.p24),

              // ─── 6. Best Selling Products (Responsive Grid) ───────────
              SectionHeader(
                title: AppStrings.bestSelling,
                subtitle: 'Customer favourites & top rated dairy',
                onViewAllTap: () {
                  ref.read(navigationProvider.notifier).setIndex(1);
                },
              ),
              const SizedBox(height: AppSizes.p12),

              if (bestSellers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.p40),
                  child: EmptyStateWidget(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No products yet',
                    message:
                        'Our best sellers are being restocked. Please check back soon.',
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.responsiveGridColumns,
                    crossAxisSpacing: AppSizes.p16,
                    mainAxisSpacing: AppSizes.p16,
                    childAspectRatio: isMobile ? 0.72 : 0.78,
                  ),
                  itemCount: bestSellers.length,
                  itemBuilder: (context, index) {
                    final product = bestSellers[index];
                    final qty = cartQuantities[product.id] ?? 0;
                    return ProductCard(
                      product: product,
                      quantity: qty,
                      onIncrement: () {
                        ref.read(cartProvider.notifier).addItem(product);
                      },
                      onDecrement: () {
                        ref.read(cartProvider.notifier).decrement(product.id);
                      },
                    );
                  },
                ),

              const SizedBox(height: AppSizes.p40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Welcome Header
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: AppSizes.borderMedium,
            boxShadow: AppColors.primaryShadowSm,
          ),
          child: const Center(
            child: CategoryImage(
              imageUrl: AppAssets.heroBannerPlaceholder,
              size: 32,
              radius: 10,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()},',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Fresh dairy, delivered daily',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trust Badges Strip
// ─────────────────────────────────────────────────────────────────────────────

class _TrustBadgesStrip extends StatelessWidget {
  static const List<_TrustBadge> _badges = [
    _TrustBadge(
      icon: Icons.verified_rounded,
      label: 'FSSAI Certified',
      color: AppColors.primaryBlue,
    ),
    _TrustBadge(
      icon: Icons.local_shipping_outlined,
      label: 'Free Delivery',
      color: AppColors.freshGreen,
    ),
    _TrustBadge(
      icon: Icons.schedule_rounded,
      label: 'Same-Day Fresh',
      color: AppColors.warning,
    ),
    _TrustBadge(
      icon: Icons.replay_rounded,
      label: 'Easy Returns',
      color: AppColors.error,
    ),
  ];

  const _TrustBadgesStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p12,
        vertical: AppSizes.p12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderLarge,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadowSm,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: AppSizes.p8,
        runSpacing: AppSizes.p8,
        children: _badges.map((badge) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p12,
              vertical: AppSizes.p8,
            ),
            decoration: BoxDecoration(
              color: badge.color.withValues(alpha: 0.08),
              borderRadius: AppSizes.borderMedium,
              border: Border.all(
                color: badge.color.withValues(alpha: 0.16),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badge.icon, size: 15, color: badge.color),
                const SizedBox(width: AppSizes.p6),
                Text(
                  badge.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badge.color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TrustBadge {
  final IconData icon;
  final String label;
  final Color color;
  const _TrustBadge({
    required this.icon,
    required this.label,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Track Order CTA
// ─────────────────────────────────────────────────────────────────────────────

class _TrackOrderCard extends StatelessWidget {
  final VoidCallback onTrackTap;

  const _TrackOrderCard({required this.onTrackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderLarge,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadowSm,
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.local_shipping_rounded,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.p14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track your order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Real-time updates on your fresh delivery',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          SizedBox(
            height: 40,
            width: 120,
            child: ElevatedButton(
              onPressed: onTrackTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSizes.borderMedium,
                ),
              ),
              child: const Text(
                'Track',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (End of Home screen sections)
// ─────────────────────────────────────────────────────────────────────────────


class _A2MilkPromotionSection extends StatelessWidget {
  final List<Product> products;
  final Map<String, int> cartQuantities;
  final void Function(Product p) onIncrement;
  final void Function(String id) onDecrement;
  final VoidCallback onShopTap;

  const _A2MilkPromotionSection({
    required this.products,
    required this.cartQuantities,
    required this.onIncrement,
    required this.onDecrement,
    required this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A2 Header Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.p20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F9F1), Color(0xFFF0FDF4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppSizes.borderXLarge,
            border: Border.all(
              color: AppColors.freshGreen.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: AppColors.cardShadowMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p8,
                        vertical: 3,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.freshGreen,
                        borderRadius: AppSizes.borderSmall,
                      ),
                      child: const Text(
                        '100% ORGANIC & PURE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),

                    const Text(
                      'Sawariya Pure\nA2 Gir Cow Milk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),

                    const Text(
                      'Easy to digest, rich in A2 beta-casein\nprotein & natural immunity boosters.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p14),

                    // Feature Pills Row
                    const Wrap(
                      spacing: AppSizes.p6,
                      runSpacing: AppSizes.p6,
                      children: [
                        _A2FeaturePill(label: 'No Hormones'),
                        _A2FeaturePill(label: 'A2 Protein'),
                        _A2FeaturePill(label: 'Bilona Method'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.p16),

              // Right Icon & CTA
              Column(
                children: [
                  Container(
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      color: AppColors.freshGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.freshGreen.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.verified_rounded,
                          color: AppColors.freshGreen, size: 34),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onShopTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.freshGreen,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: AppColors.freshGreen.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(
                            borderRadius: AppSizes.borderMedium),
                      ),
                      child: const Text(
                        'Shop A2',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // A2 Products Horizontal List
        if (products.isNotEmpty) ...[
          const SizedBox(height: AppSizes.p16),
          SizedBox(
            height: 258,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: products.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSizes.p12),
              itemBuilder: (context, index) {
                final product = products[index];
                final qty = cartQuantities[product.id] ?? 0;
                return SizedBox(
                  width: 172,
                  child: ProductCard(
                    product: product,
                    quantity: qty,
                    onIncrement: () => onIncrement(product),
                    onDecrement: () => onDecrement(product.id),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _A2FeaturePill extends StatelessWidget {
  final String label;
  const _A2FeaturePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.freshGreen.withValues(alpha: 0.12),
        borderRadius: AppSizes.borderSmall,
        border:
            Border.all(color: AppColors.freshGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 11, color: AppColors.freshGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.freshGreen,
            ),
          ),
        ],
      ),
    );
  }
}


