import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive.dart';
import '../../providers/onboarding_provider.dart';

/// Data Model for Onboarding Page Content
class OnboardingData {
  final String title;
  final String description;
  final String imageAsset;
  final bool showProductGrid;
  final Widget visualWidget;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.imageAsset,
    this.showProductGrid = false,
    required this.visualWidget,
  });
}

/// Responsive Luxury Onboarding / Landing Experience for Sawariya Dairy
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final service = ref.read(onboardingServiceProvider);
    await service.setOnboardingCompleted(true);
    if (!mounted) return;
    context.go('/login');
  }

  void _nextPage() {
    if (_currentPage < 2) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      } else {
        setState(() => _currentPage++);
      }
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final size = MediaQuery.of(context).size;

    final List<OnboardingData> pages = [
      const OnboardingData(
        title: 'Fresh Dairy, Every Day',
        description:
            'Enjoy fresh and quality dairy products delivered with care from Sawariya Dairy.',
        imageAsset: AppAssets.landingHeroMilk,
        showProductGrid: false,
        visualWidget: _DairyFreshVisual(),
      ),
      const OnboardingData(
        title: 'Pure Products, Trusted Quality',
        description:
            'Every product is sourced fresh, hygienically packed and quality-checked to bring you the best of Sawariya Dairy.',
        imageAsset: AppAssets.landingHeroProducts,
        showProductGrid: true,
        visualWidget: _DairyCollectionVisual(),
      ),
      const OnboardingData(
        title: 'Simple Shopping, Fresh Delivery',
        description:
            'Discover your favorite dairy products, order easily and enjoy freshness at your doorstep.',
        imageAsset: AppAssets.landingHeroScooter,
        showProductGrid: false,
        visualWidget: _DairyDeliveryVisual(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1B3B22),
      body: Stack(
        children: [
          // 1. Full-screen Lush Green Meadow Background
          Positioned.fill(
            child: Image.asset(
              AppAssets.landingBg,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Ambient Background Blur & Light Softening Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.10),
              ),
            ),
          ),

          // 2. Central Gold-Bordered Landing Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40.0 : 16.0,
                    vertical: isDesktop ? 32.0 : 16.0,
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 980,
                      maxHeight: isDesktop ? 580 : size.height * 0.90,
                    ),
                    // Outer Metallic Gold Gradient Frame
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF5E4B5),
                          Color(0xFFD4AF37),
                          Color(0xFF997A26),
                          Color(0xFFF5E4B5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 36,
                          spreadRadius: 2,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2.5), // Gold Border Thickness
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8F5), // Off-white / Cream
                        borderRadius: BorderRadius.circular(25.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.5),
                        child: isDesktop
                            ? _buildDesktopSplitLayout(context, pages)
                            : _buildMobileLayout(context, pages),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop Viewport Layout: Side-by-side Split View
  Widget _buildDesktopSplitLayout(
      BuildContext context, List<OnboardingData> pages) {
    final page = pages[_currentPage];

    return Row(
      children: [
        // Left Half: High Resolution Looping Hero Pane (4:5 full ratio)
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.white,
            child: Center(
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      key: ValueKey<String>(page.imageAsset),
                      page.imageAsset,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_outlined,
                            color: Color(0xFFD4AF37), size: 48),
                      ),
                    ),
                    // Soft edge gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.12),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right Half: Brand Header, Content PageView, Sub-Card & Navigation Controls
        Expanded(
          flex: 5,
          child: Container(
            color: const Color(0xFFFAF8F5),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar: Logo & Skip Action
                _buildTopHeader(),

                // Middle: Animated Content View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final item = pages[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF132238),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.description,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF4A5568),
                              height: 1.55,
                            ),
                          ),

                          // Slide 2 Special Sub-Card with 4 Product Icons
                          if (item.showProductGrid) ...[
                            const SizedBox(height: 20),
                            _buildProductIconsSubCard(),
                          ],
                        ],
                      );
                    },
                  ),
                ),

                // Bottom Controls: Gold Page Indicators & Navy Button
                _buildBottomControls(pages.length),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile Viewport Layout: Stacked Top Visual & Bottom Content Card
  Widget _buildMobileLayout(
      BuildContext context, List<OnboardingData> pages) {
    final page = pages[_currentPage];

    return Column(
      children: [
        // Top Half: Visual Header Pane (4:5 full ratio)
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.white,
            child: Center(
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      key: ValueKey<String>(page.imageAsset),
                      page.imageAsset,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_outlined,
                            color: Color(0xFFD4AF37), size: 48),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.08),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom Half: Content Pane
        Expanded(
          flex: 5,
          child: Container(
            color: const Color(0xFFFAF8F5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopHeader(),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final item = pages[index];
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF132238),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4A5568),
                                height: 1.45,
                              ),
                            ),

                            if (item.showProductGrid) ...[
                              const SizedBox(height: 14),
                              _buildProductIconsSubCard(),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

                _buildBottomControls(pages.length),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Slide 2 Sub-Card with 4 Product Icons (Paneer, Curd, Ghee, Butter)
  Widget _buildProductIconsSubCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC5A059).withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ProductSubItem(
            icon: Icons.soup_kitchen_rounded,
            label: 'Paneer',
          ),
          _ProductSubItem(
            icon: Icons.rice_bowl_rounded,
            label: 'Curd',
          ),
          _ProductSubItem(
            icon: Icons.local_cafe_rounded,
            label: 'Ghee',
          ),
          _ProductSubItem(
            icon: Icons.bakery_dining_rounded,
            label: 'Butter',
          ),
        ],
      ),
    );
  }

  /// Brand Header Widget with Cow Emoji & Skip Button
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/icon.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Sawariya Dairy',
              style: GoogleFonts.playfairDisplay(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1810),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),

        InkWell(
          onTap: _completeOnboarding,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF556070),
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF556070),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom Controls: Warm Golden Page Indicators & Gold-Trimmed Navy Button
  Widget _buildBottomControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 3D Dot Indicators matching the reference images
        Row(
          children: List.generate(
            totalPages,
            (index) => _buildCustomPageDot(index),
          ),
        ),

        // Action Button ("Next" or "Get Started")
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF5E4B5),
                Color(0xFFC5A059),
                Color(0xFF8C6D2B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF152642).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(1.8), // Gold Double Outline
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _nextPage,
              borderRadius: BorderRadius.circular(28),
              child: Ink(
                decoration: BoxDecoration(
                  color: const Color(0xFF152642), // Dark Navy Blue
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 13,
                ),
                child: Text(
                  _currentPage == totalPages - 1 ? 'Get Started' : 'Next',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF5E4B5), // Champagne Gold text
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Custom Page Indicator Dot matching exact styling from images
  Widget _buildCustomPageDot(int index) {
    final isSelected = _currentPage == index;

    if (index == 2 && isSelected) {
      // Slide 3 Indicator: Silver/Gold capsule pill
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 10),
        height: 10,
        width: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
            colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF64748B)],
          ),
        ),
      );
    } else if (index == 1 && isSelected) {
      // Slide 2 Indicator: Steel Blue Sphere
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 10),
        height: 10,
        width: 10,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Color(0xFF1C355E),
        ),
      );
    }

    // Default Gold Sphere / Capsule
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 10),
      height: 10,
      width: isSelected ? 22 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: isSelected
            ? const LinearGradient(
                colors: [
                  Color(0xFFF5E4B5),
                  Color(0xFFD4AF37),
                  Color(0xFF997A26),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : const Color(0xFFC5A059).withValues(alpha: 0.4),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

/// Helper Widget for Slide 2 Sub-Card Items
class _ProductSubItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProductSubItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: const Color(0xFF1E3A8A)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FALLBACK VISUAL ILLUSTRATION WIDGETS
// ============================================================================

class _DairyFreshVisual extends StatelessWidget {
  const _DairyFreshVisual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo(1).png',
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.local_drink_rounded,
              size: 80,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '100% PURE MILK',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC5A059),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DairyCollectionVisual extends StatelessWidget {
  const _DairyCollectionVisual();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.set_meal_rounded, size: 80, color: AppColors.primaryBlue),
          SizedBox(height: 12),
          Text(
            'PURE DAIRY PRODUCTS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC5A059),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DairyDeliveryVisual extends StatelessWidget {
  const _DairyDeliveryVisual();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining_rounded, size: 80, color: AppColors.primaryBlue),
          SizedBox(height: 12),
          Text(
            'MORNING DOORSTEP DELIVERY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC5A059),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
