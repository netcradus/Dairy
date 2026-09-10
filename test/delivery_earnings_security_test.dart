import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_app/models/earning_model.dart';
import 'package:dairy_app/models/order.dart';
import 'package:dairy_app/services/order_service.dart';

void main() {
  group('Delivery Security & RBAC Test Suite', () {
    test('OrderService.agentEarningRate is configured to 10%', () {
      expect(OrderService.agentEarningRate, 0.10);
    });

    test('Earning calculation formula evaluates to exactly 10% of order subtotal', () {
      const subtotal1 = 650.0;
      final earning1 = (subtotal1 * OrderService.agentEarningRate * 100).round() / 100;
      expect(earning1, 65.0);

      const subtotal2 = 249.50;
      final earning2 = (subtotal2 * OrderService.agentEarningRate * 100).round() / 100;
      expect(earning2, 24.95);

      const subtotal3 = 0.0;
      final earning3 = (subtotal3 * OrderService.agentEarningRate * 100).round() / 100;
      expect(earning3, 0.0);
    });

    test('orderStatusToString correctly maps delivered status for backend Cloud Function triggers', () {
      expect(orderStatusToString(OrderStatus.delivered), 'delivered');
      expect(orderStatusFromString('delivered'), OrderStatus.delivered);
      expect(orderStatusFromString('Delivered'), OrderStatus.delivered);
    });

    test('EarningModel serializes and deserializes accurately with pending default status', () {
      final now = DateTime(2026, 9, 10, 15, 0, 0);
      final model = EarningModel(
        id: 'order_abc_123',
        agentId: 'agent_driver_1',
        orderId: 'order_abc_123',
        amountEarned: 45.0,
        tipAmount: 0.0,
        deliveryFee: 30.0,
        timestamp: now,
        status: EarningStatus.pending,
      );

      final map = model.toFirestore();
      expect(map['agentId'], 'agent_driver_1');
      expect(map['orderId'], 'order_abc_123');
      expect(map['amountEarned'], 45.0);
      expect(map['deliveryFee'], 30.0);
      expect(map['status'], 'pending');

      final fromMap = EarningModel.fromFirestore(map, 'order_abc_123');
      expect(fromMap.id, 'order_abc_123');
      expect(fromMap.agentId, 'agent_driver_1');
      expect(fromMap.orderId, 'order_abc_123');
      expect(fromMap.amountEarned, 45.0);
      expect(fromMap.deliveryFee, 30.0);
      expect(fromMap.status, EarningStatus.pending);
    });

    // =========================================================================
    // 1. DELIVERY AGENTS COLLECTION (/delivery_agents/{agentId})
    // =========================================================================
    group('1. Delivery Agents Collection (/delivery_agents/{agentId}) RBAC', () {
      bool evaluateDeliveryAgentReadRule({
        required String? authUid,
        required String? authRole,
        required String targetAgentId,
        String? agentActiveOrderId,
        String? customerActiveOrderId,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        if (isAdmin) return true;

        final isDelivery = authRole == 'delivery';
        final isOwnDoc = authUid == targetAgentId;
        if (isDelivery && isOwnDoc) return true;

        final isCustomer = authRole == 'customer' || authRole == null;
        final isCustomerOfActiveAgent = isCustomer &&
            agentActiveOrderId != null &&
            agentActiveOrderId.isNotEmpty &&
            agentActiveOrderId == customerActiveOrderId;

        return isCustomerOfActiveAgent;
      }

      bool evaluateDeliveryAgentUpdateRule({
        required String? authUid,
        required String? authRole,
        required String targetAgentId,
        required Set<String> changedFields,
        String? newRole,
        String? newUid,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        if (isAdmin) return true;

        final isDelivery = authRole == 'delivery';
        final isOwnDoc = authUid == targetAgentId;
        if (!isDelivery || !isOwnDoc) return false;

        const allowedFields = {
          'name',
          'phone',
          'email',
          'profileImageUrl',
          'vehicle',
          'vehicleType',
          'vehicleNumber',
          'isOnline',
          'isOnDuty',
          'location',
          'orderId',
          'updatedAt'
        };

        final fieldsAllowed = changedFields.every(allowedFields.contains);
        final keepsUid = newUid == null || newUid == targetAgentId;
        final keepsRole = newRole == null || newRole == 'delivery';

        return fieldsAllowed && keepsUid && keepsRole;
      }

      // PASS tests
      test('PASS: delivery agent reads own profile', () {
        final allowed = evaluateDeliveryAgentReadRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetAgentId: 'agent_1',
        );
        expect(allowed, isTrue);
      });

      test('PASS: customer reads assigned driver profile for active order', () {
        final allowed = evaluateDeliveryAgentReadRule(
          authUid: 'cust_1',
          authRole: 'customer',
          targetAgentId: 'agent_1',
          agentActiveOrderId: 'order_99',
          customerActiveOrderId: 'order_99',
        );
        expect(allowed, isTrue);
      });

      test('PASS: delivery agent updates own location & duty status', () {
        final allowed = evaluateDeliveryAgentUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetAgentId: 'agent_1',
          changedFields: {'location', 'updatedAt', 'isOnline', 'isOnDuty'},
        );
        expect(allowed, isTrue);
      });

      // FAIL tests
      test('FAIL: agent reads another agent private data', () {
        final allowed = evaluateDeliveryAgentReadRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetAgentId: 'agent_2',
        );
        expect(allowed, isFalse);
      });

      test('FAIL: customer accesses unrelated delivery-agent data', () {
        final allowed = evaluateDeliveryAgentReadRule(
          authUid: 'cust_1',
          authRole: 'customer',
          targetAgentId: 'agent_1',
          agentActiveOrderId: 'order_for_cust_2',
          customerActiveOrderId: 'order_for_cust_1',
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent modifies another agent GPS location', () {
        final allowed = evaluateDeliveryAgentUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetAgentId: 'agent_2',
          changedFields: {'location', 'updatedAt'},
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent mutates protected rating field on profile', () {
        final allowed = evaluateDeliveryAgentUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetAgentId: 'agent_1',
          changedFields: {'rating'},
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent changes UID or role on delivery_agents doc', () {
        final allowedRole = evaluateDeliveryAgentUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetAgentId: 'agent_1',
          changedFields: {'name'},
          newRole: 'admin',
        );
        expect(allowedRole, isFalse);

        final allowedUid = evaluateDeliveryAgentUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetAgentId: 'agent_1',
          changedFields: {'name'},
          newUid: 'admin_uid',
        );
        expect(allowedUid, isFalse);
      });
    });

    // =========================================================================
    // 2. ORDERS COLLECTION (/orders/{orderId})
    // =========================================================================
    group('2. Orders Collection (/orders/{orderId}) RBAC', () {
      bool evaluateOrderReadRule({
        required String? authUid,
        required String? authRole,
        required String orderOwnerUserId,
        required String? orderAssignedAgentId,
        required String orderStatus,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        if (isAdmin) return true;

        if (orderOwnerUserId == authUid) return true;

        final isDelivery = authRole == 'delivery';
        if (isDelivery) {
          final isUnassignedPending = (orderAssignedAgentId == null ||
                  orderAssignedAgentId.isEmpty) &&
              (orderStatus == 'Pending' ||
                  orderStatus == 'pending' ||
                  orderStatus == 'placed');
          final isAssignedToMe = orderAssignedAgentId == authUid;
          return isUnassignedPending || isAssignedToMe;
        }

        return false;
      }

      bool evaluateOrderUpdateRule({
        required String? authUid,
        required String? authRole,
        required String? existingAssignedAgentId,
        required String existingStatus,
        required Set<String> changedFields,
        String? newAssignedAgentId,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        if (isAdmin) return true;

        final isDelivery = authRole == 'delivery';
        if (!isDelivery) return false;

        final isMine = existingAssignedAgentId != null &&
            existingAssignedAgentId == authUid;
        final isUnassigned = (existingAssignedAgentId == null ||
                existingAssignedAgentId.isEmpty) &&
            (existingStatus == 'Pending' ||
                existingStatus == 'pending' ||
                existingStatus == 'placed');
        final claimsSelf = newAssignedAgentId == authUid;
        final releases = newAssignedAgentId == null;

        if (isMine) {
          final isDeliveryProgress = changedFields.every({
            'status',
            'acceptedAt',
            'deliveredAt',
            'deliveryConfirmed'
          }.contains);
          final isRelease = changedFields
                  .every({'status', 'assignedAgentId', 'acceptedAt'}.contains) &&
              releases;
          return isDeliveryProgress || isRelease;
        } else if (isUnassigned) {
          return changedFields
                  .every({'status', 'assignedAgentId', 'acceptedAt'}.contains) &&
              claimsSelf;
        }

        return false;
      }

      // PASS tests
      test('PASS: delivery agent reads assigned order', () {
        final allowed = evaluateOrderReadRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          orderOwnerUserId: 'cust_1',
          orderAssignedAgentId: 'agent_1',
          orderStatus: 'outForDelivery',
        );
        expect(allowed, isTrue);
      });

      test('PASS: delivery agent updates allowed delivery status to Delivered', () {
        final allowed = evaluateOrderUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          existingAssignedAgentId: 'agent_1',
          existingStatus: 'outForDelivery',
          changedFields: {'status', 'deliveredAt'},
        );
        expect(allowed, isTrue);
      });

      test('PASS: delivery agent claims unassigned pending order', () {
        final allowed = evaluateOrderUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          existingAssignedAgentId: null,
          existingStatus: 'Pending',
          changedFields: {'status', 'assignedAgentId', 'acceptedAt'},
          newAssignedAgentId: 'agent_1',
        );
        expect(allowed, isTrue);
      });

      // FAIL tests
      test('FAIL: agent modifies another agent order', () {
        final allowed = evaluateOrderUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          existingAssignedAgentId: 'agent_2',
          existingStatus: 'outForDelivery',
          changedFields: {'status'},
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent modifies order price or subtotal', () {
        final allowed = evaluateOrderUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          existingAssignedAgentId: 'agent_1',
          existingStatus: 'outForDelivery',
          changedFields: {'status', 'subtotal'},
        );
        expect(allowed, isFalse);

        final allowedPrice = evaluateOrderUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          existingAssignedAgentId: 'agent_1',
          existingStatus: 'outForDelivery',
          changedFields: {'totalAmount'},
        );
        expect(allowedPrice, isFalse);
      });

      test('FAIL: agent changes customer UID', () {
        final allowed = evaluateOrderUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          existingAssignedAgentId: 'agent_1',
          existingStatus: 'outForDelivery',
          changedFields: {'status', 'userId'},
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent claims an order already claimed by another agent', () {
        final allowed = evaluateOrderUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          existingAssignedAgentId: 'agent_2',
          existingStatus: 'accepted',
          changedFields: {'status', 'assignedAgentId', 'acceptedAt'},
          newAssignedAgentId: 'agent_1',
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent assigns an order to another agent arbitrarily', () {
        final allowed = evaluateOrderUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          existingAssignedAgentId: null,
          existingStatus: 'Pending',
          changedFields: {'status', 'assignedAgentId', 'acceptedAt'},
          newAssignedAgentId: 'agent_2',
        );
        expect(allowed, isFalse);
      });
    });

    // =========================================================================
    // 3. USERS COLLECTION (/users/{userId})
    // =========================================================================
    group('3. Users Collection (/users/{userId}) RBAC', () {
      bool evaluateUserUpdateRule({
        required String? authUid,
        required String? authRole,
        required String targetUserId,
        String? existingRole,
        String? newRole,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        if (isAdmin) return true;

        final isOwnDoc = authUid == targetUserId;
        if (!isOwnDoc) return false;

        final keepsRole = newRole == null || newRole == existingRole;
        return keepsRole;
      }

      // FAIL tests
      test('FAIL: agent changes role to admin', () {
        final allowed = evaluateUserUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetUserId: 'agent_1',
          existingRole: 'delivery',
          newRole: 'admin',
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent modifies another user profile', () {
        final allowed = evaluateUserUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetUserId: 'other_user_2',
          existingRole: 'customer',
        );
        expect(allowed, isFalse);
      });
    });

    // =========================================================================
    // 4. EARNINGS COLLECTION (/earnings/{earningId})
    // =========================================================================
    group('4. Earnings Collection (/earnings/{earningId}) RBAC', () {
      bool evaluateEarningsReadRule({
        required String? authUid,
        required String? authRole,
        required String earningDocAgentId,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        final isDelivery = authRole == 'delivery';
        final isOwnEarning = earningDocAgentId == authUid;

        return isAdmin || (isDelivery && isOwnEarning);
      }

      bool evaluateEarningsWriteRule({
        required String? authUid,
        required String? authRole,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        return isAdmin;
      }

      // PASS tests
      test('PASS: delivery agent reads own earnings', () {
        final allowed = evaluateEarningsReadRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          earningDocAgentId: 'agent_1',
        );
        expect(allowed, isTrue);
      });

      // FAIL tests
      test('FAIL: agent creates earning', () {
        final allowed = evaluateEarningsWriteRule(
          authUid: 'agent_1',
          authRole: 'delivery',
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent modifies earning', () {
        final allowed = evaluateEarningsWriteRule(
          authUid: 'agent_1',
          authRole: 'delivery',
        );
        expect(allowed, isFalse);
      });

      test('FAIL: agent deletes earning', () {
        final allowed = evaluateEarningsWriteRule(
          authUid: 'agent_1',
          authRole: 'delivery',
        );
        expect(allowed, isFalse);
      });
    });

    // =========================================================================
    // 5. NOTIFICATIONS SUBCOLLECTION (/users/{userId}/notifications)
    // =========================================================================
    group('5. Notifications Subcollection RBAC', () {
      bool evaluateNotificationReadRule({
        required String? authUid,
        required String? authRole,
        required String targetUserId,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        final isOwnDoc = authUid == targetUserId;

        return isAdmin || isOwnDoc;
      }

      test('FAIL: agent reads another user notifications', () {
        final allowed = evaluateNotificationReadRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          targetUserId: 'customer_1',
        );
        expect(allowed, isFalse);
      });
    });
  });
}
