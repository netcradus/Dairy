/// Delivery Address Model for Sawariya Dairy (Phase 6)
class Address {
  final String id;
  final String label; // e.g. "Home", "Office"
  final String fullName;
  final String mobileNumber;
  final String houseFlat;
  final String streetArea;
  final String city;
  final String state;
  final String pinCode;
  final bool isDefault;

  const Address({
    required this.id,
    this.label = 'Home',
    required this.fullName,
    required this.mobileNumber,
    required this.houseFlat,
    required this.streetArea,
    required this.city,
    required this.state,
    required this.pinCode,
    this.isDefault = false,
  });

  String get fullAddressText => '$houseFlat, $streetArea, $city, $state - $pinCode';

  Address copyWith({
    String? id,
    String? label,
    String? fullName,
    String? mobileNumber,
    String? houseFlat,
    String? streetArea,
    String? city,
    String? state,
    String? pinCode,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      houseFlat: houseFlat ?? this.houseFlat,
      streetArea: streetArea ?? this.streetArea,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

