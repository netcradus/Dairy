import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/category_image.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/product.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import '../../repositories/product_repository.dart';

class EditSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription? subscription;

  const EditSubscriptionScreen({super.key, this.subscription});

  @override
  ConsumerState<EditSubscriptionScreen> createState() =>
      _EditSubscriptionScreenState();
}

class _EditSubscriptionScreenState extends ConsumerState<EditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  late SubscriptionFrequency _selectedFrequency;
  late String _deliveryTimeSlot;
  late bool _includeIcePack;

  late final bool _isNew;
  late final List<Product> _availableProducts;
  late final Product _baseProduct;
  Product? _chosenProduct;

  @override
  void initState() {
    super.initState();
    final repo = ProductRepository();
    _availableProducts =
        _dedupe([...repo.getFreshDeals(), ...repo.getA2MilkProducts()]);

    final s = widget.subscription;
    if (s != null) {
      _isNew = false;
      _selectedFrequency = s.frequency;
      _deliveryTimeSlot = s.deliveryTimeSlot;
      _includeIcePack = s.includeIcePack;
      _baseProduct = s.product;
      _chosenProduct = s.product;
      _quantityController.text = s.quantity.toString();
    } else {
      _isNew = true;
      _selectedFrequency = SubscriptionFrequency.daily;
      _deliveryTimeSlot = 'Morning (6:00 AM - 9:00 AM)';
      _includeIcePack = true;
      _baseProduct = _availableProducts.first;
      _chosenProduct = _availableProducts.first;
      _quantityController.text = '1';
    }
  }

  static List<Product> _dedupe(List<Product> list) {
    final seen = <String>{};
    final out = <Product>[];
    for (final p in list) {
      if (seen.add(p.id)) out.add(p);
    }
    return out;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  DateTime _computeNextDelivery(SubscriptionFrequency frequency) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, 6);
    switch (frequency) {
      case SubscriptionFrequency.daily:
        return base.add(const Duration(days: 1));
      case SubscriptionFrequency.alternateDay:
        return base.add(const Duration(days: 2));
      case SubscriptionFrequency.weekly:
        return base.add(const Duration(days: 7));
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity < 1) return;

    final Product product = _chosenProduct ?? _baseProduct;
    final now = DateTime.now();

    final subscription = _isNew
        ? Subscription(
            id: 'sub_${now.millisecondsSinceEpoch}',
            product: product,
            quantity: quantity,
            frequency: _selectedFrequency,
            status: SubscriptionStatus.active,
            startDate: now,
            nextDeliveryDate: _computeNextDelivery(_selectedFrequency),
            deliveryTimeSlot: _deliveryTimeSlot,
            includeIcePack: _includeIcePack,
          )
        : widget.subscription!.copyWith(
            product: product,
            quantity: quantity,
            frequency: _selectedFrequency,
            deliveryTimeSlot: _deliveryTimeSlot,
            includeIcePack: _includeIcePack,
          );

    final notifier = ref.read(subscriptionsProvider.notifier);
    if (_isNew) {
      notifier.addSubscription(subscription);
    } else {
      notifier.updateQuantity(widget.subscription!.id, quantity);
      notifier.updateFrequency(widget.subscription!.id, _selectedFrequency);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isNew
            ? 'New subscription created successfully!'
            : 'Subscription updated successfully!'),
        backgroundColor: AppColors.freshGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final product = _chosenProduct ?? _baseProduct;
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isNew ? 'New Subscription' : 'Edit Subscription'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalPadding,
          vertical: AppSizes.p16,
        ),
        child: Center(
          child: Container(
            constraints:
                BoxConstraints(maxWidth: isDesktop ? 720 : double.infinity),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductSelector(),
                  const SizedBox(height: AppSizes.p20),
                  _buildFrequencySelector(),
                  const SizedBox(height: AppSizes.p20),
                  AppTextField(
                    label: 'Quantity per delivery',
                    hint: 'Enter number of units',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.numbers_rounded,
                        color: AppColors.primaryBlue),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Quantity is required';
                      final n = int.tryParse(v);
                      if (n == null || n < 1) return 'Enter a valid quantity';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.p20),
                  AppTextField(
                    label: 'Delivery Time Slot',
                    hint: 'e.g. Morning (6:00 AM - 9:00 AM)',
                    controller: TextEditingController(text: _deliveryTimeSlot),
                    prefixIcon:
                        const Icon(Icons.schedule_rounded, color: AppColors.primaryBlue),
                    validator: AppValidators.validateRequired,
                    onChanged: (v) => _deliveryTimeSlot = v,
                  ),
                  const SizedBox(height: AppSizes.p20),
                  SwitchListTile(
                    value: _includeIcePack,
                    onChanged: (v) => setState(() => _includeIcePack = v),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryBlue,
                    title: const Text(
                      'Include ice pack for freshness',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  _buildPricingPreview(product, quantity),
                  const SizedBox(height: AppSizes.p24),
                  AppButton(
                    text: _isNew ? 'Create Subscription' : 'Save Changes',
                    onPressed: _onSave,
                  ),
                  const SizedBox(height: AppSizes.p24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    final product = _chosenProduct ?? _baseProduct;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Product',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSizes.borderLarge,
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Product>(
              isExpanded: true,
              value: product,
              items: _availableProducts
                  .map((p) => DropdownMenuItem<Product>(
                        value: p,
                        child: Row(
                          children: [
                            CategoryImage(
                              imageUrl: p.imageUrl,
                              size: 22,
                              radius: 5,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('Rs.${p.price.toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                )),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (p) => setState(() => _chosenProduct = p),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Frequency',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        Wrap(
          spacing: AppSizes.p8,
          children: SubscriptionFrequency.values.map((f) {
            final selected = _selectedFrequency == f;
            return ChoiceChip(
              label: Text(f.label),
              selected: selected,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.textPrimary,
              ),
              onSelected: (_) => setState(() => _selectedFrequency = f),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPricingPreview(Product product, int quantity) {
    final perDelivery = product.price * quantity;
    final discount = perDelivery * product.discountPercentage / 100;
    final afterDiscount = (perDelivery - discount).clamp(0.0, double.infinity);
    final monthly = afterDiscount * _selectedFrequency.deliveriesPerMonth;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSizes.borderLarge,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing Preview',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          _pricingRow('Per delivery', 'Rs.${perDelivery.toStringAsFixed(2)}'),
          if (discount > 0)
            _pricingRow(
              'Subscription discount (10%)',
              '-Rs.${discount.toStringAsFixed(2)}',
              valueColor: AppColors.freshGreen,
            ),
          _pricingRow(
            'After discount',
            'Rs.${afterDiscount.toStringAsFixed(2)}',
            valueColor: AppColors.primaryBlue,
            bold: true,
          ),
          const SizedBox(height: AppSizes.p8),
          _pricingRow(
            'Est. monthly (${_selectedFrequency.label})',
            'Rs.${monthly.toStringAsFixed(0)}',
            valueColor: AppColors.textPrimary,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _pricingRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
