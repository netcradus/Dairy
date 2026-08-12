import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/loading_button.dart';

/// Sawariya Dairy Mobile Sign In Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final mobile = _mobileController.text.trim();
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.startSignIn(mobile);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: AppColors.freshGreen,
        ),
      );
      // Navigate to OTP screen
      context.push('/otp', extra: mobile);
    } else {
      final errorState = ref.read(authProvider);
      final errorMsg = errorState.status.error?.toString() ?? 'Failed to send OTP. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg.replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AuthCard(
          featureTitle: 'Pure Dairy at Your Doorstep',
          featureSubtitle:
              'Order farm-fresh A2 milk, ghee, paneer, and butter with daily morning delivery.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const AuthHeader(
                  title: 'Welcome Back!',
                  subtitle: 'Sign in using your mobile number',
                ),

                const SizedBox(height: AppSizes.p24),

                // Mobile Number Input
                AppTextField(
                  label: 'Mobile Number',
                  hint: 'Enter 10-digit mobile number',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: AppValidators.validatePhone,
                ),

                const SizedBox(height: AppSizes.p24),

                // Send OTP Button
                LoadingButton(
                  text: 'Send OTP',
                  isLoading: isLoading,
                  onPressed: _handleSendOtp,
                ),

                const SizedBox(height: AppSizes.p24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/register');
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
