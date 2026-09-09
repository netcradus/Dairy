import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_item.dart';
import '../repositories/notification_repository.dart';
import 'user_provider.dart';

// ─── Repository provider ────────────────────────────────────────────────────

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);

// ─── Firestore-backed stream provider (real data) ──────────────────────────

/// Streams all notifications for the currently authenticated user from Firestore.
/// Uses the `users/{uid}/notifications` subcollection (rules-compliant).
/// Returns an empty list for guest users.
final userNotificationsStreamProvider =
    StreamProvider.autoDispose<List<NotificationItem>>((ref) {
  final user = ref.watch(userProvider);
  if (user.id.isEmpty) return const Stream.empty();
  return ref
      .watch(notificationRepositoryProvider)
      .streamUserNotifications(user.id);
});

/// Streams notifications for a specific [userId] — used by admin panel.
final notificationsForUserStreamProvider =
    StreamProvider.autoDispose.family<List<NotificationItem>, String>(
  (ref, userId) {
    if (userId.isEmpty) return const Stream.empty();
    return ref
        .watch(notificationRepositoryProvider)
        .streamUserNotifications(userId);
  },
);

// ─── Derived convenience providers (Firestore-backed) ──────────────────────

/// Unread notifications count for the current user from Firestore.
final firestoreUnreadCountProvider = Provider.autoDispose<AsyncValue<int>>(
  (ref) => ref.watch(userNotificationsStreamProvider).whenData(
        (list) => list.where((n) => !n.isRead).length,
      ),
);
