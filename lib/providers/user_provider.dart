import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
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
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  UserNotifier() : super(guestUser) {
    loadSession();
    debugPrint('[PROFILE DEBUG T0] UserNotifier initialized, initial state.profileImageUrl: ${state.profileImageUrl}');
  }

  static String? _extractProfileImageUrl(Map<String, dynamic> data) {
    final candidate = data['profileImageUrl'] ??
        data['photoUrl'] ??
        data['photoURL'] ??
        data['profileImage'] ??
        data['imageUrl'] ??
        data['avatar'];
    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
    return null;
  }

  void _startUserDocListener(String uid) {
    _userSubscription?.cancel();
    if (uid.isEmpty) return;

    _userSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final imageUrl = _extractProfileImageUrl(data);
          final currentImageUrl = state.profileImageUrl;
          final effectiveImageUrl = (imageUrl != null && imageUrl.isNotEmpty)
              ? imageUrl
              : currentImageUrl;

          debugPrint('[PROFILE DEBUG T4] Firestore listener fired: uid=$uid, docImageUrl=$imageUrl, currentRiverpod=$currentImageUrl, resolvedEffective=$effectiveImageUrl');

          final updatedUser = User(
            id: uid,
            name: (data['name'] as String?)?.isNotEmpty == true
                ? data['name']
                : state.name,
            phone: (data['phone'] as String?)?.isNotEmpty == true
                ? data['phone']
                : state.phone,
            email: (data['email'] as String?)?.isNotEmpty == true
                ? data['email']
                : state.email,
            profileImageUrl: effectiveImageUrl,
            role: (data['role'] as String?)?.isNotEmpty == true
                ? data['role']
                : state.role,
          );

          if (updatedUser.profileImageUrl != currentImageUrl ||
              updatedUser.name != state.name ||
              updatedUser.phone != state.phone ||
              updatedUser.email != state.email ||
              updatedUser.role != state.role) {
            state = updatedUser;
            notifyAuthStateChanged();
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString(_sessionKey, jsonEncode(updatedUser.toMap()));
            });
            debugPrint('[PROFILE DEBUG T4] State updated by listener: profileImageUrl=${state.profileImageUrl}');
          } else {
            debugPrint('[PROFILE DEBUG T4] No state change needed: profileImageUrl=${state.profileImageUrl}');
          }
        }
      }
    }, onError: (err) {
      debugPrint('[PROFILE DEBUG T4] Firestore listener error: $err');
    });
  }

  /// Load session from SharedPreferences and sync with Firestore in background
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      if (sessionJson != null) {
        final Map<String, dynamic> map = jsonDecode(sessionJson);
        state = User.fromMap(map);
        debugPrint('[PROFILE DEBUG] loadSession: restored User.fromMap profileImageUrl = ${state.profileImageUrl}');

        // Sync in background from Firestore & start real-time listener
        if (state.id.isNotEmpty) {
          _syncFromFirestore(state.id);
          _startUserDocListener(state.id);
        }
      }
    } catch (e) {
      // Fallback to guest user on error
      state = guestUser;
    }
    debugPrint('[PROFILE DEBUG] loadSession: final profileImageUrl = ${state.profileImageUrl}');
    notifyAuthStateChanged();
  }

  Future<void> _syncFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final imageUrl = _extractProfileImageUrl(data);
          final currentImageUrl = state.profileImageUrl;
          final effectiveImageUrl = (imageUrl != null && imageUrl.isNotEmpty)
              ? imageUrl
              : currentImageUrl;

          debugPrint('[PROFILE DEBUG] _syncFromFirestore: uid=$uid, extracted imageUrl=$imageUrl, current=$currentImageUrl, resolved=$effectiveImageUrl');

          final updatedUser = User(
            id: uid,
            name: data['name'] ?? state.name,
            phone: data['phone'] ?? state.phone,
            email: data['email'] ?? state.email,
            profileImageUrl: effectiveImageUrl,
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
            debugPrint('[PROFILE DEBUG] _syncFromFirestore: state updated, profileImageUrl=${state.profileImageUrl}');
            notifyAuthStateChanged();
          }
        }
      }
    } catch (err) {
      debugPrint('[PROFILE DEBUG] _syncFromFirestore error: $err');
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
            final imageUrl = _extractProfileImageUrl(data);
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
              profileImageUrl: (imageUrl != null && imageUrl.isNotEmpty)
                  ? imageUrl
                  : user.profileImageUrl,
              role: (data['role'] as String?)?.isNotEmpty == true
                  ? data['role']
                  : user.role,
            );
          }
          await docRef.set({
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          // Create user profile document in Firestore
          await docRef.set({
            'uid': user.id,
            'name': user.name,
            'phone': user.phone,
            'email': user.email,
            'profileImageUrl': user.profileImageUrl,
            'photoUrl': user.profileImageUrl,
            'role': user.role,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('[PROFILE DEBUG] setSession Firestore sync error: $e');
      }
    }

    state = user;
    notifyAuthStateChanged();
    if (user.id.isNotEmpty) {
      _startUserDocListener(user.id);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = jsonEncode(user.toMap());
      await prefs.setString(_sessionKey, sessionJson);
    } catch (_) {}
  }

  /// Clear session on Logout
  Future<void> clearSession() async {
    _userSubscription?.cancel();
    _userSubscription = null;
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
      {String? name,
      String? phone,
      String? email,
      String? profileImageUrl}) async {
    if (state.id.isEmpty) {
      throw Exception('No authenticated user session found.');
    }

    debugPrint('[PROFILE DEBUG T2] updateProfile: starting, state.profileImageUrl before=${state.profileImageUrl}, incoming profileImageUrl=$profileImageUrl');

    final updatedUser = User(
      id: state.id,
      name: name ?? state.name,
      phone: phone ?? state.phone,
      email: email ?? state.email,
      profileImageUrl: profileImageUrl ?? state.profileImageUrl,
      role: state.role,
    );

    // Update in Firestore first using set with merge so it succeeds whether the document exists or not
    final docRef = _firestore.collection('users').doc(state.id);
    await docRef.set({
      'uid': state.id,
      'role': state.role.isNotEmpty ? state.role : 'customer',
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (profileImageUrl != null) ...{
        'profileImageUrl': profileImageUrl,
        'photoUrl': profileImageUrl,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('[PROFILE DEBUG T2] updateProfile: Firestore write succeeded on users/${state.id}');

    // Update local state
    state = updatedUser;
    debugPrint('[PROFILE DEBUG T3] updateProfile: Riverpod local state updated, profileImageUrl=${state.profileImageUrl}');
    notifyAuthStateChanged();
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = jsonEncode(updatedUser.toMap());
    await prefs.setString(_sessionKey, sessionJson);
    debugPrint('[PROFILE DEBUG T3] updateProfile: session saved to SharedPreferences, profileImageUrl=${updatedUser.profileImageUrl}');
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
