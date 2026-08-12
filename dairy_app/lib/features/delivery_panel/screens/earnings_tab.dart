import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../models/delivery_boy_model.dart';
import '../../../providers/delivery_provider.dart';

/// Earnings Tab - Daily/Weekly earnings breakdown
class EarningsTab extends ConsumerWidget {
  const EarningsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final earnings = ref.watch(deliveryEarningsProvider);
    final notifier = ref.watch(deliveryEarningsProvider.notifier);
    final agent = ref.watch(deliveryAgentProvider);

    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);

    final todayEarnings = notifier.todayTotal;
    final todayDeliveries = notifier.todayDeliveries;
    final weekEarnings = notifier.weekTotal;
    final weekDeliveries = notifier.weekDeliveries;

    // Calculate breakdown from all earnings
    final totalBaseEarnings = earnings.fold<double>(0.0, (sum, e) => sum + e.baseEarnings);
    final totalTips = earnings.fold<double>(0.0, (sum, e) => sum + e.tips);
    final totalBonuses = earnings.fold<double>(0.0, (sum, e) => sum + e.bonuses);
    final totalEarnings = earnings.fold<double>(0.0, (sum, e) => sum + e.total);

    return ListView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      children: [
        // Today's Earnings Card
        _buildEarningsCard(
          context,
          title: "Today's Earnings",
          amount: todayEarnings,
          deliveries: todayDeliveries,
          subtitle: '${todayDeliveries} deliveries completed',
          icon: Icons.today_rounded,
          iconColor: AppColors.primary,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: 16),

        // Weekly Earnings Card
        _buildEarningsCard(
          context,
          title: 'This Week',
          amount: weekEarnings,
          deliveries: weekDeliveries,
          subtitle: '${weekDeliveries} deliveries completed',
          icon: Icons.date_range_rounded,
          iconColor: AppColors.info,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: 24),

        // Earnings Breakdown
        Text(
          'Earnings Breakdown',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildBreakdownCard(
          context,
          isDesktop,
          baseEarnings: totalBaseEarnings,
          tips: totalTips,
          bonuses: totalBonuses,
          total: totalEarnings,
        ),
        const SizedBox(height: 24),

        // Daily Earnings List
        Text(
          'Daily Breakdown',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...earnings.map((e) => _buildDailyEarningsItem(context, e, isDesktop)).toList(),
      ],
    );
  }

  Widget _buildEarningsCard(
    BuildContext context, {
    required String title,
    required double amount,
    required int deliveries,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDesktop,
  }) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isDesktop ? 32 : 28,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$deliveries',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              Text(
                'Deliveries',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context,
    bool isDesktop, {
    required double baseEarnings,
    required double tips,
    required double bonuses,
    required double total,
  }) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildBreakdownRow(context, 'Base Earnings', '₹${baseEarnings.toStringAsFixed(0)}', AppColors.primary),
          _buildBreakdownRow(context, 'Tips', '₹${tips.toStringAsFixed(0)}', AppColors.warning),
          _buildBreakdownRow(context, 'Bonuses', '₹${bonuses.toStringAsFixed(0)}', AppColors.info),
          const Divider(),
          _buildBreakdownRow(context, 'Total', '₹${total.toStringAsFixed(0)}', AppColors.success, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? textPrimary : textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal ? color : textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyEarningsItem(BuildContext context, DeliveryEarnings earnings, bool isDesktop) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);

    final isToday = _isSameDay(earnings.date, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppColors.primary : cardBorder,
          width: isToday ? 2 : 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primaryLight.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${earnings.date.day}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isToday ? AppColors.primary : AppColors.success,
                  ),
                ),
                Text(
                  _getMonthShort(earnings.date.month),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isToday ? AppColors.primary : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getDayName(earnings.date.weekday),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Today',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${earnings.deliveriesCount} deliveries',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${earnings.total.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              Text(
                'Base: ₹${earnings.baseEarnings.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}