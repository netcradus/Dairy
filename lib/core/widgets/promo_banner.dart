import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../models/banner_item.dart';
import 'category_image.dart';

// ---------------------------------------------------------------------------
// HeroBannerCarousel — Auto-scrolling PageView with animated dot indicators
// ---------------------------------------------------------------------------

/// Full-featured auto-scrolling hero banner carousel with pagination dots.
class HeroBannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;
  final VoidCallback? onTap;
  final Duration autoScrollInterval;

  const HeroBannerCarousel({
    super.key,
    required this.banners,
    this.onTap,
    this.autoScrollInterval = const Duration(seconds: 3),
  });

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.banners.length <= 1) return;
    _timer = Timer.periodic(widget.autoScrollInterval, (_) {
      if (!mounted) return;
      final next = (_currentIndex + 1) % widget.banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Banner PageView
        SizedBox(
          height: 182,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return Padding(
                // Small horizontal gap between slides for visual separation
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: PromoBanner(
                  banner: widget.banners[index],
                  onTap: widget.onTap,
                ),
              );
            },
          ),
        ),

        // Dot Indicators (only when multiple banners)
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (index) {
              final isActive = index == _currentIndex;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryBlue : AppColors.border,
                    borderRadius: AppSizes.borderSmall,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PromoBanner — Individual hero banner card (used inside carousel)
// ---------------------------------------------------------------------------

/// Hero Promotional Banner Card Component (used standalone or inside carousel).
class PromoBanner extends StatelessWidget {
  final BannerItem banner;
  final VoidCallback? onTap;

  const PromoBanner({
    super.key,
    required this.banner,
    this.onTap,
  });

  Color get _gradientStart {
    switch (banner.id) {
      case 'b2':
        return const Color(0xFF0B6E4F);
      case 'b3':
        return const Color(0xFF7C3500);
      default:
        return const Color(0xFF0F439B);
    }
  }

  Color get _gradientEnd {
    switch (banner.id) {
      case 'b2':
        return const Color(0xFF10B981);
      case 'b3':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.secondaryBlue;
    }
  }

  String get _bannerImage {
    switch (banner.id) {
      case 'b2':
        return AppAssets.paneerPlaceholder;
      case 'b3':
        return AppAssets.gheePlaceholder;
      default: // b1 — milk
        return AppAssets.milkPng;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppSizes.borderXLarge,
        gradient: LinearGradient(
          colors: [
            _gradientStart,
            AppColors.primaryBlue.withValues(alpha: banner.id == 'b1' ? 1 : 0),
            _gradientEnd
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _gradientStart.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.loose,
        clipBehavior: Clip.antiAlias,
        children: [
          // Decorative background circles
          Positioned(
            right: -24,
            bottom: -36,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p24, vertical: AppSizes.p20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tag Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppSizes.borderSmall,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          banner.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        banner.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        banner.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // CTA Button
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _gradientStart,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppSizes.borderMedium,
                            ),
                          ),
                          child: Text(
                            banner.buttonText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right Illustration Circle
                Container(
                  height: 86,
                  width: 86,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CategoryImage(
                      imageUrl: _bannerImage,
                      size: 52,
                      radius: 26,
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
