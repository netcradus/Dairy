import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Product image displayed in a clean rounded container with soft
/// grey/white background so packaging graphics pop. Falls back to a
/// styled placeholder when no image is available or loading fails.
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final IconData placeholderIcon;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.contain,
    this.placeholderIcon = Icons.water_drop_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusMedium);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: radius,
      ),
      padding: const EdgeInsets.all(AppSizes.p8),
      child: ClipRRect(
        borderRadius: radius,
        child: imageUrl.isEmpty
            ? _placeholder()
            : Image.network(
                imageUrl,
                fit: fit,
                width: width,
                height: height,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _placeholder();
                },
                errorBuilder: (context, error, stack) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Icon(
          placeholderIcon,
          color: AppColors.primaryBlue.withValues(alpha: 0.4),
          size: 36,
        ),
      ),
    );
  }
}
