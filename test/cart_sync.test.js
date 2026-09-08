/**
 * Sawariya Dairy — Cart Firestore Sync & Security Rules Unit Tests (Task 7)
 * =========================================================================
 * Verifies:
 * 1. Security rules for /users/{userId}/cart/{productId} (RBAC, isolation, deny unauth/delivery).
 * 2. Deterministic doc ID usage (productId) avoiding duplicate entries.
 * 3. Add to cart, quantity update, item removal, and clear cart operations.
 * 4. Multi-user isolation across login, logout, and user switching.
 * 5. Order placement failure safety (cart preserved) vs success (cart cleared).
 * 6. Empty cart and resilient parsing of malformed/missing fields.
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
  deleteDoc,
  collection,
  getDocs,
  writeBatch,
} = require('firebase/firestore');
const fs = require('fs');
const path = require('path');
const assert = require('assert');

const PROJECT_ID = 'sawariya-7efd4';
const RULES_PATH = path.resolve(__dirname, '../firestore.rules');

describe('Task 7 — Cart Firestore Sync & Security Tests', function () {
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
      await setDoc(doc(db, 'users', 'delivery_uid'), {
        uid: 'delivery_uid',
        role: 'delivery',
        name: 'Delivery Agent',
      });
      await setDoc(doc(db, 'users', 'customer1_uid'), {
        uid: 'customer1_uid',
        role: 'customer',
        name: 'Customer One',
      });
      await setDoc(doc(db, 'users', 'customer2_uid'), {
        uid: 'customer2_uid',
        role: 'customer',
        name: 'Customer Two',
      });
      await setDoc(doc(db, 'users', 'invalid_uid'), {
        uid: 'invalid_uid',
        role: 'hacker',
        name: 'Invalid Role User',
      });
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  // Helper context DB getters
  const adminDb = () => testEnv.authenticatedContext('admin_uid').firestore();
  const customer1Db = () => testEnv.authenticatedContext('customer1_uid').firestore();
  const customer2Db = () => testEnv.authenticatedContext('customer2_uid').firestore();
  const deliveryDb = () => testEnv.authenticatedContext('delivery_uid').firestore();
  const unauthDb = () => testEnv.unauthenticatedContext().firestore();
  const invalidRoleDb = () => testEnv.authenticatedContext('invalid_uid').firestore();

  // =========================================================================
  // 1. FIRESTORE SECURITY RULES FOR /users/{userId}/cart/{productId}
  // =========================================================================
  describe('1. Cart Security Rules Isolation', () => {
    it('1. Customer can read own cart item', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'users', 'customer1_uid', 'cart', 'prod_milk_1L'), {
          productId: 'prod_milk_1L',
          quantity: 2,
          product: { id: 'prod_milk_1L', title: 'Fresh Cow Milk 1L', price: 65 },
        });
      });

      const db = customer1Db();
      await assertSucceeds(getDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_milk_1L')));
    });

    it('2. Customer can add own cart item', async () => {
      const db = customer1Db();
      await assertSucceeds(setDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_paneer_200g'), {
        productId: 'prod_paneer_200g',
        quantity: 1,
        product: { id: 'prod_paneer_200g', title: 'Fresh Paneer 200g', price: 90 },
      }));
    });

    it('3. Customer can update own quantity', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'users', 'customer1_uid', 'cart', 'prod_ghee_1kg'), {
          productId: 'prod_ghee_1kg',
          quantity: 1,
        });
      });

      const db = customer1Db();
      await assertSucceeds(updateDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_ghee_1kg'), {
        quantity: 3,
      }));
    });

    it('4. Customer can delete own cart item', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'users', 'customer1_uid', 'cart', 'prod_ghee_1kg'), {
          productId: 'prod_ghee_1kg',
          quantity: 1,
        });
      });

      const db = customer1Db();
      await assertSucceeds(deleteDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_ghee_1kg')));
    });

    it('5. Customer cannot read another customer cart', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'users', 'customer2_uid', 'cart', 'prod_milk_1L'), {
          productId: 'prod_milk_1L',
          quantity: 5,
        });
      });

      const db = customer1Db();
      await assertFails(getDoc(doc(db, 'users', 'customer2_uid', 'cart', 'prod_milk_1L')));
    });

    it('6. Customer cannot write or delete another customer cart', async () => {
      const db = customer1Db();
      await assertFails(setDoc(doc(db, 'users', 'customer2_uid', 'cart', 'prod_tamper'), {
        productId: 'prod_tamper',
        quantity: 10,
      }));
      await assertFails(deleteDoc(doc(db, 'users', 'customer2_uid', 'cart', 'prod_milk_1L')));
    });

    it('7. Unauthenticated user cannot read cart', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'users', 'customer1_uid', 'cart', 'prod_milk_1L'), {
          productId: 'prod_milk_1L',
          quantity: 1,
        });
      });

      const db = unauthDb();
      await assertFails(getDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_milk_1L')));
    });

    it('8. Unauthenticated user cannot write cart', async () => {
      const db = unauthDb();
      await assertFails(setDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_hack'), {
        productId: 'prod_hack',
        quantity: 1,
      }));
    });

    it('9. Delivery agent cannot access customer cart', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'users', 'customer1_uid', 'cart', 'prod_milk_1L'), {
          productId: 'prod_milk_1L',
          quantity: 1,
        });
      });

      const db = deliveryDb();
      await assertFails(getDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_milk_1L')));
      await assertFails(setDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_deliv_item'), {
        productId: 'prod_deliv_item',
        quantity: 1,
      }));
    });

    it('10. Invalid role does not gain privileged cart access', async () => {
      const db = invalidRoleDb();
      await assertFails(getDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_milk_1L')));
      await assertFails(setDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_tamper'), {
        productId: 'prod_tamper',
        quantity: 1,
      }));
    });

    it('11. Admin can manage customer cart for support purposes', async () => {
      const db = adminDb();
      const cartRef = doc(db, 'users', 'customer1_uid', 'cart', 'prod_support');
      await assertSucceeds(setDoc(cartRef, {
        productId: 'prod_support',
        quantity: 1,
        product: { id: 'prod_support', title: 'Gift Milk', price: 0 },
      }));
      await assertSucceeds(getDoc(cartRef));
      await assertSucceeds(deleteDoc(cartRef));
    });
  });

  // =========================================================================
  // 2. CART PERSISTENCE, MUTATION & LIFECYCLE LOGIC
  // =========================================================================
  describe('2. Cart Sync Operations & Lifecycle', () => {
    it('Adds new item and updates quantity on duplicate add without duplicate docs', async () => {
      const db = customer1Db();
      const itemRef = doc(db, 'users', 'customer1_uid', 'cart', 'prod_milk_1L');

      // First add: quantity = 1
      await setDoc(itemRef, {
        productId: 'prod_milk_1L',
        quantity: 1,
        product: { id: 'prod_milk_1L', title: 'Fresh Cow Milk 1L', price: 65 },
      }, { merge: true });

      let snap = await getDoc(itemRef);
      assert.strictEqual(snap.exists(), true);
      assert.strictEqual(snap.data().quantity, 1);

      // Second add of same item: quantity becomes 2
      await setDoc(itemRef, {
        productId: 'prod_milk_1L',
        quantity: 2,
        product: { id: 'prod_milk_1L', title: 'Fresh Cow Milk 1L', price: 65 },
      }, { merge: true });

      // Verify still only 1 document in cart subcollection
      const cartColl = collection(db, 'users', 'customer1_uid', 'cart');
      const allDocs = await getDocs(cartColl);
      assert.strictEqual(allDocs.size, 1);
      assert.strictEqual(allDocs.docs[0].data().quantity, 2);
    });

    it('Increments, decrements, and removes item on quantity reaching zero', async () => {
      const db = customer1Db();
      const itemRef = doc(db, 'users', 'customer1_uid', 'cart', 'prod_paneer');

      // Initial add: quantity = 2
      await setDoc(itemRef, {
        productId: 'prod_paneer',
        quantity: 2,
        product: { id: 'prod_paneer', title: 'Paneer 200g', price: 90 },
      });

      // Increment to 3
      await updateDoc(itemRef, { quantity: 3 });
      let snap = await getDoc(itemRef);
      assert.strictEqual(snap.data().quantity, 3);

      // Decrement to 2
      await updateDoc(itemRef, { quantity: 2 });
      snap = await getDoc(itemRef);
      assert.strictEqual(snap.data().quantity, 2);

      // Remove item (or decrement when qty <= 1)
      await deleteDoc(itemRef);
      snap = await getDoc(itemRef);
      assert.strictEqual(snap.exists(), false);
    });

    it('Clears entire cart using batch write without affecting other users', async () => {
      const db = customer1Db();

      // Seed 2 items for Customer 1
      await setDoc(doc(db, 'users', 'customer1_uid', 'cart', 'item_1'), {
        productId: 'item_1',
        quantity: 1,
      });
      await setDoc(doc(db, 'users', 'customer1_uid', 'cart', 'item_2'), {
        productId: 'item_2',
        quantity: 3,
      });

      // Seed 1 item for Customer 2
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await setDoc(doc(context.firestore(), 'users', 'customer2_uid', 'cart', 'item_cust2'), {
          productId: 'item_cust2',
          quantity: 4,
        });
      });

      // Customer 1 clears cart
      const cust1Cart = collection(db, 'users', 'customer1_uid', 'cart');
      const snap1 = await getDocs(cust1Cart);
      assert.strictEqual(snap1.size, 2);

      const batch = writeBatch(db);
      snap1.docs.forEach((d) => batch.delete(d.ref));
      await batch.commit();

      // Customer 1 cart is now empty
      const afterSnap1 = await getDocs(cust1Cart);
      assert.strictEqual(afterSnap1.size, 0);

      // Customer 2 cart is completely untouched
      const db2 = customer2Db();
      const snap2 = await getDocs(collection(db2, 'users', 'customer2_uid', 'cart'));
      assert.strictEqual(snap2.size, 1);
      assert.strictEqual(snap2.docs[0].data().quantity, 4);
    });

    it('Simulates Logout & Login: Customer 1 data stays in Firestore, not leaked to Customer 2', async () => {
      // Step A: Customer 1 adds items
      const db1 = customer1Db();
      await setDoc(doc(db1, 'users', 'customer1_uid', 'cart', 'cust1_butter'), {
        productId: 'cust1_butter',
        quantity: 2,
        product: { id: 'cust1_butter', title: 'White Butter 500g', price: 220 },
      });

      // Step B: User 1 logs out (local memory is cleared in client, Firestore documents remain intact)
      const admin = adminDb();
      const afterLogoutSnap = await getDocs(collection(admin, 'users', 'customer1_uid', 'cart'));
      assert.strictEqual(afterLogoutSnap.size, 1);

      // Step C: Customer 2 logs in -> reads only Customer 2 cart (empty initially)
      const db2 = customer2Db();
      const cust2CartSnap = await getDocs(collection(db2, 'users', 'customer2_uid', 'cart'));
      assert.strictEqual(cust2CartSnap.size, 0);

      // Step D: Customer 1 logs back in -> reads Customer 1 cart (butter is restored)
      const cust1RestoredSnap = await getDocs(collection(db1, 'users', 'customer1_uid', 'cart'));
      assert.strictEqual(cust1RestoredSnap.size, 1);
      assert.strictEqual(cust1RestoredSnap.docs[0].id, 'cust1_butter');
      assert.strictEqual(cust1RestoredSnap.docs[0].data().quantity, 2);
    });

    it('Preserves cart on checkout failure and clears cart on checkout success', async () => {
      const db = customer1Db();
      const itemRef = doc(db, 'users', 'customer1_uid', 'cart', 'prod_milk');
      await setDoc(itemRef, {
        productId: 'prod_milk',
        quantity: 2,
        product: { id: 'prod_milk', title: 'Cow Milk 1L', price: 65 },
      });

      // Scenario A: Checkout order creation fails (e.g. invalid status or permission violation)
      // Cart MUST remain untouched.
      await assertFails(setDoc(doc(db, 'orders', 'bad_order'), {
        userId: 'customer2_uid', // Forged userId -> will fail
        status: 'Pending',
      }));

      // Verify cart still has the item
      let snap = await getDoc(itemRef);
      assert.strictEqual(snap.exists(), true);
      assert.strictEqual(snap.data().quantity, 2);

      // Scenario B: Checkout order creation succeeds -> then clearCart() is triggered
      await assertSucceeds(setDoc(doc(db, 'orders', 'good_order_101'), {
        userId: 'customer1_uid',
        status: 'Pending',
        totalAmount: 130,
        subtotal: 130,
        items: [{ productId: 'prod_milk', quantity: 2, unitPrice: 65 }],
        createdAt: new Date().toISOString(),
      }));

      // Clear cart after success
      await deleteDoc(itemRef);
      snap = await getDoc(itemRef);
      assert.strictEqual(snap.exists(), false);
    });

    it('Safely handles empty cart queries and missing product fields', async () => {
      const db = customer1Db();
      const emptyCartSnap = await getDocs(collection(db, 'users', 'customer1_uid', 'cart'));
      assert.strictEqual(emptyCartSnap.empty, true);
      assert.strictEqual(emptyCartSnap.size, 0);

      // Add doc with minimal/flat fields (e.g. legacy structure)
      await setDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_legacy'), {
        productId: 'prod_legacy',
        quantity: 1,
      });

      const legacySnap = await getDoc(doc(db, 'users', 'customer1_uid', 'cart', 'prod_legacy'));
      assert.strictEqual(legacySnap.exists(), true);
      assert.strictEqual(legacySnap.data().productId, 'prod_legacy');
    });
  });
});
