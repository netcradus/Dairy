import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/product_provider.dart';
import '../product/product_details_screen.dart';

/// Sawariya Dairy Phase 5 & 6 — Shop Catalog Screen
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
          product.categoryName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final allCategoryOptions = [
      {'id': 'cat_all', 'title': 'All Items'},
      ...categories.map((c) => {'id': c.id, 'title': c.title}),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.p16),

              // Search Bar Header — pill-shaped
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p16,
                  vertical: AppSizes.p4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: AppSizes.borderCapsule,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary, size: 24),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
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
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    const SizedBox(width: AppSizes.p4),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.border,
                    ),
                    const SizedBox(width: AppSizes.p4),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded,
                          color: AppColors.primaryBlue, size: 22),
                      onPressed: () {},
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
                  separatorBuilder: (_, _) => const SizedBox(width: AppSizes.p8),
                  itemBuilder: (context, index) {
                    final cat = allCategoryOptions[index];
                    final isSelected = cat['id'] == _selectedCategoryId;

                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      label: Text(cat['title'] as String),
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.surface,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSizes.borderCapsule,
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
                children: [
                  Text(
                    _selectedCategoryId == 'cat_all'
                        ? 'All Fresh Dairy Products'
                        : categories
                            .firstWhere(
                                (c) => c.id == _selectedCategoryId,
                                orElse: () => categories.first)
                            .title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${filteredProducts.length} items found',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),

              // Product Grid Layout
              if (filteredProducts.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 54, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        const Text(
                          'No products match your search or filter.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedCategoryId = 'cat_all';
                            });
                          },
                          child: const Text('Reset All Filters'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.responsiveGridColumns,
                    crossAxisSpacing: AppSizes.p14,
                    mainAxisSpacing: AppSizes.p14,
                    childAspectRatio: context.isMobile ? 0.70 : 0.74,
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
                        ref
                            .read(cartProvider.notifier)
                            .increment(product);
                      },
                      onDecrement: () {
                        ref
                            .read(cartProvider.notifier)
                            .decrement(product.id);
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSizes.p24),
            ],
          ),
        ),
      ),
    );
  }
}
