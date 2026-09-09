<<<<<<< HEAD
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
=======
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
    this.role = 'customer',
  });

  bool get isDelivery => role == 'delivery';
  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    final dynamic candidateImage = map['profileImageUrl'] ??
        map['photoUrl'] ??
        map['photoURL'] ??
        map['profileImage'] ??
        map['imageUrl'] ??
        map['avatar'];

    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      profileImageUrl: (candidateImage is String && candidateImage.trim().isNotEmpty)
          ? candidateImage.trim()
          : null,
      role: map['role'] ?? 'customer',
    );
  }
}
>>>>>>> 74192f336731d620d80cbd622f9d701aaae5b778
