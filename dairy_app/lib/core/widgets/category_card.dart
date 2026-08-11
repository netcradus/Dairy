import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../models/category.dart';

/// Reusable Category Card Component
class CategoryCard extends StatefulWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.lightBlue : AppColors.surface,
          borderRadius: AppSizes.borderLarge,
          border: Border.all(
            color: _isHovered ? AppColors.primaryBlue : AppColors.border,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.shadow,
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: AppSizes.borderLarge,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.p12,
              horizontal: AppSizes.p8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: cat.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat.iconData ?? Icons.local_drink_rounded,
                    color: AppColors.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  cat.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
