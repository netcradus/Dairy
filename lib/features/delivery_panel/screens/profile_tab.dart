import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../models/delivery_boy_model.dart';
import '../../../providers/delivery_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/user_provider.dart';

/// Profile Tab - Delivery agent info, online/offline toggle
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final agent = ref.watch(deliveryAgentProvider);
    final isOnline = agent.status == DeliveryStatus.onDuty;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);


    return ListView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      children: [
        // Profile Header
        Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: agent.profileImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          agent.profileImageUrl!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                agent.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Delivery Partner',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOnline ? Colors.white : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.white : Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Stats
        Row(
          children: [
            Expanded(child: _buildStatCard(context, 'Rating', '${agent.rating}', Icons.star_rounded, Colors.amber, isDesktop)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, 'Today\'s Deliveries', '${agent.completedDeliveriesToday}/${agent.totalDeliveriesToday}', Icons.local_shipping_rounded, AppColors.success, isDesktop)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, 'Today\'s Earnings', '₹${agent.earningsToday.toStringAsFixed(0)}', Icons.account_balance_wallet, AppColors.primary, isDesktop)),
          ],
        ),
        const SizedBox(height: 24),

        // Duty Toggle
        _buildDutyToggleCard(context, ref, agent, isDesktop),
        const SizedBox(height: 24),

        // Details Section
        _buildSectionCard(
          context,
          'Details',
          [
            _buildDetailRow(context, 'Phone', agent.phone, Icons.phone_rounded),
            _buildDetailRow(context, 'Vehicle', '${agent.vehicle} (${agent.vehicleNumber})', Icons.electric_rickshaw_rounded),
            _buildDetailRow(context, 'Assigned Zone', agent.assignedZone, Icons.location_on_rounded),
            _buildDetailRow(context, 'Partner ID', agent.id, Icons.badge_rounded),
          ],
          isDesktop,
        ),
        const SizedBox(height: 16),

        // App Settings
        _buildSectionCard(
          context,
          'App Settings',
          [
            _buildSettingsRow(
              context,
              'Notifications',
              'Manage notification preferences',
              Icons.notifications_outlined,
              null,
              trailing: Switch(
                value: settings.notificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: settingsNotifier.updateNotifications,
              ),
            ),
            _buildSettingsRow(
              context,
              'Navigation',
              _navLabel(settings.navigationApp),
              Icons.navigation_outlined,
              () => _showNavigationDialog(context, ref),
            ),
            _buildSettingsRow(
              context,
              'Language',
              _languageLabel(settings.languageCode),
              Icons.language_outlined,
              () => _showLanguageDialog(context, ref),
            ),
            _buildSettingsRow(
              context,
              'Theme',
              _themeLabel(settings.themeMode),
              Icons.palette_outlined,
              () => _showThemeDialog(context, ref),
            ),
          ],
          isDesktop,
        ),
        const SizedBox(height: 16),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildDeliveryTools(context, ref),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDeliveryTools(BuildContext context, WidgetRef ref) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final cardBg = AppColors.cardBgOf(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Switch Role',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: AppColors.warning),
              ),
              title: Text(
                'Simulate Customer Role',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              subtitle: Text(
                'Exit the delivery panel and return to the customer app',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                ref.read(userProvider.notifier).setRole('customer');
                context.push('/home');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDesktop,
  ) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDutyToggleCard(BuildContext context, WidgetRef ref, DeliveryAgent agent, bool isDesktop) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);
    final isOnline = agent.status == DeliveryStatus.onDuty;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duty Status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'Currently Online' : 'Currently Offline',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline
                          ? 'You\'re receiving delivery requests'
                          : 'Go online to start receiving requests',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: isDesktop ? 1.0 : 0.9,
                child: Switch(
                  value: isOnline,
                  onChanged: (_) => ref.read(deliveryAgentProvider.notifier).toggleDuty(),
                  activeColor: AppColors.success,
                  activeTrackColor: AppColors.success.withValues(alpha: 0.3),
                  inactiveTrackColor: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          if (isOnline) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You\'ll receive delivery requests for your assigned zone. Tap "Accept" to start a delivery.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
    bool isDesktop,
  ) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final textPrimary = AppColors.textPrimaryOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMutedOf(context),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    Widget? trailing,
    bool enabled = true,
  }) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final cardBorder = AppColors.cardBorderOf(context);
    final muted = AppColors.textMutedOf(context);

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cardBorder)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: enabled ? muted : muted.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: enabled ? textPrimary : muted,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: enabled ? muted : muted.withValues(alpha: 0.5),
                ),
          ],
        ),
      ),
    );
  }

  String _navLabel(NavigationApp app) {
    switch (app) {
      case NavigationApp.googleMaps:
        return 'Google Maps';
      case NavigationApp.appleMaps:
        return 'Apple Maps';
      case NavigationApp.waze:
        return 'Waze';
    }
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'hi':
        return 'हिंदी (Hindi)';
      default:
        return 'English';
    }
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showNavigationDialog(BuildContext context, WidgetRef ref) {
    final current = ref.read(settingsProvider).navigationApp;
    showDialog<NavigationApp>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Default Navigation App',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: NavigationApp.values.map((app) {
            return RadioListTile<NavigationApp>(
              title: Text(_navLabel(app), style: GoogleFonts.plusJakartaSans()),
              value: app,
              groupValue: current,
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateNavigationApp(value);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final current = ref.read(settingsProvider).languageCode;
    const options = [
      ('en', 'English'),
      ('hi', 'हिंदी (Hindi)'),
    ];
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Language',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option.$2, style: GoogleFonts.plusJakartaSans()),
              value: option.$1,
              groupValue: current,
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final current = ref.read(settingsProvider).themeMode;
    const options = [
      (ThemeMode.system, 'System Default'),
      (ThemeMode.light, 'Light'),
      (ThemeMode.dark, 'Dark'),
    ];
    showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Theme',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<ThemeMode>(
              title: Text(option.$2, style: GoogleFonts.plusJakartaSans()),
              value: option.$1,
              groupValue: current,
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondaryOf(context))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(userProvider.notifier).clearSession();
              // Navigation will be handled by router redirect
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Logout', style: GoogleFonts.plusJakartaSans()),
          ),
        ],
      ),
    );
  }
}