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
import '../widgets/password_field.dart';

/// Sawariya Dairy Customer Registration Screen Component
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions to proceed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.register(
      fullName: _fullNameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please verify your mobile number.'),
          backgroundColor: AppColors.freshGreen,
        ),
      );
      // Navigate to OTP verification with mobile number parameter
      context.push('/otp', extra: _mobileController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Please try again.'),
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
          featureTitle: 'Join Sawariya Dairy Family',
          featureSubtitle:
              'Get pure A2 milk, paneer, and authentic ghee delivered daily to your home.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const AuthHeader(
                  title: 'Create Account',
                  subtitle: 'Sign up for fresh daily dairy delivery',
                ),

                const SizedBox(height: AppSizes.p20),

                // Full Name
                AppTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _fullNameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.p14),

                // Mobile Number
                AppTextField(
                  label: 'Mobile Number',
                  hint: 'Enter 10-digit mobile number',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: AppValidators.validatePhone,
                ),

                const SizedBox(height: AppSizes.p14),

                // Email Address
                AppTextField(
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: AppValidators.validateEmail,
                ),

                const SizedBox(height: AppSizes.p14),

                // Password Field
                PasswordField(
                  label: 'Password',
                  hint: 'Create password (min. 8 chars)',
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must contain at least 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.p14),

                // Confirm Password Field
                PasswordField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.p12),

                // Terms & Conditions Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        activeColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _acceptTerms = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'I agree to the Terms & Conditions and Privacy Policy of Sawariya Dairy.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.p20),

                // Submit Button
                LoadingButton(
                  text: 'Create Account',
                  isLoading: isLoading,
                  onPressed: _handleRegister,
                ),

                const SizedBox(height: AppSizes.p20),

                // Already Have Account Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: const Text(
                        'Login',
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
