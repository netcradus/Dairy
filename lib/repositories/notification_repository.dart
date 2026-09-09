import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_item.dart';

/// Repository for reading and writing user notifications stored in Firestore
/// under the path: `users/{userId}/notifications/{notifId}`.
///
/// This path is covered by the existing Firestore security rules:
///   - Admins can read/write any user's notifications (isAdmin() check on /users/{userId}).
///   - Customers can read/write only their own notifications (isOwnDoc(userId)).
///
/// No modification to firestore.rules is required.
class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the notifications subcollection reference for a given [userId].
  CollectionReference<Map<String, dynamic>> _notifCol(String userId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications');

  // ─── Read ───────────────────────────────────────────────────────────────

  /// Streams all notifications for [userId], newest first.
  Stream<List<NotificationItem>> streamUserNotifications(String userId) {
    return _notifCol(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(NotificationItem.fromFirestore)
            .toList());
  }

  // ─── Mark read ──────────────────────────────────────────────────────────

  /// Marks a single notification as read.
  Future<void> markRead(String userId, String notifId) async {
    await _notifCol(userId).doc(notifId).update({'isRead': true});
  }

  /// Marks all provided notification IDs as read using a batch write.
  Future<void> markAllRead(String userId, List<String> notifIds) async {
    if (notifIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in notifIds) {
      batch.update(_notifCol(userId).doc(id), {'isRead': true});
    }
    await batch.commit();
  }

  // ─── Dismiss ────────────────────────────────────────────────────────────

  /// Deletes a single notification document from Firestore.
  Future<void> dismiss(String userId, String notifId) async {
    await _notifCol(userId).doc(notifId).delete();
  }

  /// Deletes all notification documents for [userId] using a batch write.
  Future<void> clearAll(String userId, List<String> notifIds) async {
    if (notifIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in notifIds) {
      batch.delete(_notifCol(userId).doc(id));
    }
    await batch.commit();
  }

  // ─── Write (Admin) ──────────────────────────────────────────────────────

  /// Writes a broadcast notification document to [targetUserId]'s subcollection.
  /// [createdBy] is the admin's uid for audit trail.
  Future<void> sendNotificationToUser({
    required String targetUserId,
    required String title,
    required String body,
    required NotificationType type,
    required String createdBy,
    String? orderId,
    bool isActionable = false,
  }) async {
    await _notifCol(targetUserId).add({
      'title': title,
      'body': body,
      'type': type.value,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isActionable': isActionable,
      'createdBy': createdBy,
      'userId': targetUserId,
      if (orderId != null) 'orderId': orderId,
    });
  }

  /// Fetches all UIDs from the `users` top-level collection.
  /// Admins can read all user documents per existing Firestore rules.
  Future<List<String>> _fetchAllUserIds() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((d) => d.id).toList();
  }

  /// Commits a list of batch operations, splitting into chunks of 500
  /// to stay within Firestore's per-batch limit.
  Future<void> _commitInChunks(
      List<void Function(WriteBatch)> operations) async {
    const chunkSize = 500;
    for (int i = 0; i < operations.length; i += chunkSize) {
      final batch = _firestore.batch();
      final chunk = operations.sublist(
        i,
        (i + chunkSize) < operations.length ? (i + chunkSize) : operations.length,
      );
      for (final op in chunk) {
        op(batch);
      }
      await batch.commit();
    }
  }

  /// Sends a broadcast notification to every user in the `users` collection.
  ///
  /// When [targetUserIds] is empty (the default), the method queries ALL user
  /// documents from Firestore and fans the write out to each one. The admin's
  /// own copy is marked `isRead: true` so it shows as read-only history.
  ///
  /// Uses chunked batches (≤ 500 ops each) to handle large user bases without
  /// exceeding Firestore's per-batch limit.
  Future<void> sendBroadcast({
    required String adminUid,
    required String title,
    required String body,
    required NotificationType type,
    List<String> targetUserIds = const [],
    bool isActionable = false,
  }) async {
    // Resolve recipient list: caller-supplied list OR all users in Firestore.
    final List<String> recipients;
    if (targetUserIds.isNotEmpty) {
      // Explicit targets — ensure admin is always included for history.
      recipients = {...targetUserIds, adminUid}.toList();
    } else {
      // No explicit targets → fan out to every registered user.
      final allUserIds = await _fetchAllUserIds();
      // Ensure admin is included even if their profile doc doesn't exist yet.
      recipients = {...allUserIds, adminUid}.toList();
    }

    // Build a list of batch-operation closures (one per recipient).
    final operations = recipients.map<void Function(WriteBatch)>((uid) {
      return (WriteBatch batch) {
        final ref = _notifCol(uid).doc(); // auto-ID
        batch.set(ref, {
          'title': title,
          'body': body,
          'type': type.value,
          'timestamp': FieldValue.serverTimestamp(),
          // Admin's copy is pre-marked read so it shows as sent-history only.
          'isRead': uid == adminUid,
          'isActionable': isActionable,
          'createdBy': adminUid,
          'userId': uid,
          'isBroadcast': true,
        });
      };
    }).toList();

    await _commitInChunks(operations);
  }
}
