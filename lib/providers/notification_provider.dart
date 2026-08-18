import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';

/// Mock seed notifications for Sawariya Dairy (Phase 7)
final List<NotificationItem> _mockNotifications = [
  NotificationItem(
    id: 'n1',
    type: NotificationType.delivery,
    title: 'Order Out for Delivery',
    body: 'Your order #SD-9842 is on the way. Expected delivery by 7:30 AM.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    orderId: 'SD-9842',
    isRead: false,
    isActionable: true,
  ),
  NotificationItem(
    id: 'n2',
    type: NotificationType.order,
    title: 'Order Placed Successfully',
    body: 'Order #SD-9810 has been placed. You will be notified when it ships.',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    orderId: 'SD-9810',
    isRead: false,
    isActionable: true,
  ),
  NotificationItem(
    id: 'n3',
    type: NotificationType.subscription,
    title: 'Subscription Renewal Reminder',
    body: 'Your daily A2 milk subscription will renew at 5:00 AM tomorrow.',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: false,
    isActionable: true,
  ),
  NotificationItem(
    id: 'n4',
    type: NotificationType.promotional,
    title: 'Weekly Special Offer',
    body: 'Get 15% OFF on all Ghee & Butter combos. Order before midnight!',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    isRead: true,
    isActionable: true,
  ),
  NotificationItem(
    id: 'n5',
    type: NotificationType.system,
    title: 'Delivery Update',
    body: 'Same-day delivery available for orders placed before 10:30 AM.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
    isActionable: false,
  ),
  NotificationItem(
    id: 'n6',
    type: NotificationType.delivery,
    title: 'Order Delivered',
    body: 'Your order #SD-9745 was delivered yesterday at 7:15 AM.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    orderId: 'SD-9745',
    isRead: true,
    isActionable: true,
  ),
];

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier() : super(_mockNotifications);

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void markRead(String id) {
    state = state
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
      (ref) => NotificationsNotifier(),
    );

/// Convenience providers for UI
final unreadNotificationsProvider = Provider<List<NotificationItem>>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).toList();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(unreadNotificationsProvider).length;
});
