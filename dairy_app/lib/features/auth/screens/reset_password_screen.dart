import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/loading_button.dart';
import '../widgets/password_field.dart';

/// Sawariya Dairy Reset Password Screen Component
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.resetPassword(_newPasswordController.text);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please login with your new password.'),
          backgroundColor: AppColors.freshGreen,
        ),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reset password. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AuthCard(
          featureTitle: 'Password Reset Successful',
          featureSubtitle:
              'Once set, use your new credentials to access daily fresh dairy subscriptions.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const AuthHeader(
                  title: 'Create New Password',
                  subtitle:
                      'Your new password must be different from previous used passwords.',
                ),

                const SizedBox(height: AppSizes.p24),

                // New Password Input
                PasswordField(
                  label: 'New Password',
                  hint: 'Enter at least 8 characters',
                  controller: _newPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    if (value.length < 8) {
                      return 'Password must contain at least 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.p16),

                // Confirm Password Input
                PasswordField(
                  label: 'Confirm New Password',
                  hint: 'Re-enter your new password',
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.p24),

                // Reset Password Button
                LoadingButton(
                  text: 'Reset Password',
                  isLoading: isLoading,
                  onPressed: _handleResetPassword,
                ),

                const SizedBox(height: AppSizes.p20),

                // Back to Login Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
