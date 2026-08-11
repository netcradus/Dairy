import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/status_badge.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final dividerColor = AppColors.dividerOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Support & Complaints',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          Text(
            'Resolve customer delivery issues, bottle returns, pouch damages, and query tickets.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
              boxShadow: AppColors.cardShadow,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.complaints.length,
              separatorBuilder: (ctx, idx) => Divider(color: dividerColor),
              itemBuilder: (ctx, idx) {
                final ticket = provider.complaints[idx];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.customersOrangeBg.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: AppColors.customersOrange),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ticket.customerName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.customersOrangeBg.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    ticket.issueType,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.customersOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.fromString(ticket.status),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
