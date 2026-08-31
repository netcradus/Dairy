import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../models/address.dart';

/// Address Tile for Address List & Checkout Screen
class AddressTile extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onSetDefault;

  const AddressTile({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelect,
    this.onDelete,
    this.onEdit,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightBlue : AppColors.surface,
        borderRadius: AppSizes.borderMedium,
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onSelect,
            child: Container(
              margin: const EdgeInsets.only(top: 4, right: 10, left: 4),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                  width: isSelected ? 5.5 : 2,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onSelect,
              borderRadius: AppSizes.borderMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.border,
                          borderRadius: AppSizes.borderSmall,
                        ),
                        child: Text(
                          address.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        address.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: AppSizes.borderSmall,
                            border: Border.all(
                                color: AppColors.primaryBlue, width: 0.5),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address.fullAddressText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_android_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        address.mobileNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (onDelete != null || onEdit != null || onSetDefault != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) onEdit!();
                if (value == 'delete' && onDelete != null) onDelete!();
                if (value == 'default' && onSetDefault != null) onSetDefault!();
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (onSetDefault != null && !address.isDefault)
                  const PopupMenuItem<String>(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.star_outline_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Set as Default'),
                      ],
                    ),
                  ),
                if (onEdit != null)
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}
