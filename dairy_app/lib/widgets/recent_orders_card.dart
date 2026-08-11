import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import 'status_badge.dart';

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final dividerColor = AppColors.dividerOf(context);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Orders',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => provider.setNavIndex(4),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Table Headers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Order ID',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Customer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: dividerColor),
          // Table Rows
          ...provider.recentOrders.map((order) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      order.id,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      order.customerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      currencyFormatter.format(order.amount),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: StatusBadge.fromOrderStatus(order.status),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
