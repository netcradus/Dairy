import 'dart:async'; // Add this import for Completer
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'user_provider.dart';

/// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<fb.FirebaseAuth>(
  (ref) => fb.FirebaseAuth.instance,
);

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

/// Auth State Notifier for managing Firebase Phone Auth
class AuthNotifier extends StateNotifier<AuthState> {
  final fb.FirebaseAuth _auth;

  AuthNotifier(this._auth) : super(AuthState(status: const AsyncData(null)));

  String? _verificationId;

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

  /// Initiates Firebase OTP sending for Sign In (Fixed with Completer)
  Future<bool> startSignIn(String mobileNumber) async {
    state = state.copyWith(status: const AsyncLoading());
    final completer = Completer<bool>();

    try {
      final formattedPhone =
          mobileNumber.startsWith('+') ? mobileNumber : '+91$mobileNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          state = state.copyWith(
            status: AsyncError(
              Exception(e.message ?? 'Verification failed'),
              StackTrace.current,
            ),
          );
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          state = state.copyWith(
            status: const AsyncData(null),
            mobileNumber: mobileNumber,
            isSignUpFlow: false,
          );
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return await completer.future;
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
      return false;
    }
  }

  /// Initiates Firebase OTP sending for Sign Up (Fixed with Completer)
  Future<bool> startSignUp({
    required String fullName,
    required String mobileNumber,
  }) async {
    state = state.copyWith(status: const AsyncLoading());
    final completer = Completer<bool>();

    try {
      final formattedPhone =
          mobileNumber.startsWith('+') ? mobileNumber : '+91$mobileNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          state = state.copyWith(
            status: AsyncError(
              Exception(e.message ?? 'Verification failed'),
              StackTrace.current,
            ),
          );
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          state = state.copyWith(
            status: const AsyncData(null),
            mobileNumber: mobileNumber,
            tempFullName: fullName,
            isSignUpFlow: true,
          );
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return await completer.future;
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
      return false;
    }
  }

  /// Resends OTP to the current mobile number
  Future<bool> resendOtp() async {
    final mobile = state.mobileNumber;
    if (mobile == null) return false;
    return startSignIn(mobile);
  }

  /// Verifies the OTP via Firebase and completes the session
  Future<bool> verifyOtp(String otp, WidgetRef ref) async {
    if (_verificationId == null) {
      state = state.copyWith(
        status: AsyncError(
          Exception('Verification ID not found. Please request OTP again.'),
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(status: const AsyncLoading());
    try {
      fb.PhoneAuthCredential credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      fb.UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final mobile = state.mobileNumber ?? firebaseUser.phoneNumber ?? '';
        final name = state.isSignUpFlow
            ? (state.tempFullName ?? 'Sawariya Customer')
            : (state.tempFullName ?? 'Sawariya Customer');

        final initialUser = User(
          id: firebaseUser.uid,
          name: name,
          phone: mobile,
          email: firebaseUser.email,
        );

        // setSession queries Firestore users/{uid} for the authoritative role
        await ref.read(userProvider.notifier).setSession(initialUser);

        state = AuthState(status: const AsyncData(null));
        return true;
      }
      throw Exception('Failed to sign in with Firebase.');
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(firebaseAuthProvider));
});
