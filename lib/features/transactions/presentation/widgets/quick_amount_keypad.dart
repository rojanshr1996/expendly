import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/font_weights.dart';

/// Reusable tactile numeric keypad widget designed for rapid amount entry
/// in Quick Add, Rapid Entry, and Daily Entry modes.
class QuickAmountKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onDeletePress;
  final VoidCallback? onSubmitPress;
  final String? submitLabel;
  final bool showDecimal;
  final bool isSubmitEnabled;
  final Widget? customActionRow;

  const QuickAmountKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDeletePress,
    this.onSubmitPress,
    this.submitLabel,
    this.showDecimal = true,
    this.isSubmitEnabled = true,
    this.customActionRow,
  });

  /// Helper utility to append a key to an amount string with input validation
  /// (max 2 decimal places, max length 9, proper decimal point handling).
  static String appendKey(String current, String key) {
    if (key == '.') {
      if (current.isEmpty) return '0.';
      if (current.contains('.')) return current;
      return '$current.';
    }

    if (current == '0') {
      return key;
    }

    if (current.contains('.')) {
      final parts = current.split('.');
      if (parts.length > 1 && parts[1].length >= 2) {
        return current; // Max 2 decimal digits
      }
    }

    // Limit maximum total amount length (excluding decimal point)
    final digitsOnly = current.replaceAll('.', '');
    if (digitsOnly.length >= 9) {
      return current;
    }

    return '$current$key';
  }

  /// Helper utility to handle backspace on an amount string
  static String removeLastKey(String current) {
    if (current.isEmpty) return '';
    if (current.length == 1) return '';
    return current.substring(0, current.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTablet(context);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final rowSpacing = isTablet ? 12.0 : 12.h;
    final buttonHeight = isTablet ? 60.0 : 52.h;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24.0 : 16.w,
        vertical: isTablet ? 12.0 : 8.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _KeypadButton(
                keyLabel: '1',
                height: buttonHeight,
                onTap: () => onKeyPress('1'),
              ),
              _KeypadButton(
                keyLabel: '2',
                height: buttonHeight,
                onTap: () => onKeyPress('2'),
              ),
              _KeypadButton(
                keyLabel: '3',
                height: buttonHeight,
                onTap: () => onKeyPress('3'),
              ),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            children: [
              _KeypadButton(
                keyLabel: '4',
                height: buttonHeight,
                onTap: () => onKeyPress('4'),
              ),
              _KeypadButton(
                keyLabel: '5',
                height: buttonHeight,
                onTap: () => onKeyPress('5'),
              ),
              _KeypadButton(
                keyLabel: '6',
                height: buttonHeight,
                onTap: () => onKeyPress('6'),
              ),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            children: [
              _KeypadButton(
                keyLabel: '7',
                height: buttonHeight,
                onTap: () => onKeyPress('7'),
              ),
              _KeypadButton(
                keyLabel: '8',
                height: buttonHeight,
                onTap: () => onKeyPress('8'),
              ),
              _KeypadButton(
                keyLabel: '9',
                height: buttonHeight,
                onTap: () => onKeyPress('9'),
              ),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            children: [
              showDecimal
                  ? _KeypadButton(
                      keyLabel: '.',
                      height: buttonHeight,
                      onTap: () => onKeyPress('.'),
                    )
                  : _KeypadButton(
                      keyLabel: '',
                      height: buttonHeight,
                      onTap: null,
                    ),
              _KeypadButton(
                keyLabel: '0',
                height: buttonHeight,
                onTap: () => onKeyPress('0'),
              ),
              _KeypadButton(
                icon: Icons.backspace_outlined,
                height: buttonHeight,
                onTap: onDeletePress,
              ),
            ],
          ),
          if (customActionRow != null) ...[
            SizedBox(height: rowSpacing * 1.5),
            customActionRow!,
          ] else if (onSubmitPress != null && submitLabel != null) ...[
            SizedBox(height: rowSpacing * 1.5),
            SizedBox(
              width: double.infinity,
              height: isTablet ? 54.0 : 48.h,
              child: ElevatedButton(
                onPressed: isSubmitEnabled ? onSubmitPress : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  submitLabel!,
                  style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                    fontWeight: FontWeights.bold,
                    color: isSubmitEnabled
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.38),
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

class _KeypadButton extends StatefulWidget {
  final String? keyLabel;
  final IconData? icon;
  final double height;
  final VoidCallback? onTap;

  const _KeypadButton({
    this.keyLabel,
    this.icon,
    required this.height,
    this.onTap,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if ((widget.keyLabel == null || widget.keyLabel!.isEmpty) &&
        widget.icon == null) {
      return Expanded(child: SizedBox(height: widget.height));
    }

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          if (mounted) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (mounted) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (mounted) setState(() => _isPressed = false);
        },
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 70),
          child: Container(
            height: widget.height,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: _isPressed
                  ? (isLight
                      ? colorScheme.surfaceContainer
                      : colorScheme.surfaceContainerHigh)
                  : (isLight
                      ? colorScheme.surfaceContainerLowest
                      : colorScheme.surfaceContainerLow),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isLight
                    ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                    : context.customColors.glassStroke,
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: colorScheme.onSurface,
                    size: 22.sp,
                  )
                : Text(
                    widget.keyLabel!,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeights.semiBold,
                      color: colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
