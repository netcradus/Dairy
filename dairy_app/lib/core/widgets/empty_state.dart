import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'app_button.dart';

/// Reusable Empty State Component
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.12),
                    AppColors.primaryBlue.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.cardShadowSm,
                  ),
                  child: Icon(icon, size: 32, color: AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
             const SizedBox(height: 28),
              SizedBox(
                width: 200,
                child: AppButton(
                  text: buttonText!,
                  onPressed: onButtonPressed,
                  variant: AppButtonVariant.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
