import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/margin_constants.dart';
import '../extensions/context_extensions.dart';
import '../theme/font_weights.dart';

/// Tactile Custom Keypad for transaction amount entry and PIN security verification.
class CustomKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onDeletePress;
  final VoidCallback? onSubmitPress;
  final String submitLabel;
  final bool showDecimal;

  const CustomKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDeletePress,
    this.onSubmitPress,
    this.submitLabel = 'Done',
    this.showDecimal = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _KeypadButton(keyLabel: '1', onTap: () => onKeyPress('1')),
              _KeypadButton(keyLabel: '2', onTap: () => onKeyPress('2')),
              _KeypadButton(keyLabel: '3', onTap: () => onKeyPress('3')),
            ],
          ),
          verticalMarginXSmall,
          Row(
            children: [
              _KeypadButton(keyLabel: '4', onTap: () => onKeyPress('4')),
              _KeypadButton(keyLabel: '5', onTap: () => onKeyPress('5')),
              _KeypadButton(keyLabel: '6', onTap: () => onKeyPress('6')),
            ],
          ),
          verticalMarginXSmall,
          Row(
            children: [
              _KeypadButton(keyLabel: '7', onTap: () => onKeyPress('7')),
              _KeypadButton(keyLabel: '8', onTap: () => onKeyPress('8')),
              _KeypadButton(keyLabel: '9', onTap: () => onKeyPress('9')),
            ],
          ),
          verticalMarginXSmall,
          Row(
            children: [
              showDecimal
                  ? _KeypadButton(keyLabel: '.', onTap: () => onKeyPress('.'))
                  : const _KeypadButton(keyLabel: '', onTap: null),
              _KeypadButton(keyLabel: '0', onTap: () => onKeyPress('0')),
              _KeypadButton(
                icon: Icons.backspace_outlined,
                onTap: onDeletePress,
              ),
            ],
          ),
          if (onSubmitPress != null) ...[
            verticalMarginSmall,
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: onSubmitPress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  submitLabel,
                  style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                    fontWeight: FontWeights.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? keyLabel;
  final IconData? icon;
  final VoidCallback? onTap;

  const _KeypadButton({
    this.keyLabel,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final isPressedNotifier = ValueNotifier<bool>(false);

    if (keyLabel == '' && icon == null) {
      return Expanded(child: SizedBox(height: 56.h));
    }

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          isPressedNotifier.value = true;
        },
        onTapUp: (_) => isPressedNotifier.value = false,
        onTapCancel: () => isPressedNotifier.value = false,
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isPressedNotifier,
          builder: (context, isPressed, _) {
            return AnimatedScale(
              scale: isPressed ? 0.94 : 1.0,
              duration: const Duration(milliseconds: 80),
              child: Container(
                height: 56.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isPressed
                      ? colorScheme.surfaceContainerHigh
                      : colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: context.customColors.glassStroke, width: 1.0),
                ),
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(
                        icon,
                        color: colorScheme.onSurface,
                        size: 22.sp,
                      )
                    : Text(
                        keyLabel!,
                        style: (textTheme.headlineMedium ?? const TextStyle())
                            .copyWith(
                          fontWeight: FontWeights.semiBold,
                          color: colorScheme.onSurface,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
