import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive.dart';
import '../../providers/navigation_provider.dart';
import 'edit_profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../subscription/subscriptions_screen.dart';

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
                _buildProfileHeader(context),
                const SizedBox(height: 24),

                // Account Settings
                _buildSectionTitle('Account Settings'),
                _buildTile(
                  context: context,
                  icon: Icons.location_on_outlined,
                  title: 'Saved Delivery Addresses',
                  subtitle: 'Manage home & office addresses',
                  onTap: () {},
                ),
                _buildTile(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Order History & Status',
                  subtitle: 'Track past and active milk orders',
                  onTap: () {
                    // Switch tab to Orders (Index 2)
                    ref.read(navigationProvider.notifier).setIndex(2);
                  },
                ),
                _buildTile(
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
                _buildSectionTitle('Preferences & Support'),
                   _buildTile(
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
                _buildTile(
                  context: context,
                  icon: Icons.headset_mic_outlined,
                  title: 'Customer Support',
                  subtitle: 'Contact Sawariya Dairy support team',
                  onTap: () {},
                ),
                _buildTile(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: 'About Sawariya Dairy',
                  subtitle: 'App version 1.0.0',
                  onTap: () {},
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
                      _showLogoutDialog(context);
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

  Widget _buildProfileHeader(BuildContext context) {
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
                const Text(
                  'Sawariya Customer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+91 98765 43210',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'customer@sawariyadairy.com',
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

  Widget _buildSectionTitle(String title) {
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

  Widget _buildTile({
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
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}