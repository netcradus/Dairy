import 'package:cloud_firestore/cloud_firestore.dart';
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

  String get value {
    switch (this) {
      case NotificationType.order:
        return 'order';
      case NotificationType.delivery:
        return 'delivery';
      case NotificationType.promotional:
        return 'promotional';
      case NotificationType.subscription:
        return 'subscription';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(String? value) {
    switch (value) {
      case 'order':
        return NotificationType.order;
      case 'delivery':
        return NotificationType.delivery;
      case 'promotional':
        return NotificationType.promotional;
      case 'subscription':
        return NotificationType.subscription;
      default:
        return NotificationType.system;
    }
  }
}

/// Notification Model for Sawariya Dairy (Task 11 — Firestore-backed)
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? orderId;
  final bool isRead;
  final bool isActionable;

  /// Optional: uid of admin who created this notification (for broadcasts)
  final String? createdBy;

  /// Optional: recipient uid (stored on document for filtering)
  final String? userId;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.orderId,
    this.isRead = false,
    this.isActionable = false,
    this.createdBy,
    this.userId,
  });

  /// Deserialize from a Firestore [DocumentSnapshot].
  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['timestamp'];
    final DateTime parsedTime;
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else if (ts is DateTime) {
      parsedTime = ts;
    } else {
      parsedTime = DateTime.now();
    }
    return NotificationItem(
      id: doc.id,
      type: NotificationTypeExtension.fromString(data['type'] as String?),
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? (data['message'] as String?) ?? '',
      timestamp: parsedTime,
      orderId: data['orderId'] as String?,
      isRead: (data['isRead'] as bool?) ?? false,
      isActionable: (data['isActionable'] as bool?) ?? false,
      createdBy: data['createdBy'] as String?,
      userId: data['userId'] as String?,
    );
  }

  /// Serialize to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      if (orderId != null) 'orderId': orderId,
      'isRead': isRead,
      'isActionable': isActionable,
      if (createdBy != null) 'createdBy': createdBy,
      if (userId != null) 'userId': userId,
    };
  }

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    String? orderId,
    bool? isRead,
    bool? isActionable,
    String? createdBy,
    String? userId,
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
      createdBy: createdBy ?? this.createdBy,
      userId: userId ?? this.userId,
    );
  }
}
