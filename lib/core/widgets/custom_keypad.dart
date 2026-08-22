import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          const SizedBox(height: 8.0),
          Row(
            children: [
              _KeypadButton(keyLabel: '4', onTap: () => onKeyPress('4')),
              _KeypadButton(keyLabel: '5', onTap: () => onKeyPress('5')),
              _KeypadButton(keyLabel: '6', onTap: () => onKeyPress('6')),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              _KeypadButton(keyLabel: '7', onTap: () => onKeyPress('7')),
              _KeypadButton(keyLabel: '8', onTap: () => onKeyPress('8')),
              _KeypadButton(keyLabel: '9', onTap: () => onKeyPress('9')),
            ],
          ),
          const SizedBox(height: 8.0),
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
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: onSubmitPress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
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
    final colorScheme = context.colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isPressedNotifier = ValueNotifier<bool>(false);

    if (keyLabel == '' && icon == null) {
      return const Expanded(child: SizedBox(height: 52.0));
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
                height: 52.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: isPressed
                      ? (isLight
                          ? colorScheme.surfaceContainer
                          : colorScheme.surfaceContainerHigh)
                      : (isLight
                          ? colorScheme.surfaceContainerLowest
                          : colorScheme.surfaceContainerLow),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isLight
                        ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                        : context.customColors.glassStroke,
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(
                        icon,
                        color: colorScheme.onSurface,
                        size: 22.0,
                      )
                    : Text(
                        keyLabel!,
                        style: TextStyle(
                          fontSize: 22.0,
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
