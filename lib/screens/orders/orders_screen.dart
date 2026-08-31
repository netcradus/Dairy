import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/order_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/status_badge.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedFilter = 'All';
  bool _updating = false;

  Future<void> _updateStatus(
    BuildContext context,
    AdminProvider provider,
    String orderId,
    OrderStatus newStatus,
  ) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await provider.updateOrderStatus(orderId, newStatus);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update order status. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final dividerColor = AppColors.dividerOf(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orders & Dispatch Management',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    'Track live morning & evening delivery orders and update statuses.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Pending',
                'Confirmed',
                'Preparing',
                'Out for Delivery',
                'Delivered',
                'Cancelled'
              ].map((status) {
                final isSelected = selectedFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => selectedFilter = status);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : textSecondary,
                    ),
                    backgroundColor: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : cardBorder,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Orders Table
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
              boxShadow: AppColors.cardShadow,
            ),
            child: _buildOrdersTable(
              context,
              provider,
              cardBg,
              textPrimary,
              textSecondary,
              textMuted,
              dividerColor,
              currencyFormatter,
              isDesktop,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(
    BuildContext context,
    AdminProvider provider,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color textMuted,
    Color dividerColor,
    NumberFormat currencyFormatter,
    bool isDesktop,
  ) {
    if (provider.ordersLoading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.ordersError != null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline,
                color: AppColors.statusCancelled, size: 36),
            SizedBox(height: 12),
            Text('Could not load orders.',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredOrders = provider.orders.where((order) {
      if (selectedFilter != 'All' &&
          order.status.displayName.toLowerCase() !=
              selectedFilter.toLowerCase()) {
        return false;
      }
      if (provider.searchQuery.isEmpty) return true;
      final q = provider.searchQuery.toLowerCase();
      return order.id.toLowerCase().contains(q) ||
          order.customerName.toLowerCase().contains(q) ||
          order.address.toLowerCase().contains(q) ||
          order.itemsSummary.toLowerCase().contains(q);
    }).toList();

    if (filteredOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, color: textMuted, size: 36),
              const SizedBox(height: 12),
              Text(
                selectedFilter == 'All'
                    ? 'No orders yet.'
                    : 'No $selectedFilter orders.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredOrders.length,
      separatorBuilder: (ctx, idx) => Divider(color: dividerColor),
      itemBuilder: (ctx, idx) {
        final order = filteredOrders[idx];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Order ID & Time
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Customer & Items
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.itemsSummary,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isDesktop) ...[
                      const SizedBox(height: 2),
                      Text(
                        order.address,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isDesktop)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.deliverySlot,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        order.paymentMode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              // Amount
              Expanded(
                flex: 2,
                child: Text(
                  currencyFormatter.format(order.amount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
              // Status Action Dropdown
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<OrderStatus>(
                    initialValue: order.status,
                    color: cardBg,
                    onSelected: (newStatus) => _updateStatus(
                      context,
                      provider,
                      order.id,
                      newStatus,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge.fromOrderStatus(order.status),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down,
                            size: 18, color: textSecondary),
                      ],
                    ),
                    itemBuilder: (ctx) => OrderStatus.values.map((s) {
                      return PopupMenuItem(
                        value: s,
                        child: Text(
                          s.displayName,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: textPrimary),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
