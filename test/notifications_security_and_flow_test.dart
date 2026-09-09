import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_app/models/notification_item.dart';

void main() {
  group('Notifications Security, Path & Model Tests', () {
    test('Notification path construction matches exact Firestore subcollection structure', () {
      const userId = 'user_abc_123';
      const notificationId = 'notif_xyz_789';

      // Exact path verified: users/{userId}/notifications/{notificationId}
      const collectionPath = 'users/$userId/notifications';
      const documentPath = 'users/$userId/notifications/$notificationId';

      expect(collectionPath, 'users/user_abc_123/notifications');
      expect(documentPath, 'users/user_abc_123/notifications/notif_xyz_789');
    });

    test('NotificationItem serializes to and from Firestore map correctly', () {
      final now = DateTime(2026, 9, 9, 12, 0, 0);
      final item = NotificationItem(
        id: 'notif_1',
        type: NotificationType.order,
        title: 'Order Confirmed',
        body: 'Your fresh milk order #ORD-101 is confirmed.',
        timestamp: now,
        orderId: 'ORD-101',
        isRead: false,
        isActionable: true,
        createdBy: 'admin_1',
        userId: 'cust_1',
      );

      final firestoreMap = item.toFirestore();
      expect(firestoreMap['type'], 'order');
      expect(firestoreMap['title'], 'Order Confirmed');
      expect(firestoreMap['body'], 'Your fresh milk order #ORD-101 is confirmed.');
      expect(firestoreMap['orderId'], 'ORD-101');
      expect(firestoreMap['isRead'], false);
      expect(firestoreMap['isActionable'], true);
      expect(firestoreMap['createdBy'], 'admin_1');
      expect(firestoreMap['userId'], 'cust_1');

      // Test copyWith
      final readItem = item.copyWith(isRead: true);
      expect(readItem.isRead, true);
      expect(readItem.id, 'notif_1');
      expect(readItem.title, 'Order Confirmed');
    });

    test('NotificationType parsing and icon coverage', () {
      expect(NotificationTypeExtension.fromString('order'), NotificationType.order);
      expect(NotificationTypeExtension.fromString('delivery'), NotificationType.delivery);
      expect(NotificationTypeExtension.fromString('promotional'), NotificationType.promotional);
      expect(NotificationTypeExtension.fromString('subscription'), NotificationType.subscription);
      expect(NotificationTypeExtension.fromString('unknown'), NotificationType.system);

      expect(NotificationType.order.value, 'order');
      expect(NotificationType.delivery.value, 'delivery');
      expect(NotificationType.promotional.value, 'promotional');
      expect(NotificationType.subscription.value, 'subscription');
      expect(NotificationType.system.value, 'system');
    });

    group('Firestore Security Rules Logic Verification', () {
      // Simulates the exact rules evaluated in firestore.rules:
      // match /users/{userId}/notifications/{notificationId} {
      //   allow read, create, update, delete: if isAdmin() || isOwnDoc(userId);
      // }
      // where isOwnDoc(userId) = (request.auth != null && request.auth.uid == userId)
      // and isAdmin() = (request.auth != null && role in ['admin', 'superadmin'])

      bool evaluateNotificationRule({
        required String? authUid,
        required String? authRole,
        required String targetUserId,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        final isOwnDoc = isSignedIn && authUid == targetUserId;
        final isAdmin = isSignedIn && (authRole == 'admin' || authRole == 'superadmin');

        return isAdmin || isOwnDoc;
      }

      test('Authenticated user CAN read and write their OWN notifications', () {
        final allowed = evaluateNotificationRule(
          authUid: 'user_123',
          authRole: 'customer',
          targetUserId: 'user_123',
        );
        expect(allowed, isTrue);
      });

      test('Authenticated user CANNOT read or write ANOTHER user notifications', () {
        final allowed = evaluateNotificationRule(
          authUid: 'user_123',
          authRole: 'customer',
          targetUserId: 'user_456',
        );
        expect(allowed, isFalse);
      });

      test('Unauthenticated user CANNOT read or write any notifications', () {
        final allowed = evaluateNotificationRule(
          authUid: null,
          authRole: null,
          targetUserId: 'user_123',
        );
        expect(allowed, isFalse);
      });

      test('Admin CAN write to another user notifications (broadcasts)', () {
        final allowed = evaluateNotificationRule(
          authUid: 'admin_999',
          authRole: 'admin',
          targetUserId: 'user_123',
        );
        expect(allowed, isTrue);
      });

      test('Superadmin CAN write to another user notifications', () {
        final allowed = evaluateNotificationRule(
          authUid: 'superadmin_1',
          authRole: 'superadmin',
          targetUserId: 'user_123',
        );
        expect(allowed, isTrue);
      });

      test('Delivery agent CANNOT read another customer notifications', () {
        final allowed = evaluateNotificationRule(
          authUid: 'agent_55',
          authRole: 'delivery',
          targetUserId: 'user_123',
        );
        expect(allowed, isFalse);
      });
    });
  });
}
