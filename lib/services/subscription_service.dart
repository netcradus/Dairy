import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService([FirebaseFirestore? firestore]) {
    if (firestore != null) {
      return SubscriptionService._withFirestore(firestore);
    }
    return _instance;
  }

  SubscriptionService._internal() : _firestore = FirebaseFirestore.instance;
  SubscriptionService._withFirestore(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _prefPrefix = 'cached_subscription_';

  Future<void> _saveToLocal(String uid, Subscription sub) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefPrefix$uid', jsonEncode(sub.toMap()));
    } catch (_) {}
  }

  Future<Subscription?> _loadFromLocal(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('$_prefPrefix$uid');
      if (str != null && str.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(str);
        return Subscription.fromMap(data);
      }
    } catch (_) {}
    return null;
  }

  /// Get the current subscription for a user
  Future<Subscription?> getCurrentSubscription(String uid) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final effectiveUid = (authUid != null && authUid.isNotEmpty) ? authUid : uid;
    print('[SUBSCRIPTION_DEBUG] Op: GET | Auth UID: $authUid | Target UID: $effectiveUid | Path: users/$effectiveUid/subscription/current');

    try {
      final subDocRef = _firestore
          .collection('users')
          .doc(effectiveUid)
          .collection('subscription')
          .doc('current');
      final doc = await subDocRef.get();
      if (doc.exists) {
        print('[SUBSCRIPTION_DEBUG] Op: GET | Found in Firestore at users/$effectiveUid/subscription/current');
        final sub = Subscription.fromFirestore(doc);
        unawaited(_saveToLocal(effectiveUid, sub));
        return sub;
      }
      print('[SUBSCRIPTION_DEBUG] Op: GET | Doc does not exist in Firestore at users/$effectiveUid/subscription/current');
      return await _loadFromLocal(effectiveUid);
    } catch (e) {
      print('[SUBSCRIPTION_DEBUG] Op: GET | Error fetching from Firestore: $e');
      return await _loadFromLocal(effectiveUid);
    }
  }

  /// Stream the current subscription for a user
  Stream<Subscription?> streamCurrentSubscription(String uid) {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final effectiveUid = (authUid != null && authUid.isNotEmpty) ? authUid : uid;
    try {
      final docRef = _firestore
          .collection('users')
          .doc(effectiveUid)
          .collection('subscription')
          .doc('current');
      return docRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          final sub = Subscription.fromFirestore(snapshot);
          unawaited(_saveToLocal(effectiveUid, sub));
          return sub;
        }
        return null;
      }).handleError((err) async* {
        print('[SUBSCRIPTION_DEBUG] Stream error: $err');
        final local = await _loadFromLocal(effectiveUid);
        yield local;
      });
    } catch (e) {
      print('[SUBSCRIPTION_DEBUG] streamCurrentSubscription catch: $e');
      return Stream.fromFuture(_loadFromLocal(effectiveUid));
    }
  }

  /// Create a new subscription for a user
  Future<Subscription> createSubscription(
      String uid, Subscription subscription) async {
    final now = DateTime.now();
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final effectiveUid = (authUid != null && authUid.isNotEmpty) ? authUid : uid;
    final subscriptionWithTimestamps = subscription.copyWith(
      createdAt: subscription.createdAt ?? now,
      updatedAt: now,
    );

    print('[SUBSCRIPTION_DEBUG] Op: CREATE | Auth UID: $authUid | Target UID: $effectiveUid | Path: users/$effectiveUid/subscription/current');

    try {
      final docRef = _firestore
          .collection('users')
          .doc(effectiveUid)
          .collection('subscription')
          .doc('current');
      await docRef.set(subscriptionWithTimestamps.toFirestore());
      print('[SUBSCRIPTION_DEBUG] Op: CREATE | SUCCESS at users/$effectiveUid/subscription/current');
      await _saveToLocal(effectiveUid, subscriptionWithTimestamps);
    } catch (e) {
      print('[SUBSCRIPTION_DEBUG] Op: CREATE | FAILURE at users/$effectiveUid/subscription/current: $e');
      developer.log('[SubscriptionService] Firestore set error: $e');
      rethrow;
    }

    return subscriptionWithTimestamps;
  }

  /// Update an existing subscription
  Future<Subscription> updateSubscription(
      String uid, Subscription subscription) async {
    final now = DateTime.now();
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final effectiveUid = (authUid != null && authUid.isNotEmpty) ? authUid : uid;
    final updatedSubscription = subscription.copyWith(updatedAt: now);

    print('[SUBSCRIPTION_DEBUG] Op: UPDATE | Auth UID: $authUid | Target UID: $effectiveUid | Path: users/$effectiveUid/subscription/current');

    try {
      final docRef = _firestore
          .collection('users')
          .doc(effectiveUid)
          .collection('subscription')
          .doc('current');
      await docRef.set(updatedSubscription.toFirestore());
      print('[SUBSCRIPTION_DEBUG] Op: UPDATE | SUCCESS at users/$effectiveUid/subscription/current');
      await _saveToLocal(effectiveUid, updatedSubscription);
    } catch (e) {
      print('[SUBSCRIPTION_DEBUG] Op: UPDATE | FAILURE at users/$effectiveUid/subscription/current: $e');
      developer.log('[SubscriptionService] Firestore update error: $e');
      rethrow;
    }

    return updatedSubscription;
  }

  /// Cancel a subscription (sets status to "cancelled")
  Future<Subscription> cancelSubscription(String uid) async {
    final now = DateTime.now();
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final effectiveUid = (authUid != null && authUid.isNotEmpty) ? authUid : uid;

    print('[SUBSCRIPTION_DEBUG] Op: CANCEL | Auth UID: $authUid | Target UID: $effectiveUid | Path: users/$effectiveUid/subscription/current');
    Subscription? existing = await getCurrentSubscription(effectiveUid);
    if (existing != null) {
      final cancelledSub = existing.copyWith(
        status: SubscriptionStatus.cancelled,
        autoRenew: false,
        updatedAt: now,
      );

      try {
        final subDocRef = _firestore
            .collection('users')
            .doc(effectiveUid)
            .collection('subscription')
            .doc('current');
        await subDocRef.set(cancelledSub.toFirestore());
        print('[SUBSCRIPTION_DEBUG] Op: CANCEL | SUCCESS at users/$effectiveUid/subscription/current');
        await _saveToLocal(effectiveUid, cancelledSub);
      } catch (e) {
        print('[SUBSCRIPTION_DEBUG] Op: CANCEL | FAILURE at users/$effectiveUid/subscription/current: $e');
        developer.log('[SubscriptionService] Firestore cancel error: $e');
        rethrow;
      }

      return cancelledSub;
    }
    throw Exception('No active subscription found to cancel.');
  }

  /// Renew a subscription (updates startDate, endDate, status)
  Future<Subscription> renewSubscription(String uid,
      {Duration? duration}) async {
    final now = DateTime.now();
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final effectiveUid = (authUid != null && authUid.isNotEmpty) ? authUid : uid;

    print('[SUBSCRIPTION_DEBUG] Op: RENEW | Auth UID: $authUid | Target UID: $effectiveUid | Path: users/$effectiveUid/subscription/current');
    Subscription? existing = await getCurrentSubscription(effectiveUid);

    if (existing == null) {
      throw Exception('No current subscription to renew');
    }

    final baseDate = (existing.endDate != null && existing.endDate!.isAfter(now))
        ? existing.endDate!
        : now;
    final newEndDate = baseDate.add(duration ?? const Duration(days: 30));

    final renewedSub = existing.copyWith(
      startDate: now,
      endDate: newEndDate,
      status: SubscriptionStatus.active,
      autoRenew: true,
      updatedAt: now,
    );

    try {
      final subDocRef = _firestore
          .collection('users')
          .doc(effectiveUid)
          .collection('subscription')
          .doc('current');
      await subDocRef.set(renewedSub.toFirestore());
      print('[SUBSCRIPTION_DEBUG] Op: RENEW | SUCCESS at users/$effectiveUid/subscription/current');
      await _saveToLocal(effectiveUid, renewedSub);
    } catch (e) {
      print('[SUBSCRIPTION_DEBUG] Op: RENEW | FAILURE at users/$effectiveUid/subscription/current: $e');
      developer.log('[SubscriptionService] Firestore renew error: $e');
      rethrow;
    }

    return renewedSub;
  }

  /// Check if subscription is active (status active AND endDate in future)
  Future<bool> isSubscriptionActive(String uid) async {
    try {
      final sub = await getCurrentSubscription(uid);
      return sub?.isActiveAndValid ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get subscription plan name
  Future<String?> getPlanName(String uid) async {
    try {
      final sub = await getCurrentSubscription(uid);
      return sub?.planName;
    } catch (e) {
      return null;
    }
  }

  /// Get subscription status
  Future<SubscriptionStatus?> getSubscriptionStatus(String uid) async {
    try {
      final sub = await getCurrentSubscription(uid);
      return sub?.status;
    } catch (e) {
      return null;
    }
  }
}
