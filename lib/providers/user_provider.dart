import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/auth/app_role.dart';
import '../core/router/auth_refresh.dart';
import '../models/user.dart';

const User guestUser = User(
  id: '',
  name: 'Guest Customer',
  phone: '',
  email: '',
  role: UserRole.customerValue,
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

        // Sync authoritative role and profile in background from Firestore
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
          // Trusted role from Firestore document (fails safely to 'customer' if missing or invalid)
          final trustedRole = UserRole.sanitize(data['role'] as String?);

          final updatedUser = User(
            id: uid,
            name: data['name'] ?? state.name,
            phone: data['phone'] ?? state.phone,
            email: data['email'] ?? state.email,
            profileImageUrl: data['profileImageUrl'] ?? state.profileImageUrl,
            role: trustedRole,
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
      } else {
        // Document deleted in Firestore: revoke privileged access immediately
        if (state.role != UserRole.customerValue) {
          state = User(
            id: state.id,
            name: state.name,
            phone: state.phone,
            email: state.email,
            profileImageUrl: state.profileImageUrl,
            role: UserRole.customerValue,
          );
          final prefs = await SharedPreferences.getInstance();
          final sessionJson = jsonEncode(state.toMap());
          await prefs.setString(_sessionKey, sessionJson);
          notifyAuthStateChanged();
        }
      }
    } catch (_) {
      // Ignore background sync network errors to preserve offline capability
    }
  }

  /// Save session to SharedPreferences, update state, and sync/create in Firestore.
  /// The user's authoritative role is ALWAYS determined by the Firestore document.
  Future<void> setSession(User user) async {
    if (user.id.isNotEmpty) {
      try {
        final docRef = _firestore.collection('users').doc(user.id);
        final doc = await docRef.get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            // Read authoritative role from Firestore document
            final trustedRole = UserRole.sanitize(data['role'] as String?);

            user = User(
              id: user.id,
              name: (data['name'] as String?)?.isNotEmpty == true
                  ? data['name']
                  : (user.name.isNotEmpty ? user.name : 'Sawariya Customer'),
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
              role: trustedRole,
            );
          }
          await docRef.update({
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Self-registration: ALWAYS creates a standard Customer profile.
          // Elevated roles (admin / delivery) must be assigned in Firestore.
          const safeRole = UserRole.customerValue;
          user = User(
            id: user.id,
            name: user.name.isNotEmpty ? user.name : 'Sawariya Customer',
            phone: user.phone,
            email: user.email,
            profileImageUrl: user.profileImageUrl,
            role: safeRole,
          );
          await docRef.set({
            'uid': user.id,
            'name': user.name,
            'phone': user.phone,
            'email': user.email,
            'profileImageUrl': user.profileImageUrl,
            'role': safeRole,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        // Fallback for offline - ensure user never gets elevated offline
        user = User(
          id: user.id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          profileImageUrl: user.profileImageUrl,
          role: UserRole.sanitize(user.role),
        );
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

  /// Updates profile in Firestore first, then keeps local state synchronized.
  /// Strictly prevents updating the 'role' field.
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
      role: state.role, // role is strictly preserved and never mutated here
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
