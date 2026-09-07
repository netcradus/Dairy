const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();

// Agent commission rate applied to the order subtotal. Must stay in sync with
// OrderService.agentEarningRate (0.10) in the Flutter app.
const AGENT_EARNING_RATE = 0.10;

/**
 * When an order transitions to "delivered", credit the assigned agent's
 * earnings by writing an idempotent document to the "earnings" collection.
 * The document id is the order id, so retries or duplicate status updates
 * cannot create duplicate earning records.
 */
exports.logEarningOnDelivered = onDocumentUpdated(
  { document: "orders/{orderId}" },
  async (event) => {
    if (!event.data || !event.data.after) {
      console.warn("No document data found in event; skipping.");
      return;
    }

    const before = event.data.before ? event.data.before.data() : null;
    const after = event.data.after.data();
    const orderId = event.params.orderId;

    if (!after) {
      console.warn(`Order ${orderId} has no post-update data; skipping.`);
      return;
    }

    const beforeStatus = (before && before.status ? String(before.status) : "").toLowerCase();
    const afterStatus = (after && after.status ? String(after.status) : "").toLowerCase();

    // Only act on a transition INTO "delivered".
    // Skip if status did not change, or if target status is not delivered.
    if (beforeStatus === afterStatus || afterStatus !== "delivered") {
      return;
    }

    const agentId = after.assignedAgentId;
    if (!agentId || typeof agentId !== "string" || agentId.trim() === "") {
      console.log(
        `Order ${orderId} delivered with no valid assignedAgentId; skipping earnings.`
      );
      return;
    }

    const rawSubtotal = after.subtotal != null
      ? Number(after.subtotal)
      : (after.totalAmount != null ? Number(after.totalAmount) : 0);

    if (isNaN(rawSubtotal) || rawSubtotal < 0) {
      console.warn(`Invalid subtotal for order ${orderId}; skipping earnings.`);
      return;
    }

    const deliveryFee = Number(after.deliveryCharge) || 0;
    // Calculate 10% commission on subtotal with 2 decimal precision
    const amountEarned = Math.round((rawSubtotal * AGENT_EARNING_RATE) * 100) / 100;

    const db = getFirestore();
    const earningRef = db.collection("earnings").doc(orderId);

    // Idempotency check: Verify whether earning record already exists
    const existingDoc = await earningRef.get();
    if (existingDoc.exists) {
      console.log(
        `Earning record already exists for order ${orderId}; skipping duplicate creation.`
      );
      return;
    }

    await earningRef.set({
      id: orderId,
      orderId: orderId,
      agentId: agentId.trim(),
      amountEarned: amountEarned,
      tipAmount: 0.0,
      deliveryFee: deliveryFee,
      status: "pending",
      timestamp: FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    });

    console.log(
      `Successfully logged earning for order ${orderId} (agent ${agentId.trim()}): ₹${amountEarned}`
    );
  }
);
