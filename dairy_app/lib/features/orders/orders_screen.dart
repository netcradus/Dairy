import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import 'order_details_screen.dart';
import 'order_tracking_screen.dart';

/// Sawariya Dairy Phase 7 — Orders List Screen (with status tabs)
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(allOrdersProvider);
debugPrint('ORDERS COUNT: ${allOrders.length}');
debugPrint(
  'ORDERS: ${allOrders.map((o) => o.id).toList()}',
);
    final upcoming = ref.watch(upcomingOrdersProvider);
    final completed = ref.watch(completedOrdersProvider);
    final cancelled = ref.watch(cancelledOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveHorizontalPadding,
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: 'All (${allOrders.length})'),
                Tab(text: 'Upcoming (${upcoming.length})'),
                const Tab(text: 'Completed'),
                const Tab(text: 'Cancelled'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderList(orders: allOrders),
                _OrderList(orders: upcoming),
                _OrderList(orders: completed),
                _OrderList(orders: cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Scrollable list of order cards for a tab
/// ─────────────────────────────────────────────
class _OrderList extends StatelessWidget {
  final List<Order> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalPadding,
        vertical: AppSizes.p16,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p14),
          child: _OrderCard(order: orders[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 50,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Orders Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your orders in this category will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Individual Order Card
/// ─────────────────────────────────────────────
class _OrderCard extends ConsumerWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(order.status);
    final statusIcon = _statusIcon(order.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: Order ID, Date, Status chip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(order.orderDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        order.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: AppColors.border),

          // Items row (thumbnail strip + names)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                // Product thumbnails
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: Stack(
                    children: [
                      ...List.generate(
                        order.items.length.clamp(0, 3),
                        (i) => Positioned(
                          left: i * 30.0,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.surface, width: 2),
                            ),
                            child: const Icon(Icons.water_drop_rounded,
                                color: AppColors.primaryBlue, size: 22),
                          ),
                        ),
                      ),
                      if (order.items.length > 3)
                        Positioned(
                          left: 3 * 30.0,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '+${order.items.length - 3}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ),
                SizedBox(
                    width: 16 + (order.items.length.clamp(0, 3) - 1) * 30.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.items
                            .take(2)
                            .map((i) => i.product.title)
                            .join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer: total + action buttons
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Track button (only for active orders)
                if (order.isUpcoming) ...[
                  _SmallButton(
                    label: 'Track',
                    icon: Icons.location_searching_rounded,
                    outlined: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(order: order),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                _SmallButton(
                  label: 'Details',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return const Color(0xFF0284C7);
      case OrderStatus.confirmed:
        return const Color(0xFF7C3AED);
      case OrderStatus.preparing:
        return const Color(0xFFF59E0B);
      case OrderStatus.outForDelivery:
        return AppColors.primaryBlue;
      case OrderStatus.delivered:
        return AppColors.freshGreen;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return Icons.receipt_long_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_rounded;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  •  $hour:$min $amPm';
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const _SmallButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
        elevation: 0,
      ),
    );
  }
}
