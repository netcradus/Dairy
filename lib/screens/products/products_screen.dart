import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/product_model.dart';
import '../../providers/admin_provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final filteredProducts = provider.products.where((p) {
      if (provider.searchQuery.isEmpty) return true;
      final q = provider.searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dairy Products & Inventory',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Configure milk varieties, fat content, packaging, and stock levels.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showProductDialog(context, provider, null),
                icon: const Icon(Icons.add_box_rounded,
                    size: 18, color: Colors.white),
                label: Text(
                  'Add Product',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Product Grid
          filteredProducts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No products found in catalog.',
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textMuted),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop
                        ? 3
                        : (ResponsiveLayout.isTablet(context) ? 2 : 1),
                    mainAxisExtent: 230,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (ctx, idx) {
                    final product = filteredProducts[idx];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: AppColors.cardBorder),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  product.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      product.subtitle,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Edit & Delete Icons
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18, color: AppColors.primary),
                                tooltip: 'Edit Product',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 30, minHeight: 30),
                                onPressed: () => _showProductDialog(
                                    context, provider, product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 18, color: Color(0xFFEF4444)),
                                tooltip: 'Delete Product',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 30, minHeight: 30),
                                onPressed: () => _showDeleteConfirmation(
                                    context, provider, product),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildBadge(product.category, AppColors.primary),
                              const SizedBox(width: 6),
                              _buildBadge(product.fatContent,
                                  AppColors.statusPreparing),
                            ],
                          ),
                          const Spacer(),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currencyFormatter.format(product.price),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Stock: ${product.stockQuantity} ${product.unit}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    product.inStock ? 'In Stock' : 'Out',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: product.inStock
                                          ? AppColors.revenueGreen
                                          : AppColors.statusCancelled,
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: product.inStock,
                                      activeColor: AppColors.revenueGreen,
                                      activeTrackColor: AppColors.revenueGreen
                                          .withValues(alpha: 0.3),
                                      onChanged: (val) => provider
                                          .toggleProductStock(product.id),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showProductDialog(
      BuildContext context, AdminProvider provider, DairyProduct? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final subtitleCtrl = TextEditingController(text: existing?.subtitle ?? '');
    final priceCtrl = TextEditingController(
        text: existing != null ? '${existing.price.toInt()}' : '65');
    final unitCtrl = TextEditingController(text: existing?.unit ?? '1 Litre');
    final fatCtrl =
        TextEditingController(text: existing?.fatContent ?? '3.5% Fat');
    final stockCtrl =
        TextEditingController(text: '${existing?.stockQuantity ?? 100}');
    final categoryCtrl =
        TextEditingController(text: existing?.category ?? 'Milk & Creams');
    final emojiCtrl = TextEditingController(text: existing?.emoji ?? '🥛');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Dairy Product' : 'Add Dairy Product',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Product Name (e.g. Pure Cow Milk 1L)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtitleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Subtitle / Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Price (₹)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Stock Quantity'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Unit (e.g. 500ml, 1L)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Fat % (e.g. 4.5% Fat)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: categoryCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: emojiCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Emoji Icon'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                if (isEdit) {
                  provider.updateProduct(
                    existing.copyWith(
                      name: nameCtrl.text.trim(),
                      subtitle: subtitleCtrl.text.trim(),
                      price: double.tryParse(priceCtrl.text) ?? existing.price,
                      stockQuantity: int.tryParse(stockCtrl.text) ??
                          existing.stockQuantity,
                      unit: unitCtrl.text.trim(),
                      fatContent: fatCtrl.text.trim(),
                      category: categoryCtrl.text.trim(),
                      emoji: emojiCtrl.text.trim().isEmpty
                          ? '🥛'
                          : emojiCtrl.text.trim(),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Product "${nameCtrl.text}" updated successfully!')),
                  );
                } else {
                  provider.addProduct(
                    DairyProduct(
                      id: 'PRD-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      name: nameCtrl.text.trim(),
                      subtitle: subtitleCtrl.text.trim().isEmpty
                          ? fatCtrl.text.trim()
                          : subtitleCtrl.text.trim(),
                      category: categoryCtrl.text.trim().isEmpty
                          ? 'Milk & Creams'
                          : categoryCtrl.text.trim(),
                      unit: unitCtrl.text.trim().isEmpty
                          ? '1 Litre'
                          : unitCtrl.text.trim(),
                      price: double.tryParse(priceCtrl.text) ?? 60.0,
                      ordersCount: 0,
                      totalRevenue: 0.0,
                      stockQuantity: int.tryParse(stockCtrl.text) ?? 100,
                      fatContent: fatCtrl.text.trim().isEmpty
                          ? '3.5% Fat'
                          : fatCtrl.text.trim(),
                      packaging: 'Fresh Pouch',
                      emoji: emojiCtrl.text.trim().isEmpty
                          ? '🥛'
                          : emojiCtrl.text.trim(),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Product "${nameCtrl.text}" added to catalog!')),
                  );
                }
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isEdit ? 'Save Changes' : 'Add Product',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, AdminProvider provider, DairyProduct product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(
              'Delete Product',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${product.name}" from your product inventory?',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteProduct(product.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Product "${product.name}" removed.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
