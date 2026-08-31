import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/router/auth_refresh.dart';
import '../models/user.dart';

const User guestUser = User(
  id: '',
  name: 'Guest Customer',
  phone: '',
  email: '',
  role: 'customer',
);

/// Current user profile state notifier that supports SharedPreferences persistence and Firestore sync.
class UserNotifier extends StateNotifier<User> {
  static const String _sessionKey = 'user_session';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserNotifier() : super(guestUser) {
    loadSession();
  }

  /// Load session from SharedPreferences and sync with Firestore in background
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      if (sessionJson != null) {
        final Map<String, dynamic> map = jsonDecode(sessionJson);
        state = User.fromMap(map);

        // Sync in background from Firestore
        if (state.id.isNotEmpty) {
          _syncFromFirestore(state.id);
        }
      }
    } catch (e) {
      // Fallback to guest user on error
      state = guestUser;
    }
    notifyAuthStateChanged();
  }

  Future<void> _syncFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final updatedUser = User(
            id: uid,
            name: data['name'] ?? state.name,
            phone: data['phone'] ?? state.phone,
            email: data['email'] ?? state.email,
            profileImageUrl: data['profileImageUrl'] ?? state.profileImageUrl,
            role: data['role'] ?? state.role,
          );

          if (updatedUser.name != state.name ||
              updatedUser.phone != state.phone ||
              updatedUser.email != state.email ||
              updatedUser.profileImageUrl != state.profileImageUrl ||
              updatedUser.role != state.role) {
            state = updatedUser;
            final prefs = await SharedPreferences.getInstance();
            final sessionJson = jsonEncode(state.toMap());
            await prefs.setString(_sessionKey, sessionJson);
            notifyAuthStateChanged();
          }
        }
      }
    } catch (_) {
      // Ignore background sync errors to preserve offline capability
    }
  }

  /// Save session to SharedPreferences, update state, and sync/create in Firestore
  Future<void> setSession(User user) async {
    if (user.id.isNotEmpty) {
      try {
        final docRef = _firestore.collection('users').doc(user.id);
        final doc = await docRef.get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            // Do NOT overwrite valid existing profile data unnecessarily
            user = User(
              id: user.id,
              name: (data['name'] as String?)?.isNotEmpty == true
                  ? data['name']
                  : user.name,
              phone: (data['phone'] as String?)?.isNotEmpty == true
                  ? data['phone']
                  : user.phone,
              email: (data['email'] as String?)?.isNotEmpty == true
                  ? data['email']
                  : user.email,
              profileImageUrl:
                  (data['profileImageUrl'] as String?)?.isNotEmpty == true
                      ? data['profileImageUrl']
                      : user.profileImageUrl,
              role: (data['role'] as String?)?.isNotEmpty == true
                  ? data['role']
                  : user.role,
            );
          }
          await docRef.update({
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Create user profile document in Firestore
          await docRef.set({
            'uid': user.id,
            'name': user.name,
            'phone': user.phone,
            'email': user.email,
            'profileImageUrl': user.profileImageUrl,
            'role': user.role,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        // Fallback for offline - don't block login
      }
    }

    state = user;
    notifyAuthStateChanged();
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = jsonEncode(user.toMap());
      await prefs.setString(_sessionKey, sessionJson);
    } catch (_) {}
  }

  /// Clear session on Logout
  Future<void> clearSession() async {
    state = guestUser;
    notifyAuthStateChanged();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {}
  }

  /// Developer-only helper (used by debug toggles) to switch the current
  /// user's role so the Delivery Panel can be tested. Persists like a normal
  /// session change.
  Future<void> setRole(String role) async {
    final updatedUser = User(
      id: state.id,
      name: state.name,
      phone: state.phone,
      email: state.email,
      profileImageUrl: state.profileImageUrl,
      role: role,
    );
    await setSession(updatedUser);
  }

  /// Updates profile in Firestore first, then keeps local state synchronized.
  Future<void> updateProfile(
      {String? name, String? phone, String? email}) async {
    if (state.id.isEmpty) {
      throw Exception('No authenticated user session found.');
    }

    final updatedUser = User(
      id: state.id,
      name: name ?? state.name,
      phone: phone ?? state.phone,
      email: email ?? state.email,
      profileImageUrl: state.profileImageUrl,
      role: state.role,
    );

    // Update in Firestore first (will throw exception on failure)
    final docRef = _firestore.collection('users').doc(state.id);
    await docRef.update({
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // If Firestore update succeeded, update local state
    state = updatedUser;
    notifyAuthStateChanged();
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = jsonEncode(updatedUser.toMap());
    await prefs.setString(_sessionKey, sessionJson);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
