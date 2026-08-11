import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/responsive/responsive.dart';

/// Responsive Authentication Shell Container Card
class AuthCard extends StatelessWidget {
  final Widget child;
  final String? featureTitle;
  final String? featureSubtitle;

  const AuthCard({
    super.key,
    required this.child,
    this.featureTitle = 'Freshness & Purity Guaranteed',
    this.featureSubtitle = 'Pure A2 milk, organic curd, paneer, and butter delivered fresh every morning.',
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop
              ? AppSizes.p32
              : isTablet
                  ? AppSizes.p32
                  : AppSizes.p16,
          vertical: AppSizes.p24,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 960 : 480,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSizes.borderXLarge,
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: isDesktop
              ? Row(
                  children: [
                    // Left Column: Desktop Brand Illustration Panel
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
                        padding: const EdgeInsets.all(AppSizes.p40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Dairy Emblem Graphics
                            Container(
                              width: 140,
                              height: 140,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surface,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.water_drop_rounded,
                                  size: 72,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.p32),
                            Text(
                              featureTitle!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p12),
                            Text(
                              featureSubtitle!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p32),
                            // Quality Badges
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                _FeatureChip(icon: Icons.verified, label: '100% Pure'),
                                SizedBox(width: 8),
                                _FeatureChip(icon: Icons.local_shipping, label: 'Fast Delivery'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right Column: Form Child Content
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.p40),
                        child: child,
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: child,
                ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderSmall,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
