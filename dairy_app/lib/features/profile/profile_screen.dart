import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive.dart';
import '../../providers/user_provider.dart';
import '../address/address_screen.dart';
import 'edit_profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../subscription/subscriptions_screen.dart';
import 'about_screen.dart';
import 'customer_support_screen.dart';
import '../../screens/settings/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalPadding,
          vertical: 20,
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 700 : double.infinity,
            ),
            child: Column(
              children: [
                // User Info Header
                if (kDebugMode)
                  _SecretDevGesture(
                    onTriggered: () => _openDeliveryPanel(context, ref),
                    child: buildProfileHeader(context, ref),
                  )
                else
                  buildProfileHeader(context, ref),
                const SizedBox(height: 24),

                // Developer-only access (stripped from release builds)
                if (kDebugMode) ...[
                  buildSectionTitle('Developer (Debug Only)'),
                  buildTile(
                    context: context,
                    icon: Icons.developer_mode_rounded,
                    title: 'Open Delivery Panel',
                    subtitle:
                        'Triple-tap the avatar above, or tap here, to test the delivery experience',
                    onTap: () => _openDeliveryPanel(context, ref),
                  ),
                  const SizedBox(height: 16),
                ],

                // Account Settings
                buildSectionTitle('Account Settings'),
                buildTile(
                  context: context,
                  icon: Icons.location_on_outlined,
                  title: 'Saved Delivery Addresses',
                  subtitle: 'Manage home & office addresses',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressScreen(),
                      ),
                    );
                  },
                ),
                buildTile(
                  context: context,
                  icon: Icons.repeat_rounded,
                  title: 'Daily Milk Subscriptions',
                  subtitle: 'Manage recurring morning/evening deliveries',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                buildSectionTitle('Preferences & Support'),
                buildTile(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: 'App Settings',
                  subtitle: 'Notifications, navigation, language & theme',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                buildTile(
                  context: context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Delivery updates and daily reminders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                buildTile(
                  context: context,
                  icon: Icons.headset_mic_outlined,
                  title: 'Customer Support',
                  subtitle: 'Contact Sawariya Dairy support team',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerSupportScreen(),
                      ),
                    );
                  },
                ),
                buildTile(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: 'About Sawariya Dairy',
                  subtitle: 'App version 1.0.0',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      showLogoutDialog(context, ref);
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileHeader(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Sawariya Dairy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(userProvider.notifier).clearSession();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  /// Developer-only shortcut: switch the current user to the delivery role so
  /// the router redirects into the Delivery Panel, then navigate to it.
  /// Only ever invoked from widgets guarded by [kDebugMode].
  void _openDeliveryPanel(BuildContext context, WidgetRef ref) {
    ref.read(userProvider.notifier).setRole('delivery');
    context.push('/delivery');
  }
}

/// Hidden secret gesture: triggers [onTriggered] after three quick taps on its
/// child. Intended to be wrapped in [kDebugMode] so it is absent in release.
class _SecretDevGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback onTriggered;

  const _SecretDevGesture({
    required this.child,
    required this.onTriggered,
  });

  @override
  State<_SecretDevGesture> createState() => _SecretDevGestureState();
}

class _SecretDevGestureState extends State<_SecretDevGesture> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) > const Duration(milliseconds: 600)) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;
    if (_tapCount >= 3) {
      _tapCount = 0;
      widget.onTriggered();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _handleTap, child: widget.child);
  }
}