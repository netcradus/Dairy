import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';

const String _supportPhone = '+91 98765 43210';
const String _supportEmail = 'support@sawariyadairy.com';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitting = false;

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I modify or pause my milk subscription?',
      'a': 'Open Profile → Daily Milk Subscriptions to pause, resume or change '
          'your delivery frequency at any time.',
    },
    {
      'q': 'What are your delivery timings?',
      'a': 'Fresh dairy is delivered every morning between 6:00 AM and 9:00 AM, '
          'and evening slots between 5:00 PM and 8:00 PM.',
    },
    {
      'q': 'What if I receive a damaged or spoiled product?',
      'a': 'Raise a query using the form below or call us directly. We offer '
          'instant replacement or refund for genuine quality issues.',
    },
    {
      'q': 'Can I change my delivery address?',
      'a': 'Yes. Go to Profile → Saved Delivery Addresses to add or update '
          'addresses for your orders.',
    },
  ];

  Future<void> _launch(String url, String fallbackMessage) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(fallbackMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackMessage)),
        );
      }
    }
  }

  void _call() => _launch(
        'tel:${_supportPhone.replaceAll(RegExp(r'\s+'), '')}',
        'Could not launch dialer for $_supportPhone',
      );

  void _email() => _launch(
        'mailto:$_supportEmail',
        'Could not open email for $_supportEmail',
      );

  void _whatsapp() => _launch(
        'https://wa.me/${_supportPhone.replaceAll(RegExp(r'\s+'), '')}'
        '?text=${Uri.encodeComponent('Hi Sawariya Dairy, I need help with my order.')}',
        'Could not open WhatsApp',
      );

  void _submitQuery() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    // No backend in this build — simulate sending and confirm to the user.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _submitting = false);
      _nameController.clear();
      _phoneController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your query has been received. Our team will contact you shortly.'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: AppSizes.borderMedium,
        child: InkWell(
          borderRadius: AppSizes.borderMedium,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.p14),
            decoration: BoxDecoration(
              borderRadius: AppSizes.borderMedium,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 26),
                const SizedBox(height: AppSizes.p8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final maxWidth = isDesktop ? 760.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Support'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveHorizontalPadding,
              vertical: AppSizes.p24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact banner
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppSizes.borderXLarge,
                    gradient: AppColors.brandGradient,
                    boxShadow: AppColors.primaryShadow,
                  ),
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'We are here to help',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reach the Sawariya Dairy team anytime for orders, '
                        'deliveries and product support.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Row(
                        children: [
                          _actionButton(
                            icon: Icons.call_rounded,
                            label: 'Call',
                            onTap: _call,
                          ),
                          const SizedBox(width: AppSizes.p12),
                          _actionButton(
                            icon: Icons.mail_rounded,
                            label: 'Email',
                            onTap: _email,
                          ),
                          const SizedBox(width: AppSizes.p12),
                          _actionButton(
                            icon: Icons.chat_rounded,
                            label: 'WhatsApp',
                            onTap: _whatsapp,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.p14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppSizes.borderMedium,
                        ),
                        child: Column(
                          children: [
                            _contactRow(Icons.phone_rounded, _supportPhone),
                            const SizedBox(height: 8),
                            _contactRow(Icons.email_rounded, _supportEmail),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p32),

                // Raise a query
                const Text(
                  'Raise a Query',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.p12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSizes.borderLarge,
                    border: Border.all(color: AppColors.border, width: 1.0),
                    boxShadow: AppColors.cardShadowSm,
                  ),
                  padding: const EdgeInsets.all(AppSizes.p20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Your Name'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: AppSizes.p14),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration('Phone Number'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (v.trim().length < 10) return 'Enter a valid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.p14),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: _inputDecoration('How can we help?'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please describe your issue' : null,
                        ),
                        const SizedBox(height: AppSizes.p20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submitQuery,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSizes.borderMedium,
                              ),
                              elevation: 0,
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Submit Query',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p32),

                // FAQ
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.p12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSizes.borderLarge,
                    border: Border.all(color: AppColors.border, width: 1.0),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _faqs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final faq = _faqs[index];
                      return ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p16,
                        ),
                        title: Text(
                          faq['q']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSizes.p16,
                              0,
                              AppSizes.p16,
                              AppSizes.p16,
                            ),
                            child: Text(
                              faq['a']!,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.p24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: AppSizes.p8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p14,
        vertical: AppSizes.p12,
      ),
      border: OutlineInputBorder(
        borderRadius: AppSizes.borderMedium,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSizes.borderMedium,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSizes.borderMedium,
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
    );
  }
}
