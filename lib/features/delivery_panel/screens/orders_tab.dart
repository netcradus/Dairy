import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../models/delivery_boy_model.dart';
import '../../../providers/delivery_provider.dart';

/// Orders Tab - Delivery History
class OrdersTab extends ConsumerWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final history = ref.watch(deliveryHistoryProvider);
    final completedOrders = ref.watch(deliveryOrdersProvider)
        .where((o) => o.status == DeliveryOrderStatus.delivered)
        .toList();

    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);

    // Combine history and completed orders for display
    final allOrders = [
      ...history.map((h) => _HistoryOrderItem.fromHistory(h)),
      ...completedOrders.map((o) => _HistoryOrderItem.fromOrder(o)),
    ];

    // Sort by date descending
    allOrders.sort((a, b) => b.date.compareTo(a.date));

    if (allOrders.isEmpty) {
      return _buildEmptyView(context);
    }

    return ListView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      children: [
        Text(
          'Delivery History (${allOrders.length})',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...allOrders.map((order) => _buildOrderCard(context, order, isDesktop)),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 64,
                color: AppColors.info,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Delivery History',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed deliveries will appear here',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, _HistoryOrderItem order, bool isDesktop) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Order #${order.orderId}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(order.date),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.straighten_rounded, size: 12, color: textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.distance,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${order.earnings.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Delivered',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _HistoryOrderItem {
  final String orderId;
  final String customerName;
  final double earnings;
  final DateTime date;
  final String distance;

  _HistoryOrderItem({
    required this.orderId,
    required this.customerName,
    required this.earnings,
    required this.date,
    required this.distance,
  });

  factory _HistoryOrderItem.fromHistory(DeliveryHistoryItem item) {
    return _HistoryOrderItem(
      orderId: item.orderId,
      customerName: item.customerName,
      earnings: item.earnings,
      date: item.date,
      distance: item.distance,
    );
  }

  factory _HistoryOrderItem.fromOrder(DeliveryOrder order) {
    return _HistoryOrderItem(
      orderId: order.orderId,
      customerName: order.customerName,
      earnings: order.deliveryFee,
      date: order.deliveredTime ?? order.orderTime,
      distance: order.distance,
    );
  }
}