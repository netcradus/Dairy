import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/product_provider.dart';
import '../../providers/navigation_provider.dart';
import '../product/product_details_screen.dart';

/// Sawariya Dairy — Redesigned Shop Catalog Screen matching the mockup
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  String _searchQuery = '';
  int _bannerIndex = 0;

  final List<String> _shopBanners = [
    'assets/images/shop1.png',
    'assets/images/shop2.png',
    'assets/images/shop3.png',
  ];

  final CarouselSliderController _middleCarouselController =
      CarouselSliderController();
  int _middleBannerIndex = 0;

  final List<String> _middleBanners = [
    'assets/images/shopbanner1.png',
    'assets/images/shopbanner2.png',
    'assets/images/shopbanner3.png',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    ref.read(selectedCategoryProvider.notifier).state = 'cat_all';
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(allProductsProvider);
    final cartQuantities = ref.watch(cartQuantitiesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);

    // Filter products by category and search query
    final filteredProducts = allProducts.where((product) {
      bool matchesCategory = false;
      if (selectedCategoryId == 'cat_all') {
        matchesCategory = true;
      } else if (selectedCategoryId == 'cat_milk') {
        matchesCategory = product.categoryId == 'cat_milk';
      } else if (selectedCategoryId == 'cat_paneer') {
        matchesCategory = product.categoryId == 'cat_paneer' &&
            !product.title.toLowerCase().contains('butter') &&
            !product.title.toLowerCase().contains('makhan');
      } else if (selectedCategoryId == 'cat_ghee') {
        matchesCategory = product.categoryId == 'cat_ghee';
      } else if (selectedCategoryId == 'cat_lassi') {
        matchesCategory = product.categoryId == 'cat_curd' ||
            product.title.toLowerCase().contains('lassi') ||
            product.title.toLowerCase().contains('dahi');
      } else if (selectedCategoryId == 'cat_makhan') {
        matchesCategory = product.title.toLowerCase().contains('butter') ||
            product.title.toLowerCase().contains('makhan');
      } else {
        matchesCategory = product.categoryId == selectedCategoryId;
      }

      final matchesSearch = _searchQuery.isEmpty ||
          product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.categoryName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Defined Categories to match the user's requested options and logo palette
    final categoryOptions = [
      {
<<<<<<< HEAD
        'id': 'cat_all',
        'title': 'All',
        'image': '',
        'description':
            'Browse our entire range of premium, farm-fresh dairy products.'
      },
      {
        'id': 'cat_milk',
        'title': 'Milk',
        'image': 'assets/images/milk.png',
        'description': '100% pure A2 milk sourced daily from healthy cows.'
=======
        'id': 'cat_makhan',
        'title': 'Curd',
        'image': 'assets/images/makhana.png'
>>>>>>> 3fa06e8
      },
      {
        'id': 'cat_paneer',
        'title': 'Paneer',
        'image': 'assets/images/paneer.png',
        'description':
            'Ultra-soft, protein-rich fresh cottage cheese prepared daily.'
      },
      {
        'id': 'cat_ghee',
        'title': 'Ghee',
        'image': 'assets/images/ghee.png',
        'description': 'Pure Bilona cow ghee hand-churned to golden perfection.'
      },
      {
        'id': 'cat_lassi',
        'title': 'Lassi',
        'image': 'assets/images/lassi.png',
        'description': 'Thick, creamy, and refreshing probiotic sweet lassi.'
      },
      {
        'id': 'cat_makhan',
        'title': 'Makhan',
        'image': 'assets/images/makhana.png',
        'description': 'Freshly churned creamy unsalted table butter.'
      },
    ];

    // Find the currently selected category title for dynamic headers
    final selectedCat = categoryOptions.firstWhere(
      (cat) => cat['id'] == selectedCategoryId,
      orElse: () => {'id': 'cat_all', 'title': 'All'},
    );

    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Shop Title Row with Cart Icon (on Mobile/Tablet) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shop',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF005F38),
                    ),
                  ),
                  if (isMobile)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Color(0xFF172033),
                            size: 24,
                          ),
                          onPressed: () {
                            ref
                                .read(navigationProvider.notifier)
                                .setIndex(1); // Nav to Shop / Cart
                          },
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E6BFF),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Outlined Search Bar ──
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: Color(0xFF667085), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(
                            fontSize: 13.5, color: Color(0xFF172033)),
                        decoration: const InputDecoration(
                          hintText: 'Search for milk, paneer, ghee...',
                          hintStyle: TextStyle(
                              color: Color(0xFF98A2B3), fontSize: 13.5),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        color: const Color(0xFF667085),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Promotional Banner ──
              _buildPromoBanner(),
              const SizedBox(height: 8),

              // Banner Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_shopBanners.length, (index) {
                  final isActive = index == _bannerIndex;
                  return GestureDetector(
                    onTap: () {
                      _carouselController.animateToPage(index);
                      setState(() => _bannerIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: isActive ? 12 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF005F38)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // ── Horizontal Categories Row ──
              SizedBox(
                height: 125,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = categoryOptions[index];
                    final isSelected = cat['id'] == selectedCategoryId;

                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            cat['id'] as String;
                        _showCategoryPopup(context, cat);
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isSelected ? 1.08 : 0.95,
                        child: SizedBox(
                          width: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 72,
                                width: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cat['id'] == 'cat_all'
                                      ? (isSelected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.transparent)
                                      : Colors.transparent,
                                  border: cat['id'] == 'cat_all'
                                      ? Border.all(
                                          color: AppColors.primary,
                                          width:
                                              3.5, // Thick green stamp border
                                        )
                                      : (isSelected
                                          ? Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.15),
                                              width: 1.5,
                                            )
                                          : null),
                                ),
                                child: Center(
                                  child: cat['id'] == 'cat_all'
                                      ? Icon(
                                          Icons
                                              .cabin_rounded, // farm/barn-like icon
                                          color: AppColors.primary,
                                          size: 36,
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Image.asset(
                                            cat['image'] as String,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat['id'] == 'cat_all'
                                    ? 'ALL'
                                    : cat['title'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF667085),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // ── Dynamic Title Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategoryId == 'cat_all'
                        ? 'Products'
                        : '${selectedCat['title']} Products',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Products Grid ──
              filteredProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: EmptyStateWidget(
                          icon: Icons.search_off_rounded,
                          title: 'No products found',
                          message:
                              'No products match your filter. Try adjusting or reset.',
                          buttonText: 'Reset Filters',
                          onButtonPressed: _resetFilters,
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 3,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: isMobile ? 0.73 : 0.79,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final qty = cartQuantities[product.id] ?? 0;

                        return ProductCard(
                          product: product,
                          quantity: qty,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          onIncrement: () {
                            ref.read(cartProvider.notifier).increment(product);
                          },
                          onDecrement: () {
                            ref
                                .read(cartProvider.notifier)
                                .decrement(product.id);
                          },
                        );
                      },
                    ),
              const SizedBox(height: 24),

              // ── Middle Promotional Banners ──
              _buildMiddlePromoBanner(),
              const SizedBox(height: 8),

              // Middle Banner Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_middleBanners.length, (index) {
                  final isActive = index == _middleBannerIndex;
                  return GestureDetector(
                    onTap: () {
                      _middleCarouselController.animateToPage(index);
                      setState(() => _middleBannerIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: isActive ? 12 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF005F38)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // ── Bottom Benefits Strip ──
              _buildBenefitsRow(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        aspectRatio: 1792 / 592,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: false,
        onPageChanged: (index, reason) {
          setState(() {
            _bannerIndex = index;
          });
        },
      ),
      items: _shopBanners.map((imagePath) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF005F38),
                  alignment: Alignment.center,
                  child: const Text(
                    'Sawariya Dairy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiddlePromoBanner() {
    return CarouselSlider(
      carouselController: _middleCarouselController,
      options: CarouselOptions(
        aspectRatio: 1764 / 608,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: false,
        onPageChanged: (index, reason) {
          setState(() {
            _middleBannerIndex = index;
          });
        },
      ),
      items: _middleBanners.map((imagePath) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF005F38),
                  alignment: Alignment.center,
                  child: const Text(
                    'Sawariya Dairy Special',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBenefitsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _BenefitItem(
            icon: Icons.verified_user_outlined,
            title: '100% Pure',
            subtitle: 'No Additives',
          ),
          _BenefitItem(
            icon: Icons.eco_outlined,
            title: 'Farm Fresh',
            subtitle: 'Daily Collection',
          ),
          _BenefitItem(
            icon: Icons.local_shipping_outlined,
            title: 'Safe Delivery',
            subtitle: 'Hygienic Packing',
          ),
          _BenefitItem(
            icon: Icons.payment_outlined,
            title: 'Secure Payment',
            subtitle: '100% Safe',
          ),
        ],
      ),
    );
  }

  void _showCategoryPopup(BuildContext context, Map<String, String> cat) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top header close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF667085)),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 8),
                // Category image with beautiful container background
                if (cat['image']!.isNotEmpty)
                  Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      cat['image']!,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'All',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Title
                Text(
                  cat['title']!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  cat['description']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Explore Products button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Explore Products',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF005F38), size: 16),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 7.5,
            color: Color(0xFF667085),
          ),
        ),
      ],
    );
  }
}
