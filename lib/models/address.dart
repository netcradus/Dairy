import 'package:cloud_firestore/cloud_firestore.dart';

/// Delivery Address Model for Sawariya Dairy (Phase 6 & 8)
class Address {
  final String id;
  final String label; // e.g. "Home", "Office", "Other"
  final String fullName;
  final String mobileNumber;
  final String houseFlat;
  final String streetArea;
  final String city;
  final String state;
  final String pinCode;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns true if valid, non-zero coordinates are present
  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      (latitude! != 0.0 || longitude! != 0.0);

  String get fullAddressText =>
      '$houseFlat, $streetArea, $city, $state - $pinCode';

  /// Clean query formatted for forward geocoding
  String get geocodingQuery {
    final parts = [
      houseFlat.trim(),
      streetArea.trim(),
      city.trim(),
      state.trim(),
      pinCode.trim(),
      'India',
    ].where((s) => s.isNotEmpty).toList();
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'houseFlat': houseFlat,
      'streetArea': streetArea,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'isDefault': isDefault,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  factory Address.fromMap(Map<String, dynamic> data, [String? id]) {
    double? parseCoord(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return Address(
      id: id ?? (data['id'] as String?) ?? '',
      label: (data['label'] as String?) ?? 'Home',
      fullName: (data['fullName'] as String?) ?? '',
      mobileNumber: (data['mobileNumber'] as String?) ?? '',
      houseFlat: (data['houseFlat'] as String?) ?? '',
      streetArea: (data['streetArea'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      state: (data['state'] as String?) ?? '',
      pinCode: (data['pinCode'] as String?) ?? '',
      isDefault: (data['isDefault'] as bool?) ?? false,
      latitude: parseCoord(data['latitude']),
      longitude: parseCoord(data['longitude']),
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

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
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
