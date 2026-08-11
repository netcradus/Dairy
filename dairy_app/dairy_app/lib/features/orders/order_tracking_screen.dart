import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order.dart';

/// Single tracking step on the timeline
class _TrackingStep {
  final String label;
  final IconData icon;

  const _TrackingStep(this.label, this.icon);
}

/// Order Tracking Timeline Screen
class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  static const List<_TrackingStep> _steps = [
    _TrackingStep('Order Placed', Icons.receipt_long_rounded),
    _TrackingStep('Confirmed', Icons.check_circle_outline_rounded),
    _TrackingStep('Preparing Fresh', Icons.restaurant_rounded),
    _TrackingStep('Out for Delivery', Icons.delivery_dining_rounded),
    _TrackingStep('Delivered', Icons.home_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStep = order.status.stepIndex;
    final isCancelled = order.isCancelled;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? AppColors.error.withValues(alpha: 0.08)
                        : AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCancelled
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isCancelled
                              ? AppColors.error.withValues(alpha: 0.12)
                              : AppColors.primaryBlue.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCancelled
                              ? Icons.cancel_outlined
                              : Icons.local_shipping_rounded,
                          color: isCancelled
                              ? AppColors.error
                              : AppColors.primaryBlue,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCancelled
                                  ? 'Order Cancelled'
                                  : order.status.label,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isCancelled
                                    ? AppColors.error
                                    : AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              order.estimatedDeliveryTime,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Timeline
                if (!isCancelled) ...[
                  const Text(
                    'Delivery Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
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
                      children: List.generate(_steps.length, (i) {
                        final step = _steps[i];
                        final isDone = i <= currentStep;
                        final isActive = i == currentStep;
                        final isLast = i == _steps.length - 1;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon + vertical line column
                            Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? AppColors.primaryBlue
                                        : AppColors.border,
                                    shape: BoxShape.circle,
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryBlue
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    step.icon,
                                    size: 20,
                                    color: isDone
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 44,
                                    color: isDone && i < currentStep
                                        ? AppColors.primaryBlue
                                        : AppColors.border,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Label + time
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 8,
                                  bottom: isLast ? 0 : 34,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            step.label,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isActive
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isDone
                                                  ? AppColors.textPrimary
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                          if (isActive) ...[
                                            const SizedBox(height: 3),
                                            const Text(
                                              'Current stage',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.primaryBlue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (isDone)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.freshGreen,
                                        size: 18,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Delivery Address Summary
                _InfoCard(
                  title: 'Delivery Address',
                  icon: Icons.location_on_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.deliveryAddress.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.deliveryAddress.fullAddressText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.deliveryAddress.mobileNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Method
                _InfoCard(
                  title: 'Payment Method',
                  icon: Icons.payment_rounded,
                  child: Text(
                    order.paymentMethod,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
