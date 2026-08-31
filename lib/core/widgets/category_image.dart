import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

/// Replaces the generic water-drop brand glyph with a real dairy photo.
class CategoryImage extends StatelessWidget {
  final String imageUrl;
  final String? categoryKey;
  final double size;
  final double radius;
  final BoxFit fit;
  final Color? backgroundColor;

  const CategoryImage({
    super.key,
    required this.imageUrl,
    this.categoryKey,
    this.size = 26,
    this.radius = 8,
    this.fit = BoxFit.cover,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = AppAssets.categoryImage(
          imageUrl: imageUrl,
          categoryKey: categoryKey,
        ) ??
        '';
    final isNetwork =
        resolved.startsWith('http://') || resolved.startsWith('https://');

    final image = isNetwork
        ? Image.network(
            resolved,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => _fallback(),
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : _fallback(),
          )
        : Image.asset(
            resolved,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => _fallback(),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: backgroundColor ?? Colors.transparent,
        child: image,
      ),
    );
  }

  Widget _fallback() => Center(
        child: Icon(
          Icons.image_outlined,
          size: size * 0.5,
          color: Colors.grey,
        ),
      );
}
