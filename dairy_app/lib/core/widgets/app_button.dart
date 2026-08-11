import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

/// Production Reusable Button Component with Touch Target & Loading Support
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? AppSizes.buttonHeight;
    final childWidget = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.outlined || variant == AppButtonVariant.text
                    ? AppColors.primaryBlue
                    : AppColors.textOnPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSizes.p8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(isFullWidth ? double.infinity : (width ?? 0), effectiveHeight),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppSizes.borderMedium),
          ),
          child: childWidget,
        );
        break;

      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(isFullWidth ? double.infinity : (width ?? 0), effectiveHeight),
            backgroundColor: AppColors.lightBlue,
            foregroundColor: AppColors.primaryBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppSizes.borderMedium),
          ),
          child: childWidget,
        );
        break;

      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(isFullWidth ? double.infinity : (width ?? 0), effectiveHeight),
            side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            foregroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: AppSizes.borderMedium),
          ),
          child: childWidget,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(isFullWidth ? double.infinity : (width ?? 0), effectiveHeight),
            foregroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: AppSizes.borderSmall),
          ),
          child: childWidget,
        );
        break;
    }

    return SizedBox(
      height: effectiveHeight,
      width: isFullWidth ? double.infinity : width,
      child: button,
    );
  }
}
