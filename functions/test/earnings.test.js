const { test, describe, beforeEach } = require("node:test");
const assert = require("node:assert/strict");
const { processOrderDeliveredEarning, AGENT_EARNING_RATE } = require("../index");

// Lightweight in-memory Firestore mock for unit testing Cloud Function business logic
function createMockFirestore() {
  const store = new Map(); // key: "collection/id", value: data

  const db = {
    _store: store,
    collection(colName) {
      return {
        doc(docId) {
          const docKey = `${colName}/${docId}`;
          return {
            id: docId,
            async get() {
              const data = store.get(docKey);
              return {
                id: docId,
                exists: data !== undefined,
                data() {
                  return data ? JSON.parse(JSON.stringify(data)) : undefined;
                },
              };
            },
            async set(data) {
              store.set(docKey, JSON.parse(JSON.stringify(data)));
            },
          };
        },
      };
    },
    async runTransaction(updateFn) {
      const transaction = {
        async get(docRef) {
          return await docRef.get();
        },
        set(docRef, data) {
          const docKey = `earnings/${docRef.id}`;
          store.set(docKey, JSON.parse(JSON.stringify(data)));
        },
      };
      return await updateFn(transaction);
    },
  };

  return db;
}

describe("Delivery Earnings Backend Unit Tests", () => {
  let db;

  beforeEach(() => {
    db = createMockFirestore();

    // Seed mock users
    db._store.set("users/delivery_agent_1", {
      uid: "delivery_agent_1",
      role: "delivery",
      name: "Ramesh Delivery",
    });
    db._store.set("users/admin_user_1", {
      uid: "admin_user_1",
      role: "admin",
      name: "Suresh Admin",
    });
    db._store.set("users/customer_1", {
      uid: "customer_1",
      role: "customer",
      name: "Pooja Customer",
    });
  });

  test("AGENT_EARNING_RATE is configured to exactly 10%", () => {
    assert.equal(AGENT_EARNING_RATE, 0.10);
  });

  test("Successfully creates earning of 10% subtotal on order delivery", async () => {
    const orderId = "order_1001";
    const before = { status: "outForDelivery", assignedAgentId: "delivery_agent_1", subtotal: 800, deliveryCharge: 30 };
    const after = { status: "delivered", assignedAgentId: "delivery_agent_1", subtotal: 800, deliveryCharge: 30 };

    const result = await processOrderDeliveredEarning(db, before, after, orderId);

    assert.equal(result.status, "created");
    assert.equal(result.amountEarned, 80.0); // 10% of 800
    assert.equal(result.agentId, "delivery_agent_1");
    assert.equal(result.orderId, orderId);

    // Verify written document in mock Firestore
    const stored = db._store.get(`earnings/${orderId}`);
    assert.ok(stored, "Earning document should exist");
    assert.equal(stored.amountEarned, 80.0);
    assert.equal(stored.agentId, "delivery_agent_1");
    assert.equal(stored.deliveryFee, 30);
    assert.equal(stored.status, "pending");
  });

  test("Idempotency: Repeated trigger invocation does NOT create duplicate or overwrite earning", async () => {
    const orderId = "order_1002";
    const before = { status: "outForDelivery", assignedAgentId: "delivery_agent_1", subtotal: 450 };
    const after = { status: "delivered", assignedAgentId: "delivery_agent_1", subtotal: 450 };

    // First call
    const firstResult = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(firstResult.status, "created");
    assert.equal(firstResult.amountEarned, 45.0);

    // Second call with retry / duplicate event
    const secondResult = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(secondResult.status, "skipped_duplicate");

    // Check count of records for this order: doc ID is orderId, so exactly one exists
    const stored = db._store.get(`earnings/${orderId}`);
    assert.equal(stored.amountEarned, 45.0);
  });

  test("Skips execution if status was already delivered (no transition)", async () => {
    const orderId = "order_1003";
    const before = { status: "delivered", assignedAgentId: "delivery_agent_1", subtotal: 500 };
    const after = { status: "delivered", assignedAgentId: "delivery_agent_1", subtotal: 500 };

    const result = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(result.status, "skipped");
    assert.equal(result.reason, "not_delivered_transition");
  });

  test("Skips execution if target status is not delivered", async () => {
    const orderId = "order_1004";
    const before = { status: "placed", assignedAgentId: "delivery_agent_1", subtotal: 500 };
    const after = { status: "confirmed", assignedAgentId: "delivery_agent_1", subtotal: 500 };

    const result = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(result.status, "skipped");
    assert.equal(result.reason, "not_delivered_transition");
  });

  test("Skips earning if assignedAgentId is missing or empty", async () => {
    const orderId = "order_1005";
    const before = { status: "outForDelivery", subtotal: 300 };
    const after = { status: "delivered", assignedAgentId: "", subtotal: 300 };

    const result = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(result.status, "skipped");
    assert.equal(result.reason, "missing_assigned_agent");
  });

  test("Rejects earning if assignedAgentId belongs to a customer (not a delivery agent)", async () => {
    const orderId = "order_1006";
    const before = { status: "outForDelivery", assignedAgentId: "customer_1", subtotal: 600 };
    const after = { status: "delivered", assignedAgentId: "customer_1", subtotal: 600 };

    const result = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(result.status, "skipped");
    assert.equal(result.reason, "invalid_delivery_agent");

    // Verify document was NOT created
    assert.equal(db._store.get(`earnings/${orderId}`), undefined);
  });

  test("Rejects earning if assignedAgentId does not exist in the system", async () => {
    const orderId = "order_1007";
    const before = { status: "outForDelivery", assignedAgentId: "unknown_agent_999", subtotal: 600 };
    const after = { status: "delivered", assignedAgentId: "unknown_agent_999", subtotal: 600 };

    const result = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(result.status, "skipped");
    assert.equal(result.reason, "invalid_delivery_agent");
  });

  test("Accepts agent registered in delivery_agents collection even if not yet in users", async () => {
    const orderId = "order_1008";
    db._store.set("delivery_agents/new_agent_42", {
      id: "new_agent_42",
      name: "New Driver",
    });

    const before = { status: "outForDelivery", assignedAgentId: "new_agent_42", subtotal: 350 };
    const after = { status: "delivered", assignedAgentId: "new_agent_42", subtotal: 350 };

    const result = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(result.status, "created");
    assert.equal(result.amountEarned, 35.0);
  });

  test("Falls back to totalAmount if subtotal is missing", async () => {
    const orderId = "order_1009";
    const before = { status: "outForDelivery", assignedAgentId: "delivery_agent_1", totalAmount: 250 };
    const after = { status: "delivered", assignedAgentId: "delivery_agent_1", totalAmount: 250 };

    const result = await processOrderDeliveredEarning(db, before, after, orderId);
    assert.equal(result.status, "created");
    assert.equal(result.amountEarned, 25.0);
  });
});
