import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../providers/onboarding_provider.dart';

/// Data Model for Onboarding Page Content
class OnboardingData {
  final String title;
  final String description;
  final Widget visualWidget;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.visualWidget,
  });
}

/// Responsive 3-Screen Onboarding Experience for Sawariya Dairy
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
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        // Controller not yet attached — advance state directly.
        setState(() => _currentPage++);
      }
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    final List<OnboardingData> pages = [
      OnboardingData(
        title: 'Fresh Dairy, Every Day',
        description:
            'Enjoy fresh and quality dairy products delivered with care from Sawariya Dairy.',
        visualWidget: const _DairyFreshVisual(),
      ),
      OnboardingData(
        title: 'Pure Products, Trusted Quality',
        description:
            'Choose quality milk, curd, paneer, butter and cheese for your family.',
        visualWidget: const _DairyCollectionVisual(),
      ),
      OnboardingData(
        title: 'Simple Shopping, Fresh Delivery',
        description:
            'Discover your favorite dairy products, order easily and enjoy freshness at your doorstep.',
        visualWidget: const _DairyDeliveryVisual(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isDesktop
            ? _buildDesktopLayout(context, pages)
            : _buildMobileTabletLayout(context, pages),
      ),
    );
  }

  /// Mobile & Tablet Viewport Layout (Vertical Stack with PageView)
  Widget _buildMobileTabletLayout(
      BuildContext context, List<OnboardingData> pages) {
    return Column(
      children: [
        // Top Header: Skip Button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p20,
            vertical: AppSizes.p12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo / Brand
              Row(
                children: const [
                  Icon(Icons.water_drop_rounded,
                      color: AppColors.primaryBlue, size: 24),
                  SizedBox(width: 6),
                  Text(
                    'Sawariya Dairy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),

              // Skip Button
              TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main PageView Content Area
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Visual Illustration Container
                    Expanded(
                      flex: 5,
                      child: Center(child: page.visualWidget),
                    ),

                    const SizedBox(height: AppSizes.p16),

                    // Text Content
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p12),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Controls: Page Indicator & Action Button
        Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 3-Dot Animated Page Indicator
              Row(
                children: List.generate(
                  pages.length,
                  (index) => _buildDotIndicator(index),
                ),
              ),

              // Action Button (Next / Get Started)
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, AppSizes.buttonHeight),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSizes.borderMedium,
                  ),
                ),
                child: Text(
                  _currentPage == 2 ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Desktop Viewport Layout (Centered Card Grid with Left Visual & Right Content)
  Widget _buildDesktopLayout(
      BuildContext context, List<OnboardingData> pages) {
    final page = pages[_currentPage];

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960),
        height: 600,
        margin: const EdgeInsets.all(AppSizes.p32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSizes.borderXLarge,
          border: Border.all(color: AppColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Side: Visual Illustration Panel
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(AppSizes.p32),
                child: Center(child: page.visualWidget),
              ),
            ),

            // Right Side: Content & Controls Panel
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar: Logo & Skip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.water_drop_rounded,
                                color: AppColors.primaryBlue, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Sawariya Dairy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Middle: Title & Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p16),
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),

                    // Bottom: Indicator & Next Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            pages.length,
                            (index) => _buildDotIndicator(index),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            minimumSize:
                                const Size(160, AppSizes.buttonHeight),
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSizes.borderMedium,
                            ),
                          ),
                          child: Text(
                            _currentPage == 2 ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

  /// 3-Dot Animated Page Indicator Widget
  Widget _buildDotIndicator(int index) {
    final isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryBlue
            : AppColors.primaryBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ============================================================================
// CUSTOM DAIRY VISUAL ILLUSTRATION WIDGETS
// ============================================================================

/// Screen 1 Visual: Fresh Milk & Purity Concept
class _DairyFreshVisual extends StatelessWidget {
  const _DairyFreshVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightBlue.withValues(alpha: 0.6),
          ),
        ),
        Container(
          width: 170,
          height: 170,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.local_drink_rounded,
                size: 70,
                color: AppColors.primaryBlue,
              ),
              SizedBox(height: 8),
              Text(
                '100% PURE MILK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.freshGreen,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          top: 30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.freshGreen,
              borderRadius: AppSizes.borderSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Farm Fresh',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Screen 2 Visual: Product Collection Concept
class _DairyCollectionVisual extends StatelessWidget {
  const _DairyCollectionVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightBlue.withValues(alpha: 0.6),
          ),
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: const [
            _ItemBadge(icon: Icons.inventory_2_rounded, label: 'Pure Paneer'),
            _ItemBadge(icon: Icons.rice_bowl_rounded, label: 'Fresh Curd'),
            _ItemBadge(icon: Icons.cookie_rounded, label: 'Desi Ghee'),
            _ItemBadge(icon: Icons.bakery_dining_rounded, label: 'Butter'),
          ],
        ),
      ],
    );
  }
}

class _ItemBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ItemBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderMedium,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: AppColors.primaryBlue),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen 3 Visual: Simple Shopping & Doorstep Delivery Concept
class _DairyDeliveryVisual extends StatelessWidget {
  const _DairyDeliveryVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightBlue.withValues(alpha: 0.6),
          ),
        ),
        Container(
          width: 170,
          height: 170,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.delivery_dining_rounded,
                size: 64,
                color: AppColors.primaryBlue,
              ),
              SizedBox(height: 6),
              Text(
                'EXPRESS DELIVERY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: AppSizes.borderSmall,
            ),
            child: const Text(
              'Morning Doorstep Delivery',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
