const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();

// Agent commission rate applied to the order subtotal. Must stay in sync with
// OrderService.agentEarningRate (0.10) in the Flutter app.
const AGENT_EARNING_RATE = 0.10;

/**
 * When an order transitions to "delivered", credit the assigned agent's
 * earnings by writing a document to the "earnings" collection. The document id
 * is the order id, so a redelivery cannot create duplicate records.
 */
exports.logEarningOnDelivered = onDocumentUpdated(
  { document: "orders/{orderId}" },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const orderId = event.params.orderId;

    // Only act on a transition INTO "delivered".
    if (before.status === after.status || after.status !== "delivered") {
      return;
    }

    const agentId = after.assignedAgentId;
    if (!agentId) {
      console.log(
        `Order ${orderId} delivered with no assignedAgentId; skipping earnings.`
      );
      return;
    }

    const subtotal = Number(after.subtotal) || 0;
    const deliveryFee = Number(after.deliveryCharge) || 0;
    const amountEarned = subtotal * AGENT_EARNING_RATE;

    const db = getFirestore();
    await db
      .collection("earnings")
      .doc(orderId)
      .set({
        agentId: agentId,
        orderId: orderId,
        amountEarned: amountEarned,
        tipAmount: 0,
        deliveryFee: deliveryFee,
        timestamp: FieldValue.serverTimestamp(),
        status: "pending",
      });

    console.log(
      `Logged earning for order ${orderId} (agent ${agentId}): ${amountEarned}`
    );
  }
);
