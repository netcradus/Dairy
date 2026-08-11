import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/loading_button.dart';
import '../widgets/otp_input_field.dart';

/// Sawariya Dairy OTP Verification Screen Component
class OtpScreen extends ConsumerStatefulWidget {
  final String? targetDestination;
  final bool isPasswordResetFlow;

  const OtpScreen({
    super.key,
    this.targetDestination,
    this.isPasswordResetFlow = false,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otpCode = '';
  late Timer _timer;
  int _startSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _startSeconds = 30;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds == 0) {
        setState(() {
          _canResend = true;
          _timer.cancel();
        });
      } else {
        setState(() {
          _startSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit OTP code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.verifyOtp(_otpCode);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP Verified successfully!'),
          backgroundColor: AppColors.freshGreen,
        ),
      );

      if (widget.isPasswordResetFlow) {
        context.push('/reset-password');
      } else {
        context.go('/login');
      }
    } else {
      final errorState = ref.read(authProvider);
      final errorMsg = errorState.error?.toString() ?? 'Invalid OTP code';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg.replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    final target = widget.targetDestination ?? 'your mobile number';
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.sendOtp(target);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A new OTP has been sent to $target.'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );

    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final displayDestination =
        widget.targetDestination ?? '+91 98765 43210';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AuthCard(
          featureTitle: 'Secure Account Verification',
          featureSubtitle:
              'We ensure 100% security for all Sawariya Dairy customer transactions and orders.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              AuthHeader(
                title: 'Verify Your Number',
                subtitle:
                    'Enter the 6-digit OTP sent to $displayDestination.',
              ),

              const SizedBox(height: AppSizes.p12),

              // Change Number Option
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit_outlined,
                        size: 14, color: AppColors.primaryBlue),
                    SizedBox(width: 4),
                    Text(
                      'Change Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p24),

              // 6-Digit Pin Input Field
              OtpInputField(
                onChanged: (code) {
                  setState(() {
                    _otpCode = code;
                  });
                },
                onCompleted: (code) {
                  setState(() {
                    _otpCode = code;
                  });
                  _handleVerifyOtp();
                },
              ),

              const SizedBox(height: AppSizes.p24),

              // Countdown Timer & Resend Option
              Center(
                child: _canResend
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive the OTP? ",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleResendOtp,
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Resend OTP in 00:${_startSeconds.toString().padLeft(2, '0')}s',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
              ),

              const SizedBox(height: AppSizes.p24),

              // Submit Verify Button
              LoadingButton(
                text: 'Verify OTP',
                isLoading: isLoading,
                onPressed: _handleVerifyOtp,
              ),

              const SizedBox(height: AppSizes.p16),

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
    );
  }
}
