import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

const User guestUser = User(
  id: '',
  name: 'Guest Customer',
  phone: '',
  email: '',
  role: 'customer',
);

/// Current user profile state notifier that supports SharedPreferences persistence.
class UserNotifier extends StateNotifier<User> {
  static const String _sessionKey = 'user_session';

  UserNotifier() : super(guestUser) {
    loadSession();
  }

  /// Load session from SharedPreferences
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      if (sessionJson != null) {
        final Map<String, dynamic> map = jsonDecode(sessionJson);
        state = User.fromMap(map);
      }
    } catch (e) {
      // Fallback to guest user on error
      state = guestUser;
    }
  }

  /// Save session to SharedPreferences and update state
  Future<void> setSession(User user) async {
    state = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = jsonEncode(user.toMap());
      await prefs.setString(_sessionKey, sessionJson);
    } catch (_) {}
  }

  /// Clear session on Logout
  Future<void> clearSession() async {
    state = guestUser;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {}
  }

  void updateProfile({String? name, String? phone, String? email}) {
    final updatedUser = User(
      id: state.id,
      name: name ?? state.name,
      phone: phone ?? state.phone,
      email: email ?? state.email,
      profileImageUrl: state.profileImageUrl,
      role: state.role,
    );
    setSession(updatedUser);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
