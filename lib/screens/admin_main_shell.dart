import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/responsive/responsive_layout.dart';
import '../providers/admin_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/sidebar_navigation.dart';
import 'categories/categories_screen.dart';
import 'customers/customers_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'delivery/delivery_management_screen.dart';
import 'delivery_staff/delivery_staff_screen.dart';
import 'notifications/notifications_screen.dart';
import 'orders/orders_screen.dart';
import 'payments/payments_screen.dart';
import 'products/products_screen.dart';
import 'staff/staff_roles_screen.dart';
import 'support/support_screen.dart';

class AdminMainShell extends StatelessWidget {
  const AdminMainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final bgColor = AppColors.bgOf(context);

    Widget getActiveScreen(int index) {
      switch (index) {
        case 0:
          return const DashboardScreen();
        case 1:
          return const CustomersScreen();
        case 2:
          return const ProductsScreen();
        case 3:
          return const CategoriesScreen();
        case 4:
          return const OrdersScreen();
        case 5:
          return const DeliveryManagementScreen();
        case 6:
          return const DeliveryStaffScreen();
        case 7:
          return const PaymentsScreen();
        case 8:
          return const NotificationsScreen();
        case 9:
          return const SupportScreen();
        case 10:
          return const StaffRolesScreen();
        default:
          return const DashboardScreen();
      }
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Row(
          children: [
            // Fixed Persistent Sidebar for Desktop
            const SidebarNavigation(isDrawer: false),
            // Right Main Content Area
            Expanded(
              child: Column(
                children: [
                  const AppHeader(),
                  Expanded(
                    child: getActiveScreen(provider.selectedNavIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile / Tablet with Drawer Navigation
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: bgColor,
        drawer: const Drawer(
          child: SidebarNavigation(isDrawer: true),
        ),
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                onOpenDrawer: () => scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: getActiveScreen(provider.selectedNavIndex),
              ),
            ],
          ),
        ),
      );
    }
  }
}
