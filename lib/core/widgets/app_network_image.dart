import 'package:flutter/material.dart';
import 'web_image_stub.dart' if (dart.library.html) 'web_image_web.dart'
    as platform_impl;

/// A cross-platform network image widget that gracefully handles CORS on Web.
/// - On Mobile & Desktop: renders standard [Image.network].
/// - On Web: renders [HtmlElementView] embedding a native DOM <img> element
///   which browsers allow without CORS restrictions.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return errorBuilder?.call(context, 'Empty image URL', null) ??
          const SizedBox();
    }

    return platform_impl.createPlatformNetworkImage(
      url: trimmed,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}
