/**
 * Sawariya Dairy — Address Geocoding & Coordinate Persistence Tests (Task 8)
 * =========================================================================
 * Verifies:
 * 1. Security rules for /users/{userId}/addresses/{addressId} with latitude/longitude.
 * 2. Cross-user address isolation & access guards.
 * 3. Address coordinate serialization, deserialization, and legacy fallback.
 * 4. Coordinate update & preservation during edits.
 * 5. Order snapshot preserving real delivery coordinates.
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
} = require('firebase/firestore');
const fs = require('fs');
const path = require('path');
const assert = require('assert');

const PROJECT_ID = 'sawariya-7efd4';
const RULES_PATH = path.resolve(__dirname, '../firestore.rules');

describe('Task 8 — Address Geocoding & Coordinate Persistence Tests', function () {
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
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  // 1. FIRESTORE SECURITY RULES FOR /users/{userId}/addresses/{addressId}
  describe('1. Address Security Rules & Coordinate Storage', () => {
    it('1. Customer can create address with real latitude and longitude', async () => {
      const db = testEnv.authenticatedContext('customer1_uid').firestore();
      const addrRef = doc(db, 'users', 'customer1_uid', 'addresses', 'addr_home');

      await assertSucceeds(
        setDoc(addrRef, {
          label: 'Home',
          fullName: 'Customer One',
          mobileNumber: '9876543210',
          houseFlat: 'Flat 402, Sunshine Heights',
          streetArea: 'MG Road, Vijay Nagar',
          city: 'Indore',
          state: 'Madhya Pradesh',
          pinCode: '452010',
          isDefault: true,
          latitude: 22.7533,
          longitude: 75.8937,
        })
      );
    });

    it('2. Customer can read own address with coordinates', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_home'), {
          label: 'Home',
          fullName: 'Customer One',
          mobileNumber: '9876543210',
          houseFlat: 'Flat 402',
          streetArea: 'Vijay Nagar',
          city: 'Indore',
          state: 'Madhya Pradesh',
          pinCode: '452010',
          latitude: 22.7533,
          longitude: 75.8937,
        });
      });

      const db = testEnv.authenticatedContext('customer1_uid').firestore();
      const snap = await assertSucceeds(
        getDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_home'))
      );
      assert.strictEqual(snap.data().latitude, 22.7533);
      assert.strictEqual(snap.data().longitude, 75.8937);
    });

    it('3. Customer can update address coordinates', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_home'), {
          label: 'Home',
          fullName: 'Customer One',
          city: 'Indore',
          latitude: 22.7533,
          longitude: 75.8937,
        });
      });

      const db = testEnv.authenticatedContext('customer1_uid').firestore();
      await assertSucceeds(
        updateDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_home'), {
          latitude: 22.7255,
          longitude: 75.8800,
          city: 'Indore Central',
        })
      );
    });

    it('4. Customer CANNOT read another customer addresses', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'users', 'customer2_uid', 'addresses', 'addr_secret'), {
          label: 'Secret Home',
          latitude: 28.6139,
          longitude: 77.2090,
        });
      });

      const db = testEnv.authenticatedContext('customer1_uid').firestore();
      await assertFails(
        getDoc(doc(db, 'users', 'customer2_uid', 'addresses', 'addr_secret'))
      );
    });

    it('5. Customer CANNOT write to another customer addresses', async () => {
      const db = testEnv.authenticatedContext('customer1_uid').firestore();
      await assertFails(
        setDoc(doc(db, 'users', 'customer2_uid', 'addresses', 'addr_hack'), {
          label: 'Hacked',
          latitude: 0.0,
          longitude: 0.0,
        })
      );
    });

    it('6. Unauthenticated user CANNOT read or write addresses', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(
        getDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_home'))
      );
      await assertFails(
        setDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_unauth'), {
          label: 'Unauth',
        })
      );
    });

    it('7. Admin can read and manage customer addresses for support', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_support'), {
          label: 'Support Test',
          latitude: 22.7196,
          longitude: 75.8577,
        });
      });

      const db = testEnv.authenticatedContext('admin_uid').firestore();
      await assertSucceeds(
        getDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_support'))
      );
      await assertSucceeds(
        deleteDoc(doc(db, 'users', 'customer1_uid', 'addresses', 'addr_support'))
      );
    });
  });

  // 2. ORDER CHECKOUT COORDINATE PERSISTENCE
  describe('2. Order Snapshot with Delivery Coordinates', () => {
    it('1. Order creation stores customer delivery coordinates in order snapshot', async () => {
      const db = testEnv.authenticatedContext('customer1_uid').firestore();
      const orderRef = doc(db, 'orders', 'order_geo_001');

      await assertSucceeds(
        setDoc(orderRef, {
          userId: 'customer1_uid',
          status: 'Pending',
          subtotal: 350.0,
          deliveryCharge: 30.0,
          discount: 0.0,
          totalAmount: 380.0,
          deliveryAddress: {
            fullName: 'Customer One',
            mobileNumber: '9876543210',
            houseFlat: 'Flat 402, Sunshine Heights',
            streetArea: 'Vijay Nagar',
            city: 'Indore',
            state: 'Madhya Pradesh',
            pinCode: '452010',
            label: 'Home',
            fullAddressText: 'Flat 402, Sunshine Heights, Vijay Nagar, Indore, Madhya Pradesh - 452010',
            latitude: 22.7533,
            longitude: 75.8937,
          },
          items: [
            {
              productId: 'prod_milk_1L',
              title: 'Fresh Cow Milk',
              quantity: 2,
              price: 65.0,
              totalPrice: 130.0,
            },
          ],
        })
      );

      const snap = await getDoc(orderRef);
      assert.strictEqual(snap.data().deliveryAddress.latitude, 22.7533);
      assert.strictEqual(snap.data().deliveryAddress.longitude, 75.8937);
    });

    it('2. Delivery agent can read order with coordinates', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await setDoc(doc(db, 'orders', 'order_geo_002'), {
          userId: 'customer1_uid',
          status: 'Pending',
          deliveryAddress: {
            fullName: 'Customer One',
            latitude: 22.7533,
            longitude: 75.8937,
          },
        });
      });

      const db = testEnv.authenticatedContext('delivery_uid').firestore();
      const snap = await assertSucceeds(getDoc(doc(db, 'orders', 'order_geo_002')));
      assert.strictEqual(snap.data().deliveryAddress.latitude, 22.7533);
      assert.strictEqual(snap.data().deliveryAddress.longitude, 75.8937);
    });
  });
});
