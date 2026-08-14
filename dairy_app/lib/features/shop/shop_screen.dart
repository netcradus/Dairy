import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/product_provider.dart';
import '../product/product_details_screen.dart';

/// Sawariya Dairy — Shop Catalog Screen
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = 'cat_all';
  String _searchQuery = '';

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
    final allProducts = ref.watch(allProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final cartQuantities = ref.watch(cartQuantitiesProvider);

    // Filter products by category and search query
    final filteredProducts = allProducts.where((product) {
      final matchesCategory = _selectedCategoryId == 'cat_all' ||
          product.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.categoryName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final allCategoryOptions = [
      {'id': 'cat_all', 'title': 'All Items'},
      ...categories.map((c) => {'id': c.id, 'title': c.title}),
    ];

    final isMobile = context.isMobile;
    final selectedTitle = _selectedCategoryId == 'cat_all'
        ? 'All Fresh Dairy Products'
        : categories
            .firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => categories.first,
            )
            .title;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Fixed header (search + filters + count) — does not scroll ──
          ResponsiveContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.p20),

                // Search Bar Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSizes.borderLarge,
                    border: Border.all(color: AppColors.border, width: 1.0),
                    boxShadow: AppColors.cardShadowSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: AppColors.primaryBlue, size: 22),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                'Search fresh milk, ghee, paneer, curd, sweets...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          color: AppColors.textSecondary,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p16),

                // Category Filter Pills/Tabs
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: allCategoryOptions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSizes.p8),
                    itemBuilder: (context, index) {
                      final cat = allCategoryOptions[index];
                      final isSelected = cat['id'] == _selectedCategoryId;

                      return FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        label: Text(cat['title'] as String),
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSizes.borderMedium,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.border,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = cat['id'] as String;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.p20),

                // Header & Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        selectedTitle,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: AppSizes.borderMedium,
                      ),
                      child: Text(
                        '${filteredProducts.length} items',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
              ],
            ),
          ),

          // ── Product grid — bounded by Expanded, scrolls on its own ──
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.p40),
                      child: EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: 'No products found',
                        message:
                            'No products match your search or filter. Try adjusting or reset to see everything.',
                        buttonText: 'Reset Filters',
                        onButtonPressed: _resetFilters,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSizes.p4,
                          right: AppSizes.p4,
                          bottom: AppSizes.p12,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: AppSizes.borderMedium,
                          ),
                          child: Text(
                            '${filteredProducts.length} items',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ResponsiveContainer(
                          child: GridView.builder(
                            padding: const EdgeInsets.only(
                              left: AppSizes.p4,
                              right: AppSizes.p4,
                              bottom: AppSizes.p40,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsiveGridColumns,
                        crossAxisSpacing: AppSizes.p16,
                        mainAxisSpacing: AppSizes.p16,
                        childAspectRatio: isMobile ? 0.72 : 0.78,
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
                            ref.read(cartProvider.notifier).decrement(product.id);
                          },
                        );
                      },
                    ),
                  ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
