import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/custom_keypad.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/status_components.dart';

/// Modal bottom sheet for changing or setting the 4-digit Security PIN.
class ChangePinModal extends StatefulWidget {
  const ChangePinModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChangePinModal(),
    );
  }

  @override
  State<ChangePinModal> createState() => _ChangePinModalState();
}

class _ChangePinModalState extends State<ChangePinModal>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<int> _stepNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> _pinInputNotifier = ValueNotifier<String>('');

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  String? _newPinDraft;
  late bool _hasExistingPin;

  @override
  void initState() {
    super.initState();
    final prefs = getIt<PreferenceService>();
    _hasExistingPin = prefs.isSecurityPinSet;

    // If no existing PIN, start directly at Step 1 (Enter New PIN)
    if (!_hasExistingPin) {
      _stepNotifier.value = 1;
    }

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _stepNotifier.dispose();
    _pinInputNotifier.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String val) {
    if (_pinInputNotifier.value.length < 4) {
      _pinInputNotifier.value += val;
      if (_pinInputNotifier.value.length == 4) {
        _processStepInput();
      }
    }
  }

  void _onDeletePress() {
    if (_pinInputNotifier.value.isNotEmpty) {
      _pinInputNotifier.value = _pinInputNotifier.value
          .substring(0, _pinInputNotifier.value.length - 1);
    }
  }

  Future<void> _processStepInput() async {
    final input = _pinInputNotifier.value;
    final step = _stepNotifier.value;
    final prefs = getIt<PreferenceService>();
    final l10n = context.l10n;

    if (step == 0) {
      // Step 0: Verify Current PIN
      final currentPin = prefs.securityPin;
      if (input == currentPin) {
        HapticFeedback.heavyImpact();
        _pinInputNotifier.value = '';
        _stepNotifier.value = 1;
      } else {
        _handleError(l10n.incorrectCurrentPin);
      }
    } else if (step == 1) {
      // Step 1: Save New PIN Draft
      HapticFeedback.mediumImpact();
      _newPinDraft = input;
      _pinInputNotifier.value = '';
      _stepNotifier.value = 2;
    } else if (step == 2) {
      // Step 2: Confirm New PIN
      if (input == _newPinDraft) {
        HapticFeedback.heavyImpact();
        await prefs.setSecurityPin(_newPinDraft);
        if (mounted) {
          StatusComponents.showToast(
            context,
            message: l10n.pinChangedSuccess,
            isSuccess: true,
          );
          Navigator.pop(context);
        }
      } else {
        _handleError(l10n.pinsDoNotMatch);
        _newPinDraft = null;
        _stepNotifier.value = 1;
      }
    }
  }

  Future<void> _handleError(String message) async {
    HapticFeedback.vibrate();
    _shakeController.forward(from: 0.0);
    StatusComponents.showToast(context, message: message, isError: true);
    await Future.delayed(const Duration(milliseconds: 300));
    _pinInputNotifier.value = '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: GlassContainer(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        backgroundColor: AppColors.surfaceLow,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            verticalMarginMedium,

            // Header Title
            Text(
              _hasExistingPin
                  ? l10n.changeSecurityPinTitle
                  : l10n.setupSecurityPin,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeights.bold,
              ),
            ),
            verticalMarginXSmall,

            // Step Prompt
            ValueListenableBuilder<int>(
              valueListenable: _stepNotifier,
              builder: (context, step, _) {
                String promptText = l10n.enterCurrentPin;
                if (step == 1) {
                  promptText = l10n.enterNewPin;
                } else if (step == 2) {
                  promptText = l10n.confirmNewPin;
                }

                return Text(
                  promptText,
                  style: customTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            verticalMarginLarge,

            // 4 Pin Dots Indicator
            ValueListenableBuilder<String>(
              valueListenable: _pinInputNotifier,
              builder: (context, enteredPin, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < enteredPin.length;
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isFilled
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            verticalMarginLarge,

            // Keypad
            CustomKeypad(
              onKeyPress: _onKeyPress,
              onDeletePress: _onDeletePress,
              showDecimal: false,
            ),
          ],
        ),
      ),
    );
  }
}
