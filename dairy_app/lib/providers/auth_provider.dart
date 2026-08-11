import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auth_service.dart';

/// Provider for AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth State Notifier for managing loading and auth state
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncData(null));

  Future<bool> login(String usernameOrEmail, String password) async {
    state = const AsyncLoading();
    try {
      final success = await _authService.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String mobileNumber,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final success = await _authService.register(
        fullName: fullName,
        mobileNumber: mobileNumber,
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> sendOtp(String emailOrMobile) async {
    state = const AsyncLoading();
    try {
      final success = await _authService.sendOtp(emailOrMobile: emailOrMobile);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = const AsyncLoading();
    try {
      final success = await _authService.verifyOtp(otp: otp);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    state = const AsyncLoading();
    try {
      final success = await _authService.resetPassword(newPassword: newPassword);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
