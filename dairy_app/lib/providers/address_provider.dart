import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address.dart';

/// Default initial mock address for Sawariya Dairy
const _initialAddresses = [
  Address(
    id: 'addr_1',
    label: 'Home',
    fullName: 'Rahul Sharma',
    mobileNumber: '+91 9876543210',
    houseFlat: 'Flat 402, Sunshine Heights',
    streetArea: 'MG Road, Vijay Nagar',
    city: 'Indore',
    state: 'Madhya Pradesh',
    pinCode: '452010',
    isDefault: true,
  ),
  Address(
    id: 'addr_2',
    label: 'Office',
    fullName: 'Rahul Sharma (Office)',
    mobileNumber: '+91 9876543210',
    houseFlat: 'Suite 305, Tech Park',
    streetArea: 'AB Road, Palasia',
    city: 'Indore',
    state: 'Madhya Pradesh',
    pinCode: '452001',
    isDefault: false,
  ),
];

class AddressNotifier extends StateNotifier<List<Address>> {
  AddressNotifier() : super(_initialAddresses);

  void addAddress(Address address) {
    if (address.isDefault) {
      state = [
        ...state.map((a) => a.copyWith(isDefault: false)),
        address,
      ];
    } else {
      state = [...state, address];
    }
  }

  void removeAddress(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void setDefault(String id) {
    state = state.map((a) => a.copyWith(isDefault: a.id == id)).toList();
  }
}

final addressesProvider =
    StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
  return AddressNotifier();
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
