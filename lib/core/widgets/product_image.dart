import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

/// Reusable Product Image Widget for Cart, Orders, Checkout & Details
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String? categoryKey;
  final String? productId;
  final String? title;
  final double size;
  final double radius;
  final BoxFit fit;
  final Color? backgroundColor;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.categoryKey,
    this.productId,
    this.title,
    this.size = 56,
    this.radius = 8,
    this.fit = BoxFit.contain,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = AppAssets.productImage(
          imageUrl: imageUrl,
          categoryKey: categoryKey,
          productId: productId,
          title: title,
        ) ??
        AppAssets.milkPng;

    final isNetwork =
        resolved.startsWith('http://') || resolved.startsWith('https://');

    final image = isNetwork
        ? Image.network(
            resolved,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => Image.asset(
              AppAssets.productImage(
                    productId: productId,
                    title: title,
                    categoryKey: categoryKey,
                  ) ??
                  AppAssets.milkPng,
              width: size,
              height: size,
              fit: fit,
            ),
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Center(
                    child: SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
          )
        : Image.asset(
            resolved,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => Image.asset(
              AppAssets.productImage(
                    productId: productId,
                    title: title,
                    categoryKey: categoryKey,
                  ) ??
                  AppAssets.milkPng,
              width: size,
              height: size,
              fit: fit,
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: backgroundColor ?? Colors.transparent,
        child: Center(child: image),
      ),
    );
  }
}
