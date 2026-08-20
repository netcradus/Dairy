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
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      role: map['role'] ?? 'customer',
    );
  }
}
