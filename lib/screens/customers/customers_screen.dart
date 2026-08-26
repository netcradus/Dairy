import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../models/customer_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/status_badge.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final filteredCustomers = provider.customers.where((c) {
      if (provider.searchQuery.isEmpty) return true;
      final q = provider.searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.deliveryZone.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Management',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Manage dairy subscriptions, addresses, and customer wallets.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showCustomerDialog(context, provider, null),
                icon: const Icon(Icons.person_add_alt_1_rounded,
                    size: 18, color: Colors.white),
                label: Text(
                  'Add Customer',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Customer List Table / Cards
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppColors.cardShadow,
            ),
            child: filteredCustomers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No customers found.',
                        style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textMuted),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredCustomers.length,
                    separatorBuilder: (ctx, idx) => const Divider(),
                    itemBuilder: (ctx, idx) {
                      final customer = filteredCustomers[idx];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : 'C',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${customer.phone} • ${customer.deliveryZone}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (!isDesktop) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      customer.subscriptionPlan,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                      customer.subscriptionPlan,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      customer.milkPreference,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormatter
                                        .format(customer.walletBalance),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: customer.walletBalance >= 0
                                          ? AppColors.revenueGreen
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  StatusBadge.fromString(customer.status),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Actions: Edit and Delete
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18, color: AppColors.primary),
                                  tooltip: 'Edit Customer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  onPressed: () => _showCustomerDialog(
                                      context, provider, customer),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      size: 18, color: Color(0xFFEF4444)),
                                  tooltip: 'Delete Customer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  onPressed: () => _showDeleteConfirmation(
                                      context, provider, customer),
                                ),
                              ],
                            ),
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

  void _showCustomerDialog(
      BuildContext context, AdminProvider provider, DairyCustomer? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final zoneCtrl = TextEditingController(
        text: existing?.deliveryZone ?? 'Sector 7x Highrise Belt');
    final planCtrl = TextEditingController(
        text: existing?.subscriptionPlan ?? 'Daily Morning (2 Litres)');
    final milkCtrl = TextEditingController(
        text: existing?.milkPreference ?? 'Pure A2 Cow Milk');
    final walletCtrl = TextEditingController(
        text: existing != null ? '${existing.walletBalance.toInt()}' : '500');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Customer Details' : 'Add New Dairy Subscriber',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Customer Full Name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: emailCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Email Address'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Delivery Address & Flat/Apt'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: zoneCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Delivery Zone'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: walletCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Wallet Balance (₹)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: planCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Subscription Plan (e.g. Daily Morning 2L)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: milkCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Milk Variety Preference'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                if (isEdit) {
                  provider.updateCustomer(
                    existing.copyWith(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim().isEmpty
                          ? existing.phone
                          : phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim().isEmpty
                          ? existing.email
                          : emailCtrl.text.trim(),
                      address: addressCtrl.text.trim().isEmpty
                          ? existing.address
                          : addressCtrl.text.trim(),
                      deliveryZone: zoneCtrl.text.trim().isEmpty
                          ? existing.deliveryZone
                          : zoneCtrl.text.trim(),
                      subscriptionPlan: planCtrl.text.trim().isEmpty
                          ? existing.subscriptionPlan
                          : planCtrl.text.trim(),
                      milkPreference: milkCtrl.text.trim().isEmpty
                          ? existing.milkPreference
                          : milkCtrl.text.trim(),
                      walletBalance: double.tryParse(walletCtrl.text) ??
                          existing.walletBalance,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Customer "${nameCtrl.text}" updated successfully!')),
                  );
                } else {
                  provider.addCustomer(
                    DairyCustomer(
                      id: 'CUST-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim().isEmpty
                          ? '+91 99999 00000'
                          : phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim().isEmpty
                          ? '${nameCtrl.text.toLowerCase().replaceAll(' ', '')}@gmail.com'
                          : emailCtrl.text.trim(),
                      address: addressCtrl.text.trim().isEmpty
                          ? 'Flat 101, Noida'
                          : addressCtrl.text.trim(),
                      deliveryZone: zoneCtrl.text.trim().isEmpty
                          ? 'Central Noida Hub'
                          : zoneCtrl.text.trim(),
                      subscriptionPlan: planCtrl.text.trim().isEmpty
                          ? 'Daily Morning (2 Litres)'
                          : planCtrl.text.trim(),
                      milkPreference: milkCtrl.text.trim().isEmpty
                          ? 'Pure A2 Cow Milk'
                          : milkCtrl.text.trim(),
                      walletBalance: double.tryParse(walletCtrl.text) ?? 500.0,
                      status: 'Active',
                      joinedDate: 'Today',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Customer "${nameCtrl.text}" added successfully!')),
                  );
                }
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isEdit ? 'Save Changes' : 'Save Customer',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, AdminProvider provider, DairyCustomer customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(
              'Delete Customer',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove customer "${customer.name}" (${customer.id})? All associated subscriptions will be removed.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteCustomer(customer.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Customer "${customer.name}" removed successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
