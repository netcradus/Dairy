import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation Index StateNotifier for active tab (Home=0, Shop=1, Orders=2, Profile=3)
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);

  void setIndex(int index) {
    if (index >= 0 && index <= 3) {
      state = index;
    }
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
