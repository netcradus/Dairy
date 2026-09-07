import '../core/auth/app_role.dart';

/// User Model for Sawariya Dairy
class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImageUrl;
  final String role; // 'admin', 'customer', 'delivery'

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImageUrl,
    this.role = UserRole.customerValue,
  });

  UserRole get userRole => UserRole.fromString(role);
  bool get isDelivery => userRole.isDelivery;
  bool get isAdmin => userRole.isAdmin;
  bool get isCustomer => userRole.isCustomer;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': UserRole.sanitize(role),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      role: UserRole.sanitize(map['role'] as String?),
    );
  }
}
