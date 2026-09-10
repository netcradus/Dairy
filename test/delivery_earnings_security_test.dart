import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_app/models/earning_model.dart';
import 'package:dairy_app/models/order.dart';
import 'package:dairy_app/services/order_service.dart';

void main() {
  group('Delivery Earnings Security & Calculations Test Suite', () {
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

    group('Firestore Security Rules Logic Verification for /earnings/{earningId}', () {
      // Simulates the exact rules in firestore.rules:
      // match /earnings/{earningId} {
      //   allow read: if isAdmin() || (isDelivery() && resource.data.agentId == request.auth.uid);
      //   allow write: if isAdmin();
      // }
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

      test('Delivery agent CAN read their own earnings', () {
        final allowed = evaluateEarningsReadRule(
          authUid: 'agent_ramesh',
          authRole: 'delivery',
          earningDocAgentId: 'agent_ramesh',
        );
        expect(allowed, isTrue);
      });

      test('Delivery agent CANNOT read another agent earnings', () {
        final allowed = evaluateEarningsReadRule(
          authUid: 'agent_ramesh',
          authRole: 'delivery',
          earningDocAgentId: 'agent_suresh',
        );
        expect(allowed, isFalse);
      });

      test('Customer CANNOT read any earnings', () {
        final allowed = evaluateEarningsReadRule(
          authUid: 'customer_123',
          authRole: 'customer',
          earningDocAgentId: 'agent_ramesh',
        );
        expect(allowed, isFalse);
      });

      test('Unauthenticated user CANNOT read any earnings', () {
        final allowed = evaluateEarningsReadRule(
          authUid: null,
          authRole: null,
          earningDocAgentId: 'agent_ramesh',
        );
        expect(allowed, isFalse);
      });

      test('Admin CAN read any delivery agent earnings', () {
        final allowed = evaluateEarningsReadRule(
          authUid: 'admin_boss',
          authRole: 'admin',
          earningDocAgentId: 'agent_ramesh',
        );
        expect(allowed, isTrue);
      });

      test('Delivery agent CANNOT write, create, or update earnings from client', () {
        final allowed = evaluateEarningsWriteRule(
          authUid: 'agent_ramesh',
          authRole: 'delivery',
        );
        expect(allowed, isFalse);
      });

      test('Customer CANNOT write, create, or update earnings from client', () {
        final allowed = evaluateEarningsWriteRule(
          authUid: 'customer_123',
          authRole: 'customer',
        );
        expect(allowed, isFalse);
      });

      test('Only Admin can write or update earnings documents via client (otherwise Cloud Function Admin SDK)', () {
        final allowed = evaluateEarningsWriteRule(
          authUid: 'admin_boss',
          authRole: 'admin',
        );
        expect(allowed, isTrue);
      });
    });

    group('Order Assignment & Delivery Status Transition Rules Simulation', () {
      // Simulates canUpdateAssignedOrder() from firestore.rules:
      // allows updating status to delivered only if isDelivery() AND order is assigned to this agent
      bool evaluateOrderDeliveredUpdateRule({
        required String? authUid,
        required String? authRole,
        required String? orderAssignedAgentId,
        required Set<String> changedFields,
      }) {
        final isSignedIn = authUid != null && authUid.isNotEmpty;
        if (!isSignedIn) return false;

        final isAdmin = authRole == 'admin' || authRole == 'superadmin';
        if (isAdmin) return true;

        final isDelivery = authRole == 'delivery';
        if (!isDelivery) return false;

        final isMine = orderAssignedAgentId != null && orderAssignedAgentId == authUid;
        if (!isMine) return false;

        const allowedKeys = {'status', 'acceptedAt', 'deliveredAt', 'deliveryConfirmed'};
        return changedFields.every(allowedKeys.contains);
      }

      test('Assigned delivery agent CAN mark order as delivered', () {
        final allowed = evaluateOrderDeliveredUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          orderAssignedAgentId: 'agent_1',
          changedFields: {'status'},
        );
        expect(allowed, isTrue);
      });

      test('Unassigned delivery agent CANNOT mark another agent order as delivered', () {
        final allowed = evaluateOrderDeliveredUpdateRule(
          authUid: 'agent_2',
          authRole: 'delivery',
          orderAssignedAgentId: 'agent_1',
          changedFields: {'status'},
        );
        expect(allowed, isFalse);
      });

      test('Delivery agent CANNOT manipulate order totals or agentId while marking delivered', () {
        final allowed = evaluateOrderDeliveredUpdateRule(
          authUid: 'agent_1',
          authRole: 'delivery',
          orderAssignedAgentId: 'agent_1',
          changedFields: {'status', 'subtotal'},
        );
        expect(allowed, isFalse);
      });
    });
  });
}
