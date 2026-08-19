import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../repositories/firestore_product_repository.dart';
import '../product/product_details_screen.dart';

/// Sawariya Dairy — Redesigned Shop Catalog Screen matching the mockup
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CarouselSliderController _carouselController = CarouselSliderController();
  String _selectedCategoryId = 'cat_all';
  String _searchQuery = '';
  int _bannerIndex = 0;

  /// Live streams from Cloud Firestore, subscribed once.
  late final Stream<List<Product>> _productsStream;
  late final Stream<List<Category>> _categoriesStream;

  final List<String> _shopBanners = [
    'assets/images/shopbanner1.png',
    'assets/images/shopbanner2.png',
    'assets/images/shopbanner3.png',
  ];

  @override
  void initState() {
    super.initState();
    final repo = ref.read(firestoreProductRepoProvider);
    _productsStream = repo.streamProducts();
    _categoriesStream = repo.streamCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategoryId = 'cat_all';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartQuantities = ref.watch(cartQuantitiesProvider);

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
                            ref.read(navigationProvider.notifier).setIndex(1); // Nav to Shop / Cart
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
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
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
                    const Icon(Icons.search_rounded, color: Color(0xFF667085), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF172033)),
                        decoration: const InputDecoration(
                          hintText: 'Search for milk, paneer, ghee...',
                          hintStyle: TextStyle(color: Color(0xFF98A2B3), fontSize: 13.5),
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
                        color: isActive ? const Color(0xFF005F38) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // ── Horizontal Categories Row ──
              StreamBuilder<List<Category>>(
                stream: _categoriesStream,
                builder: (context, catSnap) {
                  final cats = <Category>[
                    const Category(id: 'cat_all', title: 'All', imageUrl: ''),
                    ...?catSnap.data,
                  ];

                  return SizedBox(
                    height: 82,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final cat = cats[index];
                        final isSelected = cat.id == _selectedCategoryId;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = cat.id;
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF005F38) : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF005F38) : const Color(0xFFCBD5E1),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: cat.id == 'cat_all'
                                      ? Text(
                                          'All',
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : const Color(0xFF005F38),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                          ),
                                        )
                                      : cat.imageUrl.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Image.asset(
                                                cat.imageUrl,
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          : Icon(
                                              cat.iconData ?? Icons.category_rounded,
                                              size: 22,
                                              color: isSelected ? Colors.white : const Color(0xFF005F38),
                                            ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.title,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF005F38) : const Color(0xFF667085),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // ── Best Sellers Title Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Best Sellers',
                    style: TextStyle(
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
              StreamBuilder<List<Product>>(
                stream: _productsStream,
                builder: (context, prodSnap) {
                  final allProducts = prodSnap.data ?? [];

                  // Filter products by category and search query
                  final filteredProducts = allProducts.where((product) {
                    final matchesCategory = _selectedCategoryId == 'cat_all' ||
                        product.categoryId == _selectedCategoryId;
                    final matchesSearch = _searchQuery.isEmpty ||
                        product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        product.categoryName.toLowerCase().contains(_searchQuery.toLowerCase());
                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (prodSnap.connectionState == ConnectionState.waiting &&
                      allProducts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (prodSnap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: EmptyStateWidget(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load products',
                        message: 'Check your connection and Firestore setup.',
                        buttonText: 'Retry',
                        onButtonPressed: _resetFilters,
                      ),
                    );
                  }

                  return filteredProducts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: EmptyStateWidget(
                              icon: Icons.search_off_rounded,
                              title: 'No products found',
                              message: 'No products match your filter. Try adjusting or reset.',
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
                                    builder: (_) => ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                              onIncrement: () {
                                ref.read(cartProvider.notifier).increment(product);
                              },
                              onDecrement: () {
                                ref.read(cartProvider.notifier).decrement(product.id);
                              },
                            );
                          },
                        );
                },
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
        aspectRatio: 1584 / 336,
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
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF005F38),
                  alignment: Alignment.center,
                  child: const Text(
                    'Sawariya Dairy',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
