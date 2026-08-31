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
    final isLoading = ref.watch(addressLoadingProvider);
    final error = ref.watch(addressErrorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Static Header section
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p24, vertical: AppSizes.p16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'My Delivery Addresses',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
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
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Add New Address',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.textOnPrimary,
                          minimumSize: const Size(0, 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content section
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
                  child: Builder(
                    builder: (context) {
                      if (isLoading && addresses.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                        );
                      }
                      if (error != null && addresses.isEmpty) {
                        return Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSizes.p24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 48, color: AppColors.error),
                                const SizedBox(height: 12),
                                const Text(
                                  'Failed to Load Addresses',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (addresses.isEmpty) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.p24),
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppSizes.borderLarge,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                  style:
                                      TextStyle(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AddAddressScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Delivery Address'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Addresses List inside structured bounds
                      return ListView.builder(
                        itemCount: addresses.length,
                        padding: const EdgeInsets.only(bottom: AppSizes.p24),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return AddressTile(
                            address: address,
                            isSelected: address.id == selectedId,
                            onSelect: () {
                              ref
                                  .read(selectedAddressIdProvider.notifier)
                                  .state = address.id;
                              Navigator.pop(context);
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddAddressScreen(
                                      addressToEdit: address),
                                ),
                              );
                            },
                            onDelete: () {
                              ref
                                  .read(addressesProvider.notifier)
                                  .removeAddress(address.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Address deleted successfully')),
                              );
                            },
                            onSetDefault: () {
                              ref
                                  .read(addressesProvider.notifier)
                                  .setDefault(address.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Default address updated')),
                              );
                            },
                          );
                        },
                      );
                    },
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
