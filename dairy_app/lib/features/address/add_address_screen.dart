import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';

/// Sawariya Dairy Phase 6 — Add New Address Screen
class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _houseFlatController = TextEditingController();
  final _streetAreaController = TextEditingController();
  final _cityController = TextEditingController(text: 'Indore');
  final _stateController = TextEditingController(text: 'Madhya Pradesh');
  final _pinCodeController = TextEditingController();
  String _selectedLabel = 'Home';
  bool _isDefault = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _houseFlatController.dispose();
    _streetAreaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  void _onSaveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
        label: _selectedLabel,
        fullName: _fullNameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        houseFlat: _houseFlatController.text.trim(),
        streetArea: _streetAreaController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        isDefault: _isDefault,
      );

      ref.read(addressesProvider.notifier).addAddress(newAddress);
      ref.read(selectedAddressIdProvider.notifier).state = newAddress.id;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery address saved successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Delivery Address'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSizes.borderLarge,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact & Address Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // Tag selection (Home / Office / Other)
                  Row(
                    children: ['Home', 'Office', 'Other'].map((label) {
                      final isSelected = _selectedLabel == label;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedLabel = label);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // Full Name
                  AppTextField(
                    label: 'Full Name',
                    hint: 'e.g. Rahul Sharma',
                    controller: _fullNameController,
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: AppColors.primaryBlue),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter full name' : null,
                  ),
                  const SizedBox(height: AppSizes.p14),

                  // Mobile Number
                  AppTextField(
                    label: 'Mobile Number',
                    hint: 'e.g. 9876543210',
                    controller: _mobileController,
                    prefixIcon: const Icon(Icons.phone_android_rounded,
                        color: AppColors.primaryBlue),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.length < 10
                        ? 'Enter valid 10-digit mobile number'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.p14),

                  // House / Flat / Building
                  AppTextField(
                    label: 'House / Flat / Building Name',
                    hint: 'e.g. Flat 402, Sunshine Heights',
                    controller: _houseFlatController,
                    prefixIcon: const Icon(Icons.home_outlined,
                        color: AppColors.primaryBlue),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter house/flat details'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.p14),

                  // Street / Area / Locality
                  AppTextField(
                    label: 'Street / Area / Locality',
                    hint: 'e.g. MG Road, Vijay Nagar',
                    controller: _streetAreaController,
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: AppColors.primaryBlue),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter street/area'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.p14),

                  // City & PIN Code (Row)
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'City',
                          hint: 'e.g. Indore',
                          controller: _cityController,
                          prefixIcon: const Icon(Icons.location_city_rounded,
                              color: AppColors.primaryBlue),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter city' : null,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: AppTextField(
                          label: 'PIN Code',
                          hint: 'e.g. 452010',
                          controller: _pinCodeController,
                          prefixIcon: const Icon(Icons.pin_drop_outlined,
                              color: AppColors.primaryBlue),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.length < 6
                              ? 'Enter 6-digit PIN'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p14),

                  // State
                  AppTextField(
                    label: 'State',
                    hint: 'e.g. Madhya Pradesh',
                    controller: _stateController,
                    prefixIcon: const Icon(Icons.map_outlined,
                        color: AppColors.primaryBlue),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter state' : null,
                  ),
                  const SizedBox(height: AppSizes.p14),

                  // Checkbox: Set as Default Address
                  CheckboxListTile(
                    value: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val ?? false),
                    title: const Text(
                      'Make this my primary default delivery address',
                      style: TextStyle(fontSize: 13),
                    ),
                    activeColor: AppColors.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: AppSizes.p20),

                  // Save Button
                  AppButton(
                    text: 'Save Address & Select',
                    onPressed: _onSaveAddress,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
