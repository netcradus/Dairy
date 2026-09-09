import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../services/location_service.dart';

/// Sawariya Dairy Phase 6 & 8 — Add / Edit Delivery Address Screen
class AddAddressScreen extends ConsumerStatefulWidget {
  final Address? addressToEdit;
  final bool autoDetectLocation;
  const AddAddressScreen({
    super.key,
    this.addressToEdit,
    this.autoDetectLocation = false,
  });

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _houseFlatController;
  late final TextEditingController _streetAreaController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pinCodeController;
  String _selectedLabel = 'Home';

  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.addressToEdit;
    _fullNameController = TextEditingController(text: addr?.fullName ?? '');
    _mobileController = TextEditingController(text: addr?.mobileNumber ?? '');
    _houseFlatController = TextEditingController(text: addr?.houseFlat ?? '');
    _streetAreaController = TextEditingController(text: addr?.streetArea ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _stateController = TextEditingController(text: addr?.state ?? '');
    _pinCodeController = TextEditingController(text: addr?.pinCode ?? '');
    if (addr != null) {
      _selectedLabel = addr.label;
      _latitude = addr.latitude;
      _longitude = addr.longitude;
    }

    if (widget.autoDetectLocation && widget.addressToEdit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onUseCurrentLocation();
        }
      });
    }
  }

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

  /// Fetches real device GPS coordinates and reverse geocodes into address fields
  Future<void> _onUseCurrentLocation() async {
    setState(() => _isLocating = true);
    final locationService = ref.read(locationServiceProvider);

    try {
      final result = await locationService.getCurrentPositionDetailed();
      if (!mounted) return;

      switch (result.status) {
        case LocationResultStatus.servicesDisabled:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorMessage ??
                    'Location services are turned off. Please turn on GPS / Location in your device settings.',
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
          setState(() => _isLocating = false);
          return;

        case LocationResultStatus.permissionDenied:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorMessage ??
                    'Location permission was denied. Please allow location access to use your current location.',
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
          setState(() => _isLocating = false);
          return;

        case LocationResultStatus.permissionDeniedForever:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorMessage ??
                    'Location permission is permanently denied in settings. Please enable location permission for this app in Settings.',
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
          setState(() => _isLocating = false);
          return;

        case LocationResultStatus.timeoutOrError:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorMessage ??
                    'Could not determine GPS coordinates. Please check your signal and try again.',
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
          setState(() => _isLocating = false);
          return;

        case LocationResultStatus.success:
          final position = result.position;
          if (position == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not obtain valid GPS coordinates.'),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() => _isLocating = false);
            return;
          }

          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
          });

          // Perform reverse geocoding to fill address fields
          final geoAddress = await locationService.reverseGeocode(
            position.latitude,
            position.longitude,
          );

          if (!mounted) return;

          if (geoAddress != null && geoAddress.hasAnyField) {
            // Auto-fill available address fields without overwriting Full Name / Mobile
            if (geoAddress.houseOrBuilding != null &&
                geoAddress.houseOrBuilding!.trim().isNotEmpty) {
              _houseFlatController.text = geoAddress.houseOrBuilding!.trim();
            }
            if (geoAddress.streetOrArea != null &&
                geoAddress.streetOrArea!.trim().isNotEmpty) {
              _streetAreaController.text = geoAddress.streetOrArea!.trim();
            }
            if (geoAddress.city != null && geoAddress.city!.trim().isNotEmpty) {
              _cityController.text = geoAddress.city!.trim();
            }
            if (geoAddress.state != null && geoAddress.state!.trim().isNotEmpty) {
              _stateController.text = geoAddress.state!.trim();
            }
            if (geoAddress.postalCode != null &&
                geoAddress.postalCode!.trim().isNotEmpty) {
              _pinCodeController.text = geoAddress.postalCode!.trim();
            }

            final capturedCity =
                geoAddress.city?.trim().isNotEmpty == true
                    ? geoAddress.city!.trim()
                    : 'Current location';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location captured and address auto-filled: $capturedCity (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
                ),
                backgroundColor: AppColors.freshGreen,
                duration: const Duration(seconds: 4),
              ),
            );
          } else {
            // Coordinates retained even if reverse geocoding is unavailable
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'GPS coordinates captured (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}), but address details could not be auto-filled. Please enter address manually.',
                ),
                backgroundColor: AppColors.primaryBlue,
                duration: const Duration(seconds: 4),
              ),
            );
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _onSaveAddress() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() => _isSaving = true);
    final editingAddr = widget.addressToEdit;
    final isEdit = editingAddr != null;
    final locationService = ref.read(locationServiceProvider);

    final house = _houseFlatController.text.trim();
    final street = _streetAreaController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final pin = _pinCodeController.text.trim();

    double? resolvedLat = _latitude;
    double? resolvedLng = _longitude;

    // Determine if address text changed during edit
    final addressTextChanged = isEdit &&
        (editingAddr.houseFlat != house ||
            editingAddr.streetArea != street ||
            editingAddr.city != city ||
            editingAddr.state != state ||
            editingAddr.pinCode != pin);

    // If coordinates are missing or address changed, perform geocoding
    if (resolvedLat == null || resolvedLng == null || addressTextChanged) {
      final fullQuery = [house, street, city, state, pin, 'India']
          .where((s) => s.isNotEmpty)
          .join(', ');
      final fallbackQuery =
          [city, state, pin, 'India'].where((s) => s.isNotEmpty).join(', ');

      final geocoded = await locationService.geocodeAddress(
        fullQuery,
        fallbackQuery: fallbackQuery,
      );

      if (geocoded != null) {
        resolvedLat = geocoded.latitude;
        resolvedLng = geocoded.longitude;
      } else if (isEdit && editingAddr.hasCoordinates) {
        // Preserve existing valid coordinates if geocoding failed
        resolvedLat = editingAddr.latitude;
        resolvedLng = editingAddr.longitude;
      }
    }

    final existingAddresses = ref.read(addressesProvider);
    final isDefault = editingAddr?.isDefault ?? existingAddresses.isEmpty;

    final address = Address(
      id: isEdit
          ? editingAddr.id
          : 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: _selectedLabel,
      fullName: _fullNameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      houseFlat: house,
      streetArea: street,
      city: city,
      state: state,
      pinCode: pin,
      isDefault: isDefault,
      latitude: resolvedLat,
      longitude: resolvedLng,
    );

    if (isEdit) {
      await ref.read(addressesProvider.notifier).updateAddress(address);
    } else {
      await ref.read(addressesProvider.notifier).addAddress(address);
      ref.read(selectedAddressIdProvider.notifier).state = address.id;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit
            ? 'Delivery address updated successfully!'
            : 'Delivery address saved successfully!'),
      ),
    );

    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.addressToEdit != null;
    final hasCoords = _latitude != null && _longitude != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Delivery Address' : 'Add Delivery Address'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSizes.borderLarge,
              boxShadow: [
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
                  // ── PROMINENT "USE CURRENT LOCATION" ACTION BANNER ──
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSizes.p16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryBlue.withValues(alpha: 0.08),
                          AppColors.lightBlue.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.35),
                        width: 1.4,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLocating ? null : _onUseCurrentLocation,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _isLocating
                                    ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.my_location_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isLocating
                                          ? 'Detecting GPS Location...'
                                          : 'Use Current Location',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isLocating
                                          ? 'Requesting high-accuracy coordinates & address'
                                          : 'Tap to auto-fill address using real device GPS',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── GPS COORDINATES STATUS BADGE ──
                  if (hasCoords)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.p16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.freshGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.freshGreen.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.gps_fixed_rounded,
                            size: 20,
                            color: AppColors.freshGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Real GPS Coordinates Attached',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.freshGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Latitude: ${(_latitude ?? 0.0).toStringAsFixed(6)}, Longitude: ${(_longitude ?? 0.0).toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed:
                                _isLocating ? null : _onUseCurrentLocation,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Re-detect',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── SECTION DIVIDER ──
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR ENTER DETAILS MANUALLY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
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
                    hint: 'Enter full name',
                    controller: _fullNameController,
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: AppColors.primaryBlue),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Please enter full name'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.p14),

                  // Mobile Number
                  AppTextField(
                    label: 'Mobile Number',
                    hint: 'Enter 10-digit mobile number',
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
                    hint: 'House / Flat / Building name',
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
                    hint: 'Street / Area / Locality',
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
                          hint: 'Enter city',
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
                          hint: 'Enter 6-digit PIN',
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
                    hint: 'Enter state',
                    controller: _stateController,
                    prefixIcon: const Icon(Icons.map_outlined,
                        color: AppColors.primaryBlue),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter state' : null,
                  ),
                  const SizedBox(height: AppSizes.p20),

                  // Save Button
                  AppButton(
                    text: _isSaving
                        ? 'Saving Address...'
                        : (isEdit
                            ? 'Update Address & Select'
                            : 'Save Address & Select'),
                    onPressed: _isSaving ? null : _onSaveAddress,
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
