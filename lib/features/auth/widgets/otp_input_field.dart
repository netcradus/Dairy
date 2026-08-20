import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Touch-Friendly 6-Digit OTP PIN Input Widget
class OtpInputField extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputField({
    super.key,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Pre-populate with space to detect backspace on empty fields across all platforms (mobile IME)
    _controllers = List.generate(6, (_) => TextEditingController(text: ' '));
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) {
      // Put the space back so we can detect future deletions
      _controllers[index].text = ' ';
      
      if (index > 0) {
        // Clear the previous controller's digit and set it back to space
        _controllers[index - 1].text = ' ';
        _focusNodes[index - 1].requestFocus();
      }
    } else {
      final cleanValue = value.replaceAll(' ', '');
      if (cleanValue.isNotEmpty) {
        final digit = cleanValue.substring(cleanValue.length - 1);
        _controllers[index].value = TextEditingValue(
          text: digit,
          selection: TextSelection.collapsed(offset: digit.length),
        );

        if (index < 5) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      }
    }

    final code = _controllers.map((c) {
      return c.text.replaceAll(' ', '');
    }).join();

    if (widget.onChanged != null) {
      widget.onChanged!(code);
    }
    if (code.length == 6) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(skipTraversal: true),
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                }
              }
            },
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textInputAction:
                  index < 5 ? TextInputAction.next : TextInputAction.done,
              onFieldSubmitted: (_) {
                final code = _controllers.map((c) => c.text.replaceAll(' ', '')).join();
                if (code.length == 6) {
                  widget.onCompleted(code);
                }
              },
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(2),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
              ],
              onChanged: (value) => _onDigitChanged(index, value),
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: AppSizes.borderMedium,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSizes.borderMedium,
                  borderSide: BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
