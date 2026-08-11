import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation Index StateNotifier for active tab (Home=0, Shop=1, Orders=2, Offers=3, Profile=4)
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);

  void setIndex(int index) {
    if (index >= 0 && index <= 4) {
      state = index;
    }
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
