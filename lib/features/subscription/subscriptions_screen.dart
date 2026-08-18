import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../core/widgets/category_image.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../subscription/edit_subscription_screen.dart';

/// Sawariya Dairy Phase 7 — Subscriptions Home Screen
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final active = ref.watch(activeSubscriptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Subscriptions'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditSubscriptionScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'New',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: subscriptions.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveHorizontalPadding,
                vertical: AppSizes.p16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p12, vertical: AppSizes.p8),
                    decoration: const BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: AppSizes.borderLarge,
                    ),
                    child: Text(
                      '${active.length} Active · ${subscriptions.length} Total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  ...subscriptions.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.p14),
                      child: _SubscriptionCard(
                        subscription: s,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditSubscriptionScreen(subscription: s),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.subscriptions_outlined,
                  size: 50,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            const Text(
              'No Subscriptions Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            const Text(
              'Subscribe to your favourite dairy products and get them delivered fresh daily with a 10% recurring discount.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditSubscriptionScreen()),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Create Subscription',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSizes.borderMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends ConsumerWidget {
  final Subscription subscription;
  final VoidCallback onTap;

  const _SubscriptionCard({
    required this.subscription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = subscription.product;
    final statusColor = _statusColor(subscription.status);
    final nextDate = subscription.nextDeliveryDate;
    final isCancelled = subscription.isCancelled;

    return Dismissible(
      key: ValueKey(subscription.id),
      direction: isCancelled
          ? DismissDirection.horizontal
          : DismissDirection.endToStart,
      background: Container(
        decoration: const BoxDecoration(
          color: AppColors.error,
          borderRadius: AppSizes.borderLarge,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        child: const Icon(Icons.delete_rounded,
            color: Colors.white, size: 22),
      ),
      onDismissed: (_) {
        ref.read(subscriptionsProvider.notifier).cancel(subscription.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription cancelled')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSizes.borderLarge,
          border: Border.all(
            color: isCancelled
                ? AppColors.border
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppSizes.borderLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: product, status chip
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: AppSizes.borderSmall,
                        ),
                        child: Center(
                          child: CategoryImage(
                            imageUrl: AppAssets.milkPlaceholder,
                            size: 32,
                            radius: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${p.unit} • ${p.categoryName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          subscription.status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: AppColors.border),
                // Middle: details
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Icons.repeat_rounded,
                        'Frequency',
                        subscription.frequency.label,
                      ),
                      const SizedBox(height: 6),
                      _buildDetailRow(
                          Icons.numbers_rounded,
                        'Qty per delivery',
                        '${subscription.quantity} ${p.unit}',
                      ),
                      const SizedBox(height: 6),
                      _buildDetailRow(
                        Icons.schedule_rounded,
                        'Next delivery',
                        nextDate == null
                            ? '—'
                            : DateFormat.yMMMd().add_jm().format(nextDate),
                      ),
                      const SizedBox(height: 6),
                      _buildDetailRow(
                        Icons.local_shipping_outlined,
                        'Delivery slot',
                        subscription.deliveryTimeSlot,
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: AppColors.border),
                // Bottom: pricing + actions
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${subscription.priceAfterDiscountPerDelivery.toStringAsFixed(2)} / delivery',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Text(
                            '₹${subscription.monthlyCost.toStringAsFixed(0)} / month',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (subscription.status == SubscriptionStatus.active)
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(subscriptionsProvider.notifier)
                                .pause(subscription.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Subscription paused')),
                            );
                          },
                          icon: const Icon(Icons.pause_rounded,
                              size: 16, color: AppColors.primaryBlue),
                          label: const Text(
                            'Pause',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.primaryBlue),
                            shape: const RoundedRectangleBorder(
                                borderRadius: AppSizes.borderMedium),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      if (subscription.status == SubscriptionStatus.paused)
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(subscriptionsProvider.notifier)
                                .resume(subscription.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Subscription resumed')),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded,
                              size: 16, color: AppColors.freshGreen),
                          label: const Text(
                            'Resume',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.freshGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.freshGreen),
                            shape: const RoundedRectangleBorder(
                                borderRadius: AppSizes.borderMedium),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.freshGreen;
      case SubscriptionStatus.paused:
        return const Color(0xFFF59E0B);
      case SubscriptionStatus.cancelled:
        return AppColors.error;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
