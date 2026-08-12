import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../models/banner_item.dart';

// ---------------------------------------------------------------------------
// HeroBannerCarousel — Auto-scrolling PageView with animated dot indicators
// ---------------------------------------------------------------------------

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
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              if (index >= widget.banners.length) {
                return const SizedBox.shrink();
              }

              final banner = widget.banners[index];

              return PromoBanner(
                banner: banner,
                onTap: widget.onTap,
              );
            },
          ),
        ),
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
// PromoBanner — Light blue gradient hero banner with featured product image
// ---------------------------------------------------------------------------

class PromoBanner extends StatelessWidget {
  final BannerItem banner;
  final VoidCallback? onTap;

  const PromoBanner({
    super.key,
    required this.banner,
    this.onTap,
  });

  IconData get _bannerIcon {
    switch (banner.id) {
      case 'b2':
        return Icons.kitchen_rounded;
      case 'b3':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.water_drop_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
      decoration: BoxDecoration(
        borderRadius: AppSizes.borderXLarge,
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F0FE), Color(0xFFFFFFFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
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
                          color: AppColors.lightBlue,
                          borderRadius: AppSizes.borderSmall,
                        ),
                        child: Text(
                          banner.tag,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        banner.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
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
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSizes.borderCapsule,
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

                // Right product illustration circle
                Container(
                  height: 86,
                  width: 86,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _bannerIcon,
                      color: AppColors.primaryBlue,
                      size: 44,
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