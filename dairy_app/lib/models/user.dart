/// User Model for Sawariya Dairy
class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImageUrl,
  });
}
