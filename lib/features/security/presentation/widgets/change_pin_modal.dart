import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/custom_keypad.dart';
import '../../../../core/widgets/status_components.dart';
import 'reset_pin_modal.dart';

/// Refined modal bottom sheet for changing or setting the 4-digit Security PIN.
class ChangePinModal extends StatefulWidget {
  const ChangePinModal({super.key});

  static Future<void> show(BuildContext context) {
    return AdaptiveSheet.show<void>(
      context: context,
      isScrollControlled: true,
      maxDialogWidth: 460.0,
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
  final ValueNotifier<bool> _isErrorNotifier = ValueNotifier<bool>(false);

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  String? _newPinDraft;
  late bool _hasExistingPin;

  @override
  void initState() {
    super.initState();
    final prefs = getIt<PreferenceService>();
    _hasExistingPin = prefs.isSecurityPinSet;

    // If no existing PIN, start directly at Step 1 (Create New PIN)
    if (!_hasExistingPin) {
      _stepNotifier.value = 1;
    }

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 14.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _stepNotifier.dispose();
    _pinInputNotifier.dispose();
    _isErrorNotifier.dispose();
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
        _isErrorNotifier.value = false;
        _pinInputNotifier.value = '';
        _stepNotifier.value = 1;
      } else {
        _handleError(l10n.incorrectCurrentPin);
      }
    } else if (step == 1) {
      // Step 1: Save New PIN Draft
      HapticFeedback.mediumImpact();
      _isErrorNotifier.value = false;
      _newPinDraft = input;
      _pinInputNotifier.value = '';
      _stepNotifier.value = 2;
    } else if (step == 2) {
      // Step 2: Confirm New PIN
      if (input == _newPinDraft) {
        HapticFeedback.heavyImpact();
        _isErrorNotifier.value = false;
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
    _isErrorNotifier.value = true;
    HapticFeedback.vibrate();
    _shakeController.forward(from: 0.0);
    StatusComponents.showToast(context, message: message, isError: true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      _pinInputNotifier.value = '';
      _isErrorNotifier.value = false;
    }
  }

  void _onForgotPin() {
    Navigator.pop(context);
    ResetPinModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet = Breakpoints.isTablet(context);
    final l10n = context.l10n;
    final maxHeight =
        isTablet ? 580.0 : MediaQuery.of(context).size.height * 0.88;

    final totalSteps = _hasExistingPin ? 3 : 2;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color:
              isLight ? colorScheme.surface : colorScheme.surfaceContainerHigh,
          borderRadius: isTablet
              ? BorderRadius.circular(24.0)
              : BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(
            color: isLight
                ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                : customColors.glassStroke.withValues(alpha: 0.45),
            width: 1.0,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 20.w,
              vertical: isTablet ? 20.0 : 16.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle (phone only)
                if (!isTablet) ...[
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isLight
                            ? colorScheme.outline.withValues(alpha: 0.4)
                            : colorScheme.outlineVariant.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // Header Row: Back button (if can go back), Title, Close Button
                ValueListenableBuilder<int>(
                  valueListenable: _stepNotifier,
                  builder: (context, step, _) {
                    final canGoBack = _hasExistingPin ? step > 0 : step > 1;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (canGoBack)
                          IconButton(
                            icon: Icon(Icons.arrow_back_rounded,
                                color: colorScheme.onSurface),
                            onPressed: () {
                              _isErrorNotifier.value = false;
                              _pinInputNotifier.value = '';
                              if (step == 2) {
                                _newPinDraft = null;
                                _stepNotifier.value = 1;
                              } else if (step == 1 && _hasExistingPin) {
                                _stepNotifier.value = 0;
                              }
                            },
                            visualDensity: VisualDensity.compact,
                          )
                        else
                          const SizedBox(width: 40),
                        Expanded(
                          child: Text(
                            l10n.changeSecurityPin,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.pop(context),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10.h),

                // Flexible Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circular Lock Icon Badge
                        ValueListenableBuilder<int>(
                          valueListenable: _stepNotifier,
                          builder: (context, step, _) {
                            IconData iconData = Icons.lock_outline_rounded;
                            if (step == 1) {
                              iconData = Icons.lock_reset_rounded;
                            } else if (step == 2) {
                              iconData = Icons.lock_rounded;
                            }

                            return Container(
                              width: 52.w,
                              height: 52.w,
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: isLight ? 0.12 : 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: isLight ? 0.35 : 0.30),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                        alpha: isLight ? 0.15 : 0.25),
                                    blurRadius: 12.r,
                                    spreadRadius: -2.r,
                                  ),
                                ],
                              ),
                              child: Icon(
                                iconData,
                                color: colorScheme.primary,
                                size: 24.sp,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12.h),

                        // Step Badge (e.g. "STEP 1 OF 3")
                        ValueListenableBuilder<int>(
                          valueListenable: _stepNotifier,
                          builder: (context, step, _) {
                            final currentStepDisplay =
                                _hasExistingPin ? (step + 1) : step;
                            final stepLabel =
                                'STEP $currentStepDisplay OF $totalSteps';

                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: isLight ? 0.12 : 0.20),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: isLight ? 0.30 : 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                stepLabel,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontSize: 10.sp,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8.h),

                        // Step Title & Subtitle
                        ValueListenableBuilder<int>(
                          valueListenable: _stepNotifier,
                          builder: (context, step, _) {
                            String title = l10n.enterCurrentPin;
                            String subtitle =
                                'Verify your identity with your current PIN';

                            if (step == 1) {
                              title = _hasExistingPin
                                  ? l10n.enterNewPin
                                  : l10n.setupSecurityPin;
                              subtitle = 'Choose a memorable 4-digit code';
                            } else if (step == 2) {
                              title = l10n.confirmNewPin;
                              subtitle = 'Re-enter your 4-digit PIN to confirm';
                            }

                            return Column(
                              children: [
                                Text(
                                  title,
                                  style:
                                      context.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  subtitle,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 14.h),

                        // Step Progress Indicators (Segmented bars)
                        ValueListenableBuilder<int>(
                          valueListenable: _stepNotifier,
                          builder: (context, step, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(totalSteps, (index) {
                                final actualStepIndex =
                                    _hasExistingPin ? index : index + 1;
                                final isCompleted = step > actualStepIndex;
                                final isCurrent = step == actualStepIndex;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 280),
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  width: isCurrent ? 24.w : 8.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2.r),
                                    color: isCompleted || isCurrent
                                        ? colorScheme.primary
                                        : isLight
                                            ? colorScheme.outlineVariant
                                                .withValues(alpha: 0.5)
                                            : colorScheme.outlineVariant
                                                .withValues(alpha: 0.3),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),

                        // 4 PIN Dots / Points (matching ResetPinModal)
                        ValueListenableBuilder<bool>(
                          valueListenable: _isErrorNotifier,
                          builder: (context, isError, _) {
                            return ValueListenableBuilder<String>(
                              valueListenable: _pinInputNotifier,
                              builder: (context, enteredPin, _) {
                                final redColor = isLight
                                    ? const Color(0xFFDC2626)
                                    : customColors.semanticRed;

                                return AnimatedBuilder(
                                  animation: _shakeAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(_shakeAnimation.value, 0),
                                      child: child,
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(4, (index) {
                                      final isFilled =
                                          index < enteredPin.length;

                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        curve: Curves.easeOutCubic,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 8.w),
                                        width: 16.w,
                                        height: 16.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isError
                                              ? redColor.withValues(
                                                  alpha: isLight ? 0.15 : 0.25)
                                              : isFilled
                                                  ? colorScheme.primary
                                                  : (isLight
                                                      ? colorScheme
                                                          .surfaceContainerLowest
                                                      : colorScheme
                                                          .surfaceContainerHigh
                                                          .withValues(
                                                              alpha: 0.4)),
                                          border: Border.all(
                                            color: isError
                                                ? redColor
                                                : isFilled
                                                    ? colorScheme.primary
                                                    : (isLight
                                                        ? colorScheme
                                                            .outlineVariant
                                                            .withValues(
                                                                alpha: 0.70)
                                                        : colorScheme
                                                            .outlineVariant
                                                            .withValues(
                                                                alpha: 0.6)),
                                            width: 1.8,
                                          ),
                                          boxShadow: isFilled && !isError
                                              ? [
                                                  BoxShadow(
                                                    color: colorScheme.primary
                                                        .withValues(
                                                            alpha: isLight
                                                                ? 0.35
                                                                : 0.5),
                                                    blurRadius: 8.r,
                                                    spreadRadius: 0,
                                                  ),
                                                ]
                                              : isError
                                                  ? [
                                                      BoxShadow(
                                                        color:
                                                            redColor.withValues(
                                                                alpha: 0.4),
                                                        blurRadius: 8.r,
                                                        spreadRadius: 0,
                                                      ),
                                                    ]
                                                  : null,
                                        ),
                                        child: isFilled
                                            ? Center(
                                                child: Container(
                                                  width: 6.w,
                                                  height: 6.w,
                                                  decoration: BoxDecoration(
                                                    color: isError
                                                        ? redColor
                                                        : Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      );
                                    }),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 8.h),

                        // Forgot PIN Link (Step 0)
                        ValueListenableBuilder<int>(
                          valueListenable: _stepNotifier,
                          builder: (context, step, _) {
                            if (step == 0 && _hasExistingPin) {
                              return TextButton(
                                onPressed: _onForgotPin,
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: colorScheme.primary,
                                ),
                                child: Text(
                                  'Forgot?',
                                  style:
                                      context.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }
                            return SizedBox(height: 12.h);
                          },
                        ),

                        // CustomKeypad (matching ResetPinModal)
                        CustomKeypad(
                          showDecimal: false,
                          onKeyPress: _onKeyPress,
                          onDeletePress: _onDeletePress,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
