import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/widgets/category_card.dart';
import '../../core/widgets/deal_card.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/promo_banner.dart';
import '../../core/widgets/section_header.dart';
import '../../models/product.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';


/// Sawariya Dairy Phase 4 — Complete Home Discovery Screen
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroBanners = ref.watch(heroBannersProvider);
    final categories = ref.watch(categoriesProvider);
    final freshDeals = ref.watch(freshDealsProvider);
    final a2Products = ref.watch(a2ProductsProvider);
    final bestSellers = ref.watch(bestSellersProvider);
    final cartQuantities = ref.watch(cartQuantitiesProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.p16),

              // ─── Greeting Header ───────────────────────────────────────
              _buildGreetingHeader(context, user),
              const SizedBox(height: AppSizes.p16),

              // ─── Trust Badges Strip ───────────────────────────────────────
              _TrustBadgesStrip(),

              const SizedBox(height: AppSizes.p16),

              // ─── 1. Hero Promotional Banner Carousel ─────────────────────
              if (heroBanners.isNotEmpty)
                HeroBannerCarousel(
                  banners: heroBanners,
                  onTap: () {
                    ref.read(navigationProvider.notifier).setIndex(1);
                  },
                ),

              const SizedBox(height: AppSizes.p24),

              // ─── 2. Categories Section ────────────────────────────────────
              SectionHeader(
                title: AppStrings.categories,
                subtitle: 'Farm fresh dairy essentials delivered daily',
                onViewAllTap: () {
                  ref.read(navigationProvider.notifier).setIndex(1);
                },
              ),
              SizedBox(
                height: 114,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSizes.p8),
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

              // ─── 3. Fresh Deals Section (Horizontal Carousel) ─────────────
              SectionHeader(
                title: AppStrings.freshDeals,
                subtitle: 'Limited time daily fresh discounts',
                onViewAllTap: () {
                  ref.read(navigationProvider.notifier).setIndex(1);
                },
              ),
              SizedBox(
                height: 152,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: freshDeals.length,
                  itemBuilder: (context, index) {
                    final product = freshDeals[index];
                    final qty = cartQuantities[product.id] ?? 0;
                    return DealCard(
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
              ),

              const SizedBox(height: AppSizes.p24),

              // ─── 4. A2 Gir Cow Milk Promotion Section ────────────────────
              _A2MilkPromotionSection(
                products: a2Products,
                cartQuantities: cartQuantities,
                onIncrement: (p) =>
                    ref.read(cartProvider.notifier).addItem(p),
                onDecrement: (id) =>
                    ref.read(cartProvider.notifier).decrement(id),
                onShopTap: () =>
                    ref.read(navigationProvider.notifier).setIndex(1),
              ),

              const SizedBox(height: AppSizes.p24),

              // ─── 5. Best Selling Products (Responsive Grid) ───────────────
              SectionHeader(
                title: AppStrings.bestSelling,
                subtitle: 'Customer favourites & top rated dairy',
                onViewAllTap: () {
                  ref.read(navigationProvider.notifier).setIndex(1);
                },
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.responsiveGridColumns,
                  crossAxisSpacing: AppSizes.p14,
                  mainAxisSpacing: AppSizes.p14,
                  childAspectRatio: context.isMobile ? 0.70 : 0.74,
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

  Widget _buildGreetingHeader(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning 👋',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _iconButton(Icons.notifications_outlined),
              const SizedBox(width: AppSizes.p8),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lightBlue,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 20, color: AppColors.textPrimary),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trust Badges Strip
// ─────────────────────────────────────────────────────────────────────────────

class _TrustBadgesStrip extends StatelessWidget {
  static const _badges = [
    _TrustBadge(
      icon: Icons.verified_rounded,
      label: 'FSSAI Certified',
      color: Color(0xFF1455C3),
    ),
    _TrustBadge(
      icon: Icons.local_shipping_outlined,
      label: 'Free Delivery',
      color: Color(0xFF10B981),
    ),
    _TrustBadge(
      icon: Icons.schedule_rounded,
      label: 'Same-Day Fresh',
      color: Color(0xFFF59E0B),
    ),
    _TrustBadge(
      icon: Icons.replay_rounded,
      label: 'Easy Returns',
      color: Color(0xFFE53935),
    ),
  ];

  const _TrustBadgesStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: _badges.length,
        separatorBuilder: (_, _) => const SizedBox(width: 0),
        itemBuilder: (context, index) {
          final badge = _badges[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.p8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p12, vertical: AppSizes.p8),
              decoration: BoxDecoration(
                color: badge.color.withValues(alpha: 0.07),
                borderRadius: AppSizes.borderLarge,
                border: Border.all(
                    color: badge.color.withValues(alpha: 0.18), width: 1),
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
            ),
          );
        },
      ),
    );
  }
}

class _TrustBadge {
  final IconData icon;
  final String label;
  final Color color;
  const _TrustBadge(
      {required this.icon, required this.label, required this.color});
}

// ─────────────────────────────────────────────────────────────────────────────
// A2 Milk Promotion Section
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
                color: AppColors.freshGreen.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              // Text Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p8, vertical: 3),
                      decoration: BoxDecoration(
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
                    const SizedBox(height: AppSizes.p8),

                    const Text(
                      'Sawariya Pure\nA2 Gir Cow Milk',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p6),

                    const Text(
                      'Easy to digest, rich in A2 beta-casein\nprotein & natural immunity boosters.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),

                    // Feature Pills Row
                    Wrap(
                      spacing: AppSizes.p6,
                      runSpacing: AppSizes.p6,
                      children: const [
                        _A2FeaturePill(label: '✓ No Hormones'),
                        _A2FeaturePill(label: '✓ A2 Protein'),
                        _A2FeaturePill(label: '✓ Bilona Method'),
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
                          width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.verified_rounded,
                          color: AppColors.freshGreen, size: 34),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onShopTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.freshGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
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
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.freshGreen,
        ),
      ),
    );
  }
}
