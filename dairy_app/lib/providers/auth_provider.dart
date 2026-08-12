import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/mock_otp_service.dart';
import '../models/user.dart';
import 'user_provider.dart';

/// Provider for MockOtpService instance
final mockOtpServiceProvider = Provider<MockOtpService>((ref) {
  return MockOtpService();
});

/// State containing status of the auth requests
class AuthState {
  final AsyncValue<void> status;
  final String? mobileNumber;
  final String? tempFullName;
  final bool isSignUpFlow;

  AuthState({
    required this.status,
    this.mobileNumber,
    this.tempFullName,
    this.isSignUpFlow = false,
  });

  bool get isLoading => status.isLoading;

  AuthState copyWith({
    AsyncValue<void>? status,
    String? mobileNumber,
    String? tempFullName,
    bool? isSignUpFlow,
  }) {
    return AuthState(
      status: status ?? this.status,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      tempFullName: tempFullName ?? this.tempFullName,
      isSignUpFlow: isSignUpFlow ?? this.isSignUpFlow,
    );
  }
}

/// Auth State Notifier for managing loading, mobile, temp signup state and verification
class AuthNotifier extends StateNotifier<AuthState> {
  final MockOtpService _otpService;

  AuthNotifier(this._otpService)
      : super(AuthState(status: const AsyncData(null)));

  /// Compatibility stub for forgot password flow
  Future<bool> sendOtp(String mobileNumber) async {
    return startSignIn(mobileNumber);
  }

  /// Compatibility stub for reset password flow
  Future<bool> resetPassword(String newPassword) async {
    state = state.copyWith(status: const AsyncLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    state = state.copyWith(status: const AsyncData(null));
    return true;
  }

  /// Initiates OTP sending for Sign In
  Future<bool> startSignIn(String mobileNumber) async {
    state = state.copyWith(status: const AsyncLoading());
    try {
      final success = await _otpService.sendOtp(mobileNumber);
      if (success) {
        state = state.copyWith(
          status: const AsyncData(null),
          mobileNumber: mobileNumber,
          isSignUpFlow: false,
        );
        return true;
      }
      throw Exception('Failed to send OTP. Please try again.');
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
      return false;
    }
  }

  /// Initiates OTP sending for Sign Up
  Future<bool> startSignUp({
    required String fullName,
    required String mobileNumber,
  }) async {
    state = state.copyWith(status: const AsyncLoading());
    try {
      final success = await _otpService.sendOtp(mobileNumber);
      if (success) {
        state = state.copyWith(
          status: const AsyncData(null),
          mobileNumber: mobileNumber,
          tempFullName: fullName,
          isSignUpFlow: true,
        );
        return true;
      }
      throw Exception('Failed to send OTP. Please try again.');
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
      return false;
    }
  }

  /// Resends OTP to the current mobile number
  Future<bool> resendOtp() async {
    final mobile = state.mobileNumber;
    if (mobile == null) return false;
    
    state = state.copyWith(status: const AsyncLoading());
    try {
      final success = await _otpService.sendOtp(mobile);
      state = state.copyWith(status: const AsyncData(null));
      return success;
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
      return false;
    }
  }

  /// Verifies the OTP and completes the Sign In / Sign Up process
  Future<bool> verifyOtp(String otp, WidgetRef ref) async {
    final mobile = state.mobileNumber;
    if (mobile == null) {
      state = state.copyWith(
        status: AsyncError(Exception('No active mobile number found for verification.'), StackTrace.current),
      );
      return false;
    }

    state = state.copyWith(status: const AsyncLoading());
    try {
      final verified = await _otpService.verifyOtp(mobile, otp);
      if (verified) {
        // Create user session details
        String role;
        String name;
        String? email;
        if (mobile == '9999999999') {
          role = 'admin';
          name = state.isSignUpFlow ? (state.tempFullName ?? 'Sawariya Admin') : 'Sawariya Admin';
          email = state.isSignUpFlow ? null : 'admin@sawariyadairy.com';
        } else if (mobile == '7777777777') {
          role = 'delivery';
          name = state.isSignUpFlow ? (state.tempFullName ?? 'Delivery Partner') : 'Rajesh Kumar';
          email = state.isSignUpFlow ? null : 'delivery@sawariyadairy.com';
        } else {
          role = 'customer';
          name = state.isSignUpFlow ? (state.tempFullName ?? 'Sawariya Customer') : 'Sawariya Customer';
          email = state.isSignUpFlow ? null : 'customer@sawariyadairy.com';
        }

        final user = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          phone: mobile,
          email: email,
          role: role,
        );

        // Save session in UserNotifier
        await ref.read(userProvider.notifier).setSession(user);

        state = AuthState(status: const AsyncData(null)); // reset state
        return true;
      }
      throw Exception('Invalid OTP. Please check the code and try again.');
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(mockOtpServiceProvider));
});
