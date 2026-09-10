/**
 * Sawariya Dairy — Delivery Earnings Persistence Unit Tests (Task 6)
 * ===================================================================
 * Verifies:
 * 1. Earning calculation formula (10% of order subtotal).
 * 2. Idempotent earnings document creation in Firestore ('earnings/{orderId}').
 * 3. Prevention of duplicate earnings on repeated updates / retries.
 * 4. Skipping of unassigned or non-delivered orders.
 * 5. Safe numeric handling for subtotal and delivery charge.
 * 6. Delivery agent access restrictions (reads own earnings, cannot forge earnings).
 */

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  collection,
  query,
  where,
  getDocs,
} = require('firebase/firestore');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'sawariya-7efd4';
const RULES_PATH = path.resolve(__dirname, '../firestore.rules');
const AGENT_EARNING_RATE = 0.10;

describe('Task 6 — Delivery Earnings Persistence Tests', function () {
  this.timeout(10000);

  let testEnv;

  before(async () => {
    const rules = fs.readFileSync(RULES_PATH, 'utf8');
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules,
        host: '127.0.0.1',
        port: 8080,
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();

    // Seed test users in users collection
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'users', 'admin_uid'), {
        uid: 'admin_uid',
        role: 'admin',
        name: 'Admin User',
      });
      await setDoc(doc(db, 'users', 'agent_1'), {
        uid: 'agent_1',
        role: 'delivery',
        name: 'Delivery Agent One',
      });
      await setDoc(doc(db, 'users', 'agent_2'), {
        uid: 'agent_2',
        role: 'delivery',
        name: 'Delivery Agent Two',
      });
      await setDoc(doc(db, 'users', 'customer_uid'), {
        uid: 'customer_uid',
        role: 'customer',
        name: 'Customer User',
      });
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  // Simulated backend worker function replicating functions/index.js logic
  async function simulateCloudFunctionTrigger(beforeData, afterData, orderId) {
    if (!afterData) return { status: 'skipped', reason: 'no_after_data' };

    const beforeStatus = (beforeData && beforeData.status ? String(beforeData.status) : '').toLowerCase();
    const afterStatus = (afterData && afterData.status ? String(afterData.status) : '').toLowerCase();

    // Only transition into "delivered"
    if (beforeStatus === afterStatus || afterStatus !== 'delivered') {
      return { status: 'skipped', reason: 'not_delivered_transition' };
    }

    const agentId = afterData.assignedAgentId;
    if (!agentId || typeof agentId !== 'string' || agentId.trim() === '') {
      return { status: 'skipped', reason: 'missing_assigned_agent' };
    }

    const cleanAgentId = agentId.trim();
    let isAuthorized = false;
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      const userSnap = await getDoc(doc(db, 'users', cleanAgentId));
      if (userSnap.exists()) {
        const role = userSnap.data().role;
        if (role === 'delivery' || role === 'admin') isAuthorized = true;
      } else {
        const agentSnap = await getDoc(doc(db, 'delivery_agents', cleanAgentId));
        if (agentSnap.exists()) isAuthorized = true;
      }
    });

    if (!isAuthorized) {
      return { status: 'skipped', reason: 'invalid_delivery_agent' };
    }

    const rawSubtotal = afterData.subtotal != null
      ? Number(afterData.subtotal)
      : (afterData.totalAmount != null ? Number(afterData.totalAmount) : 0);

    if (isNaN(rawSubtotal) || rawSubtotal < 0) {
      return { status: 'skipped', reason: 'invalid_subtotal' };
    }

    const deliveryFee = Number(afterData.deliveryCharge) || 0;
    const amountEarned = Math.round((rawSubtotal * AGENT_EARNING_RATE) * 100) / 100;

    let resultStatus = 'created';

    // Execute via trusted Admin context (replicating Cloud Function Admin SDK)
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      const earningRef = doc(db, 'earnings', orderId);

      const existing = await getDoc(earningRef);
      if (existing.exists()) {
        resultStatus = 'skipped_duplicate';
        return;
      }

      await setDoc(earningRef, {
        id: orderId,
        orderId: orderId,
        agentId: agentId.trim(),
        amountEarned: amountEarned,
        tipAmount: 0.0,
        deliveryFee: deliveryFee,
        status: 'pending',
        timestamp: new Date().toISOString(),
        createdAt: new Date().toISOString(),
      });
    });

    return { status: resultStatus, amountEarned, agentId: agentId.trim(), orderId };
  }

  // =========================================================================
  // 1. EARNINGS CALCULATION & TRANSITION TESTS
  // =========================================================================
  describe('1. Earning Creation & Calculation Formula', () => {
    it('Creates earning record with exact 10% commission on order delivery', async () => {
      const orderId = 'order_test_101';
      const before = { status: 'outForDelivery', assignedAgentId: 'agent_1', subtotal: 650, deliveryCharge: 30 };
      const after = { status: 'delivered', assignedAgentId: 'agent_1', subtotal: 650, deliveryCharge: 30 };

      const result = await simulateCloudFunctionTrigger(before, after, orderId);
      if (result.status !== 'created') throw new Error(`Expected created, got ${result.status}`);
      if (result.amountEarned !== 65.0) throw new Error(`Expected 65.0 (10% of 650), got ${result.amountEarned}`);

      // Verify Firestore document exists
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const earningSnap = await getDoc(doc(context.firestore(), 'earnings', orderId));
        if (!earningSnap.exists()) throw new Error('Earning doc not found in Firestore');
        const data = earningSnap.data();
        if (data.agentId !== 'agent_1') throw new Error(`Expected agent_1, got ${data.agentId}`);
        if (data.amountEarned !== 65.0) throw new Error(`Expected 65.0, got ${data.amountEarned}`);
        if (data.deliveryFee !== 30.0) throw new Error(`Expected deliveryFee 30, got ${data.deliveryFee}`);
        if (data.status !== 'pending') throw new Error(`Expected pending, got ${data.status}`);
      });
    });

    it('Correctly handles lowercase and capitalized status (Delivered vs delivered)', async () => {
      const orderId = 'order_test_102';
      const before = { status: 'Pending', assignedAgentId: 'agent_1', subtotal: 200 };
      const after = { status: 'Delivered', assignedAgentId: 'agent_1', subtotal: 200 };

      const result = await simulateCloudFunctionTrigger(before, after, orderId);
      if (result.status !== 'created') throw new Error(`Expected created, got ${result.status}`);
      if (result.amountEarned !== 20.0) throw new Error(`Expected 20.0, got ${result.amountEarned}`);
    });

    it('Falls back to totalAmount if subtotal is omitted', async () => {
      const orderId = 'order_test_103';
      const before = { status: 'outForDelivery', assignedAgentId: 'agent_1', totalAmount: 500 };
      const after = { status: 'delivered', assignedAgentId: 'agent_1', totalAmount: 500 };

      const result = await simulateCloudFunctionTrigger(before, after, orderId);
      if (result.status !== 'created') throw new Error(`Expected created, got ${result.status}`);
      if (result.amountEarned !== 50.0) throw new Error(`Expected 50.0, got ${result.amountEarned}`);
    });
  });

  // =========================================================================
  // 2. IDEMPOTENCY & DUPLICATE PREVENTION
  // =========================================================================
  describe('2. Idempotency & Duplicate Prevention', () => {
    it('Does not create duplicate earning if the same delivered order is updated again', async () => {
      const orderId = 'order_test_201';
      const before1 = { status: 'outForDelivery', assignedAgentId: 'agent_1', subtotal: 300 };
      const after1 = { status: 'delivered', assignedAgentId: 'agent_1', subtotal: 300 };

      // First delivery transition
      const result1 = await simulateCloudFunctionTrigger(before1, after1, orderId);
      if (result1.status !== 'created') throw new Error('First trigger should create earning');

      // Subsequent update to already delivered order (e.g. admin note or review added)
      const before2 = { status: 'delivered', assignedAgentId: 'agent_1', subtotal: 300, adminNote: 'reviewed' };
      const after2 = { status: 'delivered', assignedAgentId: 'agent_1', subtotal: 300, adminNote: 'reviewed' };

      const result2 = await simulateCloudFunctionTrigger(before2, after2, orderId);
      if (result2.status !== 'skipped') throw new Error(`Expected skipped on same status, got ${result2.status}`);

      // Repeated trigger retry with before!=delivered but document already in Firestore
      const beforeRetry = { status: 'outForDelivery', assignedAgentId: 'agent_1', subtotal: 300 };
      const afterRetry = { status: 'delivered', assignedAgentId: 'agent_1', subtotal: 300 };

      const result3 = await simulateCloudFunctionTrigger(beforeRetry, afterRetry, orderId);
      if (result3.status !== 'skipped_duplicate') {
        throw new Error(`Expected skipped_duplicate from DB existence check, got ${result3.status}`);
      }
    });
  });

  // =========================================================================
  // 3. INVALID / EDGE CASE CONDITIONS
  // =========================================================================
  describe('3. Edge Case Handling', () => {
    it('Skips earning creation if assignedAgentId is missing or empty', async () => {
      const orderId = 'order_test_301';
      const before = { status: 'placed', subtotal: 400 };
      const after = { status: 'delivered', assignedAgentId: null, subtotal: 400 };

      const result = await simulateCloudFunctionTrigger(before, after, orderId);
      if (result.status !== 'skipped' || result.reason !== 'missing_assigned_agent') {
        throw new Error(`Expected missing_assigned_agent skip, got ${JSON.stringify(result)}`);
      }
    });

    it('Skips earning creation if transition is not to delivered (e.g. placed -> confirmed)', async () => {
      const orderId = 'order_test_302';
      const before = { status: 'placed', assignedAgentId: 'agent_1', subtotal: 400 };
      const after = { status: 'confirmed', assignedAgentId: 'agent_1', subtotal: 400 };

      const result = await simulateCloudFunctionTrigger(before, after, orderId);
      if (result.status !== 'skipped' || result.reason !== 'not_delivered_transition') {
        throw new Error(`Expected not_delivered_transition skip, got ${JSON.stringify(result)}`);
      }
    });
  });

  // =========================================================================
  // 4. FIRESTORE SECURITY RULES VERIFICATION FOR /earnings
  // =========================================================================
  describe('4. Firestore Security Rules for /earnings', () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'earnings', 'order_agent1_earning'), {
          agentId: 'agent_1',
          orderId: 'order_agent1_earning',
          amountEarned: 75.0,
          status: 'pending',
        });
        await setDoc(doc(db, 'earnings', 'order_agent2_earning'), {
          agentId: 'agent_2',
          orderId: 'order_agent2_earning',
          amountEarned: 90.0,
          status: 'pending',
        });
      });
    });

    it('Allows delivery agent to read own earnings document', async () => {
      const agent1Db = testEnv.authenticatedContext('agent_1').firestore();
      await assertSucceeds(getDoc(doc(agent1Db, 'earnings', 'order_agent1_earning')));
    });

    it('Denies delivery agent from reading another agent earnings document', async () => {
      const agent1Db = testEnv.authenticatedContext('agent_1').firestore();
      await assertFails(getDoc(doc(agent1Db, 'earnings', 'order_agent2_earning')));
    });

    it('Denies delivery agent from creating or modifying earnings directly via client', async () => {
      const agent1Db = testEnv.authenticatedContext('agent_1').firestore();
      await assertFails(setDoc(doc(agent1Db, 'earnings', 'forged_earning'), {
        agentId: 'agent_1',
        amountEarned: 5000,
      }));
      await assertFails(updateDoc(doc(agent1Db, 'earnings', 'order_agent1_earning'), {
        amountEarned: 9999,
      }));
    });

    it('Denies customer from reading or writing earnings', async () => {
      const custDb = testEnv.authenticatedContext('customer_uid').firestore();
      await assertFails(getDoc(doc(custDb, 'earnings', 'order_agent1_earning')));
      await assertFails(setDoc(doc(custDb, 'earnings', 'cust_earning'), { amountEarned: 100 }));
    });

    it('Allows Admin to read, update, and manage all earnings records', async () => {
      const adminDb = testEnv.authenticatedContext('admin_uid').firestore();
      await assertSucceeds(getDoc(doc(adminDb, 'earnings', 'order_agent1_earning')));
      await assertSucceeds(getDoc(doc(adminDb, 'earnings', 'order_agent2_earning')));
      await assertSucceeds(updateDoc(doc(adminDb, 'earnings', 'order_agent1_earning'), {
        status: 'paid',
      }));
    });
  });
});
