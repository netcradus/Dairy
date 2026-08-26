import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/responsive/responsive.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/widgets/category_card.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/product_provider.dart';
import '../../providers/navigation_provider.dart';

/// Sawariya Dairy — Pixel-Perfect Home Screen matching attached design
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _orderIdController = TextEditingController();

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.p16),

              // ─── 2. Hero Banner (banner1v.mp4 Video Banner) ───
              _HeroPromotionalBanner(
                onTap: () => ref.read(navigationProvider.notifier).setIndex(1),
              ),

              const SizedBox(height: AppSizes.p24),

              // ─── 3. Categories Section ──────────────────────────────────────────
              SectionHeader(
                title: AppStrings.categories,
                subtitle: 'Farm fresh dairy essentials delivered daily',
                onViewAllTap: () {
                  ref.read(navigationProvider.notifier).setIndex(1);
                },
              ),
              const SizedBox(height: AppSizes.p14),

              // 5 Category Cards (Horizontal scroll or responsive row)
              SizedBox(
                height: 205,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.zero,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSizes.p14),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return CategoryCard(
                      category: cat,
                      width: isDesktop ? 195 : 170,
                      height: 205,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            cat.id;
                        ref.read(navigationProvider.notifier).setIndex(1);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSizes.p24),

              // ─── 3.5. Middle Promotional Banner (banner4 & banner5) ───────────────────
              const _CategoryPromotionalBanner(),

              const SizedBox(height: AppSizes.p24),

              // ─── 4. Bottom Split Row: Track Order & Freshness Banner ─────────────
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Track Your Order Card
                    Expanded(
                      flex: 5,
                      child: _TrackOrderCard(
                        controller: _orderIdController,
                        onTrackTap: () {
                          ref.read(navigationProvider.notifier).setIndex(2);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.p20),

                    // Right: Freshness You Can Trust Blue Banner
                    Expanded(
                      flex: 5,
                      child: _FreshnessBanner(
                        onExploreTap: () {
                          ref.read(navigationProvider.notifier).setIndex(1);
                        },
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _TrackOrderCard(
                      controller: _orderIdController,
                      onTrackTap: () {
                        ref.read(navigationProvider.notifier).setIndex(2);
                      },
                    ),
                    const SizedBox(height: AppSizes.p16),
                    _FreshnessBanner(
                      onExploreTap: () {
                        ref.read(navigationProvider.notifier).setIndex(1);
                      },
                    ),
                  ],
                ),

              const SizedBox(height: AppSizes.p24),

              // ─── Why Choose Us Banner ───
              const _WhyChooseUsVideo(),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Trust Badges Strip (4 Badges in a Row)
// ─────────────────────────────────────────────────────────────────────────────

class _TrustBadgesStrip extends StatelessWidget {
  const _TrustBadgesStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BadgeItem(
                    icon: Icons.shield_outlined,
                    iconColor: Color(0xFF1E6BFF),
                    bgColor: Color(0xFFEFF6FF),
                    title: 'FSSAI Certified',
                    subtitle: 'Safe & Certified',
                  ),
                  SizedBox(width: 16),
                  _BadgeItem(
                    icon: Icons.local_shipping_outlined,
                    iconColor: Color(0xFF10B981),
                    bgColor: Color(0xFFEDFBF5),
                    title: 'Free Delivery',
                    subtitle: 'On all orders',
                  ),
                  SizedBox(width: 16),
                  _BadgeItem(
                    icon: Icons.access_time_rounded,
                    iconColor: Color(0xFFF59E0B),
                    bgColor: Color(0xFFFFFBEB),
                    title: 'Same-Day Fresh',
                    subtitle: 'Timely & Fresh',
                  ),
                  SizedBox(width: 16),
                  _BadgeItem(
                    icon: Icons.replay_rounded,
                    iconColor: Color(0xFFEF4444),
                    bgColor: Color(0xFFFEF2F2),
                    title: 'Easy Returns',
                    subtitle: 'Hassle-free returns',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;

  const _BadgeItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Hero Promotional Banner ("Pure Goodness, Delivered to Your Doorstep")
// ─────────────────────────────────────────────────────────────────────────────

class _HeroPromotionalBanner extends StatefulWidget {
  final VoidCallback onTap;

  const _HeroPromotionalBanner({
    required this.onTap,
  });

  @override
  State<_HeroPromotionalBanner> createState() => _HeroPromotionalBannerState();
}

class _HeroPromotionalBannerState extends State<_HeroPromotionalBanner> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/banner3v.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.play();
          _controller.setVolume(0.0); // Mute
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding =
        MediaQuery.of(context).size.width >= 800 ? 24.0 : 12.0;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        constraints: const BoxConstraints(maxWidth: 1100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: widget.onTap,
              child: !_isInitialized
                  ? Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF005F38),
                        ),
                      ),
                    )
                  : VideoPlayer(_controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F3FC), Color(0xFFD5E9F9), Color(0xFFD0E8F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFC7E2F7), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Right half — meadow/nature background image
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 320,
              child: Image.asset(
                AppAssets.landingBgMeadow,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            // Soft fade from left (keeps text readable)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 280,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8F3FC), Color(0x00E8F3FC)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Top Right Stamp: FARM TO FAMILY
            Positioned(
              top: 12,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.92),
                  border: Border.all(
                    color: const Color(0xFF005F38).withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'FARM',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF005F38),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'TO',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF005F38),
                      ),
                    ),
                    Text(
                      'FAMILY',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF005F38),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(
                      Icons.eco_rounded,
                      size: 10,
                      color: Color(0xFF10B981),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Row
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Text + Feature Grid
                    Expanded(
                      flex: 55,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pure Goodness,\nDelivered to Your Doorstep',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F2F64),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Farm fresh milk & dairy products,\nhygienically packed for your family.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A5568),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Horizontal Feature Icon Row matching mockup
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              _HeroFeatureIcon(
                                icon: Icons.eco_outlined,
                                label: '100%\nPure',
                              ),
                              SizedBox(width: 14),
                              _HeroFeatureIcon(
                                icon: Icons.water_drop_outlined,
                                label: 'No Added\nPreservatives',
                              ),
                              SizedBox(width: 14),
                              _HeroFeatureIcon(
                                icon: Icons.sanitizer_outlined,
                                label: 'Hygienically\nPacked',
                              ),
                              SizedBox(width: 14),
                              _HeroFeatureIcon(
                                icon: Icons.favorite_border_rounded,
                                label: 'Trusted by\nThousands',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right: Two Milk Bottles
                    Expanded(
                      flex: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Image.asset(
                              AppAssets.milkPng,
                              height: 230,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.local_drink_rounded,
                                size: 75,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Image.asset(
                              AppAssets.lassiPng,
                              height: 230,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.local_drink_rounded,
                                size: 75,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular icon + short label below — used in the hero banner 2×2 feature grid.
class _HeroFeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroFeatureIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.82),
            border: Border.all(
              color: const Color(0xFF1E6BFF).withValues(alpha: 0.18),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF1E6BFF)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F3778),
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Track Order Card (Left bottom card)
// ─────────────────────────────────────────────────────────────────────────────

class _TrackOrderCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTrackTap;

  const _TrackOrderCard({required this.controller, required this.onTrackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E7F8), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track your order',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Real-time updates on your fresh delivery',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Input + Track Button Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 0.9,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your Order ID',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 0,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onTrackTap,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(110, 42),
                  backgroundColor: const Color(0xFF005F38),
                  foregroundColor: Colors.white,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Track Order',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Freshness You Can Trust Banner (Right bottom card)
// ─────────────────────────────────────────────────────────────────────────────

class _FreshnessBanner extends StatelessWidget {
  final VoidCallback onExploreTap;

  const _FreshnessBanner({required this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExploreTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/home.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 120,
                color: const Color(0xFF005F38),
                alignment: Alignment.center,
                child: const Text(
                  'Freshness You Can Trust',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;

  const _CheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 16,
          width: 16,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 11,
            color: Color(0xFF005F38),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Middle/Category Promotional Banner (banner4.png, banner5.png)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryPromotionalBanner extends StatefulWidget {
  const _CategoryPromotionalBanner();

  @override
  State<_CategoryPromotionalBanner> createState() =>
      _CategoryPromotionalBannerState();
}

class _CategoryPromotionalBannerState
    extends State<_CategoryPromotionalBanner> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<String> bannerImages = [
    'assets/images/banner4.png',
    'assets/images/banner5.png',
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        aspectRatio: 1764 / 608,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        enlargeCenterPage: false,
        viewportFraction: 1.0,
      ),
      items: bannerImages.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF005F38),
                      alignment: Alignment.center,
                      child: const Text(
                        'Sawariya Dairy Specials',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Why Choose Us Video Player Widget
// ─────────────────────────────────────────────────────────────────────────────

class _WhyChooseUsVideo extends StatefulWidget {
  const _WhyChooseUsVideo();

  @override
  State<_WhyChooseUsVideo> createState() => _WhyChooseUsVideoState();
}

class _WhyChooseUsVideoState extends State<_WhyChooseUsVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/whyv.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.play();
          _controller.setVolume(0.0); // Mute
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: _isInitialized ? _controller.value.aspectRatio : 16 / 9,
        child: !_isInitialized
            ? Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF005F38),
                  ),
                ),
              )
            : VideoPlayer(_controller),
      ),
    );
  }
}
