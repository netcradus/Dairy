import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/address_tile.dart';
import '../../providers/address_provider.dart';
import 'add_address_screen.dart';

/// Sawariya Dairy Phase 6 — Saved Addresses Selection Screen
class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    final selectedId = ref.watch(selectedAddressIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Delivery Address'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Saved Addresses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddAddressScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                      label: const Text('Add New'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSizes.borderMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                if (addresses.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSizes.borderLarge,
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.location_off_outlined,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        const Text(
                          'No Addresses Saved',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please add a delivery address to proceed with order checkout.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddAddressScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Delivery Address'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ...addresses.map(
                    (address) => AddressTile(
                      address: address,
                      isSelected: address.id == selectedId,
                      onSelect: () {
                        ref.read(selectedAddressIdProvider.notifier).state =
                            address.id;
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
