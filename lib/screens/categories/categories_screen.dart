import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/category_model.dart';
import '../../providers/admin_provider.dart';
import '../../services/firebase_storage_service.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<Map<String, String>> _categoryPresets = [
    {'label': 'Milk', 'path': AppAssets.milkCategory},
    {'label': 'Paneer', 'path': AppAssets.paneerCategory},
    {'label': 'Ghee', 'path': AppAssets.gheeCategory},
    {'label': 'Lassi', 'path': AppAssets.lassiCategory},
    {'label': 'Makhan', 'path': AppAssets.makhanCategory},
    {'label': 'Uple', 'path': AppAssets.upleCategory},
    {'label': 'Water', 'path': AppAssets.waterCategory},
    {'label': 'All', 'path': 'assets/images/all.png'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final bgColor = AppColors.bgOf(context);

    if (provider.isLoading && provider.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Loading categories from Firestore...',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Categories',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Categorize fresh dairy items, daily morning batches, and retail dairy products.',
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
                onPressed: () => _showCategoryDialog(context, provider, null),
                icon: const Icon(Icons.add_circle_outline_rounded,
                    size: 18, color: Colors.white),
                label: Text(
                  'Add Category',
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
          provider.categories.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.category_outlined,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No categories yet.',
                          style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textMuted, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first category to organize products.',
                          style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop
                        ? 3
                        : (ResponsiveLayout.isTablet(context) ? 2 : 1),
                    mainAxisExtent: 200,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (ctx, idx) {
                    final cat = provider.categories[idx];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
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
                                  color: cat.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: cat.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: cat.imageUrl.startsWith('http')
                                            ? Image.network(
                                                cat.imageUrl,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Text(
                                                  cat.emoji,
                                                  style: const TextStyle(
                                                      fontSize: 22),
                                                ),
                                              )
                                            : Image.asset(
                                                cat.imageUrl,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Text(
                                                  cat.emoji,
                                                  style: const TextStyle(
                                                      fontSize: 22),
                                                ),
                                              ),
                                      )
                                    : Text(
                                        cat.emoji,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cardBorder),
                                ),
                                child: Text(
                                  '${cat.productCount} Products',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18, color: AppColors.primary),
                                tooltip: 'Edit Category',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                onPressed: () =>
                                    _showCategoryDialog(context, provider, cat),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 18, color: Color(0xFFEF4444)),
                                tooltip: 'Delete Category',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                onPressed: () => _showDeleteConfirmation(
                                    context, provider, cat),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cat.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              cat.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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

  void _showCategoryDialog(
      BuildContext context, AdminProvider provider, DairyCategory? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final emojiCtrl = TextEditingController(text: existing?.emoji ?? '🥛');
    final countCtrl =
        TextEditingController(text: '${existing?.productCount ?? 0}');

    showDialog(
      context: context,
      builder: (ctx) {
        String selectedImageUrl = existing?.imageUrl ?? '';
        bool isUploadingImage = false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              isEdit ? 'Update Category' : 'Add New Category',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Category Image Selector ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Category Image',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: isUploadingImage
                              ? null
                              : () async {
                                  try {
                                    final picker = ImagePicker();
                                    final picked = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      maxWidth: 1024,
                                      maxHeight: 1024,
                                      imageQuality: 85,
                                    );
                                    if (picked == null) return;

                                    setDialogState(
                                        () => isUploadingImage = true);
                                    final bytes = await picked.readAsBytes();
                                    final catId = existing?.id ??
                                        'cat_${DateTime.now().millisecondsSinceEpoch % 10000}';

                                    final downloadUrl =
                                        await FirebaseStorageService
                                            .instance
                                            .uploadCategoryImage(
                                                categoryId: catId,
                                                bytes: bytes);

                                    setDialogState(() {
                                      selectedImageUrl = downloadUrl;
                                      isUploadingImage = false;
                                    });

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Category image uploaded successfully!'),
                                          backgroundColor: AppColors.freshGreen,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setDialogState(
                                        () => isUploadingImage = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to upload image: ${e.toString().replaceAll("Exception: ", "")}',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          icon: isUploadingImage
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined,
                                  size: 16, color: AppColors.primary),
                          label: Text(
                            isUploadingImage ? 'Uploading...' : 'Upload Image',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isUploadingImage)
                      Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                                color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Uploading to Firebase Storage...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (selectedImageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: selectedImageUrl.startsWith('http')
                            ? Image.network(
                                selectedImageUrl,
                                height: 90,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 90,
                                    width: double.infinity,
                                    color: AppColors.background,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: AppColors.primary),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 90,
                                  width: double.infinity,
                                  color: AppColors.background,
                                  child: const Icon(Icons.image_not_supported,
                                      color: AppColors.textMuted),
                                ),
                              )
                            : Image.asset(
                                selectedImageUrl,
                                height: 90,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 90,
                                  width: double.infinity,
                                  color: AppColors.background,
                                  child: const Icon(Icons.image_not_supported,
                                      color: AppColors.textMuted),
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Or choose a preset default category image:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categoryPresets.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final img = _categoryPresets[index];
                          final isSelected = selectedImageUrl == img['path'];
                          return GestureDetector(
                            onTap: () => setDialogState(
                                () => selectedImageUrl = img['path']!),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.cardBorder,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(4),
                                  child: Image.asset(
                                    img['path']!,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.image,
                                                color: AppColors.textMuted),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  img['label']!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Form fields ──
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Category Name',
                          hintText: 'e.g. Milk & Creams'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Short description of products'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: emojiCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Emoji Icon',
                                hintText: '🥛, 🧀, 🍯'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: countCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Product Count'),
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
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    if (isEdit) {
                      await provider.updateCategory(
                        existing.copyWith(
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          emoji: emojiCtrl.text.trim().isEmpty
                              ? '🥛'
                              : emojiCtrl.text.trim(),
                          productCount: int.tryParse(countCtrl.text) ??
                              existing.productCount,
                          imageUrl: selectedImageUrl,
                        ),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Category "${nameCtrl.text}" updated successfully!')),
                        );
                      }
                    } else {
                      await provider.addCategory(
                        DairyCategory(
                          id: 'CAT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          productCount: int.tryParse(countCtrl.text) ?? 0,
                          icon: Icons.category_rounded,
                          color: AppColors.primary,
                          emoji: emojiCtrl.text.trim().isEmpty
                              ? '🥛'
                              : emojiCtrl.text.trim(),
                          imageUrl: selectedImageUrl,
                        ),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Category "${nameCtrl.text}" added successfully!')),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  isEdit ? 'Save Changes' : 'Create Category',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, AdminProvider provider, DairyCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(
              'Delete Category',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the category "${category.name}"? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteCategory(category.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Category "${category.name}" deleted successfully.')),
                );
              }
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
