import 'dart:async';

/// Authentication Service Foundation for Sawariya Dairy
class AuthService {
  /// Mock Login request
  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    // Simulated validation check
    if (usernameOrEmail.isNotEmpty && password.length >= 6) {
      return true;
    }
    throw Exception('Invalid username/email or password.');
  }

  /// Mock Registration request
  Future<bool> register({
    required String fullName,
    required String mobileNumber,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return true;
  }

  /// Mock Request OTP
  Future<bool> sendOtp({required String emailOrMobile}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true;
  }

  /// Mock Verify OTP
  Future<bool> verifyOtp({required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (otp == '123456' || otp.length == 6) {
      return true;
    }
    throw Exception('Invalid OTP code. Please try again.');
  }

  /// Mock Reset Password
  Future<bool> resetPassword({
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }
}
