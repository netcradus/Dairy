import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum PaymentMethodType { cashOnDelivery, onlinePayment }

/// Payment Method Selectable Option Tile
class PaymentOptionTile extends StatelessWidget {
  final PaymentMethodType method;
  final PaymentMethodType selectedMethod;
  final ValueChanged<PaymentMethodType> onSelected;

  const PaymentOptionTile({
    super.key,
    required this.method,
    required this.selectedMethod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selectedMethod;

    final String title = method == PaymentMethodType.cashOnDelivery
        ? 'Cash on Delivery (COD)'
        : 'Online Payment (UPI / Cards / NetBanking)';

    final String subtitle = method == PaymentMethodType.cashOnDelivery
        ? 'Pay cash or UPI upon fresh delivery at your doorstep'
        : 'Instant 100% secure payment via GPay, PhonePe, Paytm or Card';

    final IconData icon = method == PaymentMethodType.cashOnDelivery
        ? Icons.payments_rounded
        : Icons.account_balance_wallet_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightBlue : AppColors.surface,
        borderRadius: AppSizes.borderMedium,
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () => onSelected(method),
        borderRadius: AppSizes.borderMedium,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p14),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                    width: isSelected ? 6 : 2,
                  ),
                ),
              ),
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
