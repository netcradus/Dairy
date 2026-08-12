import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;

import '../theme/admin_theme.dart';
import '../../providers/admin_provider.dart';
import '../../screens/admin_main_shell.dart';

import '../../features/address/add_address_screen.dart';
import '../../features/address/address_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/delivery_panel/delivery_panel_screen.dart';
import '../../features/main_layout/main_layout_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/offers/offers_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/product/product_details_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../models/product.dart';
import '../../providers/user_provider.dart';

/// Central GoRouter configuration provider for Sawariya Dairy
final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(userProvider);
  final isLoggedIn = user.id.isNotEmpty;
  final isAdmin = user.role == 'admin';
  final isDelivery = user.role == 'delivery';

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isAuthPath = path == '/login' ||
                         path == '/register' ||
                         path == '/otp' ||
                         path == '/splash' ||
                         path == '/onboarding';

      if (!isLoggedIn && !isAuthPath) {
        return '/login';
      }

      if (isLoggedIn) {
        if (isAuthPath) {
          if (isAdmin) return '/admin';
          if (isDelivery) return '/delivery';
          return '/home';
        }
        if (path == '/admin' && !isAdmin) {
          return isDelivery ? '/delivery' : '/home';
        }
        if (path == '/delivery' && !isDelivery) {
          return isAdmin ? '/admin' : '/home';
        }
        if (path == '/home' && (isAdmin || isDelivery)) {
          return isAdmin ? '/admin' : '/delivery';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return OtpScreen(
              targetDestination: extra['targetDestination'] as String?,
              isPasswordResetFlow: extra['isPasswordResetFlow'] as bool? ?? false,
            );
          } else if (extra is String) {
            return OtpScreen(targetDestination: extra);
          }
          return const OtpScreen();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayoutScreen(),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        path: '/product-details',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/address',
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        path: '/add-address',
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/offers',
        builder: (context, state) => const OffersScreen(),
      ),
GoRoute(
        path: '/admin',
        builder: (context, state) => provider.MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: provider.Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              return Theme(
                data: adminProvider.isDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme,
                child: const AdminMainShell(),
              );
            },
          ),
        ),
      ),
      GoRoute(
        path: '/delivery',
        builder: (context, state) => const DeliveryPanelScreen(),
      ),
    ],
  );
});
