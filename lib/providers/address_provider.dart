import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';
import 'user_provider.dart';

class AddressNotifier extends StateNotifier<List<Address>> {
  final String _userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AddressNotifier(this._userId) : super([]) {
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (_userId.isEmpty) {
      state = [];
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('addresses')
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return Address(
          id: doc.id,
          label: data['label'] ?? 'Home',
          fullName: data['fullName'] ?? '',
          mobileNumber: data['mobileNumber'] ?? '',
          houseFlat: data['houseFlat'] ?? '',
          streetArea: data['streetArea'] ?? '',
          city: data['city'] ?? '',
          state: data['state'] ?? '',
          pinCode: data['pinCode'] ?? '',
          isDefault: data['isDefault'] ?? false,
        );
      }).toList();

      state = list;
    } catch (_) {
      state = [];
    }
  }

  Future<void> addAddress(Address address) async {
    if (_userId.isEmpty) return;
    try {
      final colRef =
          _firestore.collection('users').doc(_userId).collection('addresses');

      if (address.isDefault) {
        final batch = _firestore.batch();
        for (var a in state) {
          if (a.isDefault) {
            batch.update(colRef.doc(a.id), {'isDefault': false});
          }
        }
        final docRef = colRef.doc(address.id);
        batch.set(docRef, {
          'label': address.label,
          'fullName': address.fullName,
          'mobileNumber': address.mobileNumber,
          'houseFlat': address.houseFlat,
          'streetArea': address.streetArea,
          'city': address.city,
          'state': address.state,
          'pinCode': address.pinCode,
          'isDefault': address.isDefault,
        });
        await batch.commit();
      } else {
        await colRef.doc(address.id).set({
          'label': address.label,
          'fullName': address.fullName,
          'mobileNumber': address.mobileNumber,
          'houseFlat': address.houseFlat,
          'streetArea': address.streetArea,
          'city': address.city,
          'state': address.state,
          'pinCode': address.pinCode,
          'isDefault': address.isDefault,
        });
      }

      await _loadAddresses();
    } catch (_) {}
  }

  Future<void> updateAddress(Address address) async {
    if (_userId.isEmpty) return;
    try {
      final colRef =
          _firestore.collection('users').doc(_userId).collection('addresses');

      if (address.isDefault) {
        final batch = _firestore.batch();
        for (var a in state) {
          if (a.isDefault && a.id != address.id) {
            batch.update(colRef.doc(a.id), {'isDefault': false});
          }
        }
        batch.update(colRef.doc(address.id), {
          'label': address.label,
          'fullName': address.fullName,
          'mobileNumber': address.mobileNumber,
          'houseFlat': address.houseFlat,
          'streetArea': address.streetArea,
          'city': address.city,
          'state': address.state,
          'pinCode': address.pinCode,
          'isDefault': address.isDefault,
        });
        await batch.commit();
      } else {
        await colRef.doc(address.id).update({
          'label': address.label,
          'fullName': address.fullName,
          'mobileNumber': address.mobileNumber,
          'houseFlat': address.houseFlat,
          'streetArea': address.streetArea,
          'city': address.city,
          'state': address.state,
          'pinCode': address.pinCode,
          'isDefault': address.isDefault,
        });
      }

      await _loadAddresses();
    } catch (_) {}
  }

  Future<void> removeAddress(String id) async {
    if (_userId.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('addresses')
          .doc(id)
          .delete();
      await _loadAddresses();
    } catch (_) {}
  }

  Future<void> setDefault(String id) async {
    if (_userId.isEmpty) return;
    try {
      final colRef =
          _firestore.collection('users').doc(_userId).collection('addresses');
      final batch = _firestore.batch();
      for (var a in state) {
        batch.update(colRef.doc(a.id), {'isDefault': a.id == id});
      }
      await batch.commit();
      await _loadAddresses();
    } catch (_) {}
  }
}

final addressesProvider =
    StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
  final user = ref.watch(userProvider);
  return AddressNotifier(user.id);
});

/// Currently selected address ID for checkout
final selectedAddressIdProvider = StateProvider<String>((ref) {
  final addresses = ref.watch(addressesProvider);
  final defaultAddress = addresses.firstWhere(
    (a) => a.isDefault,
    orElse: () => addresses.isNotEmpty
        ? addresses.first
        : const Address(
            id: 'addr_temp',
            fullName: 'Customer Name',
            mobileNumber: '9876543210',
            houseFlat: '123 Dairy Lane',
            streetArea: 'Main Street',
            city: 'Indore',
            state: 'Madhya Pradesh',
            pinCode: '452001',
          ),
  );
  return defaultAddress.id;
});

/// Selected address object getter provider
final selectedAddressProvider = Provider<Address?>((ref) {
  final addresses = ref.watch(addressesProvider);
  final selectedId = ref.watch(selectedAddressIdProvider);
  if (addresses.isEmpty) return null;
  return addresses.firstWhere(
    (a) => a.id == selectedId,
    orElse: () => addresses.first,
  );
});
