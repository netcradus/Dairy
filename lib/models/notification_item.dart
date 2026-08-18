import 'package:flutter/material.dart';

/// Notification type for Sawariya Dairy
enum NotificationType {
  order,
  delivery,
  promotional,
  subscription,
  system,
}

extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.order:
        return Icons.receipt_long_rounded;
      case NotificationType.delivery:
        return Icons.local_shipping_outlined;
      case NotificationType.promotional:
        return Icons.local_offer_outlined;
      case NotificationType.subscription:
        return Icons.subscriptions_outlined;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }
}

/// Notification Model for Sawariya Dairy (Phase 7)
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? orderId;
  final bool isRead;
  final bool isActionable;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.orderId,
    this.isRead = false,
    this.isActionable = false,
  });

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    String? orderId,
    bool? isRead,
    bool? isActionable,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
    );
  }
}
