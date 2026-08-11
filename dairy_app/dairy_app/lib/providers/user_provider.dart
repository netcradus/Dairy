import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

/// Current user profile state notifier.
class UserNotifier extends StateNotifier<User> {
  UserNotifier()
      : super(const User(
          id: 'user_1',
          name: 'Sawariya Customer',
          phone: '+91 98765 43210',
          email: 'customer@sawariyadairy.com',
        ));

  void updateProfile({String? name, String? phone, String? email}) {
    state = User(
      id: state.id,
      name: name ?? state.name,
      phone: phone ?? state.phone,
      email: email ?? state.email,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});
