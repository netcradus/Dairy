import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive/responsive.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_bottom_navigation.dart';
import '../../core/widgets/app_desktop_sidebar.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../cart/cart_screen.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/shop_screen.dart';

/// Main Responsive Layout Shell
class MainLayoutScreen extends ConsumerWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final isDesktop = context.isDesktop;

    final List<Widget> pages = [
      const HomeScreen(),         // 0 – Home
      const ShopScreen(),         // 1 – Shop
      const OrdersScreen(),       // 2 – Orders
      const ProfileScreen(),      // 3 – Profile
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            AppDesktopSidebar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(navigationProvider.notifier).setIndex(index);
              },
            ),
            Expanded(
              child: Column(
                children: [
                  AppTopAppBar(
                    cartItemCount: cartCount,
                    onSearchTap: () {
                      ref.read(navigationProvider.notifier).setIndex(1);
                    },
                    onNotificationTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      );
                    },
                    onCartTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: currentIndex,
                      children: pages,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile & Tablet Layout
    return Scaffold(
      appBar: AppTopAppBar(
        cartItemCount: cartCount,
        onSearchTap: () {
          ref.read(navigationProvider.notifier).setIndex(1);
        },
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
        onCartTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        },
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
        },
      ),
    );
  }
}
