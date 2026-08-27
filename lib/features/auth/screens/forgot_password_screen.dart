import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/loading_button.dart';

/// Sawariya Dairy Forgot Password Screen Component
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final destination = _destinationController.text.trim();
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.sendOtp(destination);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $destination successfully.'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );

      // Navigate to OTP verification screen with reset flag
      context.push(
        '/otp',
        extra: {
          'targetDestination': destination,
          'isPasswordResetFlow': true,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
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
          featureTitle: 'Quick Password Recovery',
          featureSubtitle:
              'Verify your registered email or mobile to create a new password safely.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const AuthHeader(
                  title: 'Forgot Password?',
                  subtitle:
                      'Enter your registered email address or mobile number to receive a 6-digit OTP code.',
                ),

                const SizedBox(height: AppSizes.p24),

                // Destination Input Field
                AppTextField(
                  label: 'Email or Mobile Number',
                  hint: 'e.g. name@email.com or 9876543210',
                  controller: _destinationController,
                  prefixIcon:
                      const Icon(Icons.mark_email_read_outlined, size: 20),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your registered email or mobile number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.p24),

                // Send OTP Button
                LoadingButton(
                  text: 'Send OTP',
                  isLoading: isLoading,
                  onPressed: _handleSendOtp,
                ),

                const SizedBox(height: AppSizes.p20),

                // Back to Login Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: const Text(
                      'Remember your password? Login',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
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
