/// Centralized Role-Based Access Control (RBAC) definition for Sawariya Dairy
enum UserRole {
  admin,
  delivery,
  customer;

  static const String adminValue = 'admin';
  static const String deliveryValue = 'delivery';
  static const String customerValue = 'customer';

  /// Securely parses a role string.
  /// Any unknown, null, empty, or invalid role fails securely to [UserRole.customer].
  static UserRole fromString(String? role) {
    if (role == null) return UserRole.customer;
    switch (role.trim().toLowerCase()) {
      case adminValue:
        return UserRole.admin;
      case deliveryValue:
        return UserRole.delivery;
      case customerValue:
        return UserRole.customer;
      default:
        // Fail securely: unknown/invalid roles are never granted privileged access
        return UserRole.customer;
    }
  }

  /// Returns the canonical sanitized role string for storage or state.
  static String sanitize(String? role) {
    return fromString(role).value;
  }

  /// Canonical string representation matching existing Firestore schema.
  String get value {
    switch (this) {
      case UserRole.admin:
        return adminValue;
      case UserRole.delivery:
        return deliveryValue;
      case UserRole.customer:
        return customerValue;
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isDelivery => this == UserRole.delivery;
  bool get isCustomer => this == UserRole.customer;

  /// Returns the default landing/home route for this role.
  String get homeRoute {
    switch (this) {
      case UserRole.admin:
        return '/admin';
      case UserRole.delivery:
        return '/delivery';
      case UserRole.customer:
        return '/home';
    }
  }
}
