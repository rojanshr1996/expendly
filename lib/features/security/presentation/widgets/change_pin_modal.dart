import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_components.dart';
import 'reset_pin_modal.dart';

/// Highly refined, spacious liquid-glass modal bottom sheet for changing or setting the 4-digit Security PIN.
class ChangePinModal extends StatefulWidget {
  const ChangePinModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
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
      HapticFeedback.selectionClick();
      _pinInputNotifier.value += val;
      if (_pinInputNotifier.value.length == 4) {
        _processStepInput();
      }
    }
  }

  void _onDeletePress() {
    if (_pinInputNotifier.value.isNotEmpty) {
      HapticFeedback.selectionClick();
      _pinInputNotifier.value = _pinInputNotifier.value
          .substring(0, _pinInputNotifier.value.length - 1);
    }
  }

  void _onClearPress() {
    if (_pinInputNotifier.value.isNotEmpty) {
      HapticFeedback.lightImpact();
      _pinInputNotifier.value = '';
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
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final l10n = context.l10n;

    final totalSteps = _hasExistingPin ? 3 : 2;

    // High contrast primary text colors
    final primaryTextColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final secondaryTextColor =
        isLight ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return DraggableScrollableSheet(
      initialChildSize: 0.84,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLight
                      ? [
                          colorScheme.surfaceContainerLowest
                              .withValues(alpha: 0.96),
                          colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.90),
                        ]
                      : [
                          colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.88),
                          colorScheme.surfaceContainerLowest
                              .withValues(alpha: 0.72),
                        ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                border: Border.all(
                  color: isLight
                      ? Colors.white.withValues(alpha: 0.90)
                      : customColors.glassStroke.withValues(alpha: 0.65),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: isLight ? 0.7 : 0.08),
                    blurRadius: 10.r,
                    spreadRadius: -2.r,
                    offset: const Offset(0, -2),
                  ),
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isLight ? 0.10 : 0.40),
                    blurRadius: 32.r,
                    spreadRadius: 0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.5.h,
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFF94A3B8)
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Top Bar: Step Progress Badge & Close Button
                    ValueListenableBuilder<int>(
                      valueListenable: _stepNotifier,
                      builder: (context, step, _) {
                        final displayStepNumber =
                            _hasExistingPin ? step + 1 : step;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Glass Step Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: isLight ? 0.12 : 0.20),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: isLight ? 0.35 : 0.45),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7.w,
                                    height: 7.w,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.7),
                                          blurRadius: 4.r,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 7.w),
                                  Text(
                                    'STEP $displayStepNumber OF $totalSteps',
                                    style: customTypography.labelMediumMono
                                        .copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Glass Close Button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 34.w,
                                height: 34.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isLight
                                      ? Colors.white.withValues(alpha: 0.85)
                                      : colorScheme.surfaceContainerHigh
                                          .withValues(alpha: 0.5),
                                  border: Border.all(
                                    color: isLight
                                        ? const Color(0xFFCBD5E1)
                                        : customColors.glassStroke
                                            .withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18.sp,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Liquid Glass Animated Shield / Lock Badge
                    ValueListenableBuilder<int>(
                      valueListenable: _stepNotifier,
                      builder: (context, step, _) {
                        IconData iconData = Icons.lock_outline_rounded;
                        if (step == 1) iconData = Icons.pin_outlined;
                        if (step == 2) iconData = Icons.verified_user_outlined;

                        return Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment.topLeft,
                              radius: 1.1,
                              colors: isLight
                                  ? [
                                      colorScheme.primary
                                          .withValues(alpha: 0.18),
                                      colorScheme.primary
                                          .withValues(alpha: 0.06),
                                    ]
                                  : [
                                      colorScheme.primary
                                          .withValues(alpha: 0.32),
                                      colorScheme.primary
                                          .withValues(alpha: 0.12),
                                    ],
                            ),
                            border: Border.all(
                              color: colorScheme.primary
                                  .withValues(alpha: isLight ? 0.40 : 0.50),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary
                                    .withValues(alpha: isLight ? 0.20 : 0.35),
                                blurRadius: 16.r,
                                spreadRadius: -2.r,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) => ScaleTransition(
                              scale: anim,
                              child: child,
                            ),
                            child: Icon(
                              iconData,
                              key: ValueKey(iconData),
                              color: colorScheme.primary,
                              size: 26.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Animated Step Title & Subtitle (High Contrast)
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

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.15),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            key: ValueKey(step),
                            children: [
                              Text(
                                title,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                subtitle,
                                style: customTypography.bodyMedium.copyWith(
                                  color: secondaryTextColor,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Step Progress Indicators (segmented glass bars)
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
                              width: isCurrent ? 28.w : 12.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.r),
                                color: isCompleted || isCurrent
                                    ? colorScheme.primary
                                    : isLight
                                        ? const Color(0xFFCBD5E1)
                                        : colorScheme.outlineVariant
                                            .withValues(alpha: 0.4),
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withValues(alpha: 0.6),
                                          blurRadius: 6.r,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),

                    // 4 Liquid Glass PIN Indicator Cells (Spacious & High Contrast)
                    ValueListenableBuilder<bool>(
                      valueListenable: _isErrorNotifier,
                      builder: (context, isError, _) {
                        return ValueListenableBuilder<String>(
                          valueListenable: _pinInputNotifier,
                          builder: (context, enteredPin, _) {
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
                                  final isFilled = index < enteredPin.length;
                                  final isCurrentInput =
                                      index == enteredPin.length;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutCubic,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    width: 56.w,
                                    height: 62.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isError
                                            ? [
                                                AppColors.semanticRed
                                                    .withValues(alpha: 0.22),
                                                AppColors.semanticRed
                                                    .withValues(alpha: 0.10),
                                              ]
                                            : isFilled
                                                ? [
                                                    colorScheme.primary
                                                        .withValues(
                                                            alpha: isLight
                                                                ? 0.18
                                                                : 0.28),
                                                    colorScheme.primary
                                                        .withValues(
                                                            alpha: isLight
                                                                ? 0.08
                                                                : 0.16),
                                                  ]
                                                : [
                                                    isLight
                                                        ? Colors.white
                                                        : colorScheme
                                                            .surfaceContainerHigh
                                                            .withValues(
                                                                alpha: 0.45),
                                                    isLight
                                                        ? const Color(
                                                            0xFFF8FAFC)
                                                        : colorScheme
                                                            .surfaceContainerLow
                                                            .withValues(
                                                                alpha: 0.30),
                                                  ],
                                      ),
                                      border: Border.all(
                                        color: isError
                                            ? AppColors.semanticRed
                                            : isFilled
                                                ? colorScheme.primary
                                                : isCurrentInput
                                                    ? colorScheme.primary
                                                        .withValues(alpha: 0.65)
                                                    : isLight
                                                        ? const Color(
                                                            0xFFCBD5E1)
                                                        : customColors
                                                            .glassStroke
                                                            .withValues(
                                                                alpha: 0.60),
                                        width: isFilled || isCurrentInput
                                            ? 1.8
                                            : 1.2,
                                      ),
                                      boxShadow: [
                                        if (isFilled && !isError)
                                          BoxShadow(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.30),
                                            blurRadius: 10.r,
                                            spreadRadius: 0,
                                          ),
                                        if (isError)
                                          BoxShadow(
                                            color: AppColors.semanticRed
                                                .withValues(alpha: 0.40),
                                            blurRadius: 10.r,
                                            spreadRadius: 0,
                                          ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                              alpha: isLight ? 0.05 : 0.16),
                                          blurRadius: 8.r,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: AnimatedScale(
                                      scale: isFilled ? 1.0 : 0.0,
                                      duration:
                                          const Duration(milliseconds: 180),
                                      curve: Curves.easeOutBack,
                                      child: Container(
                                        width: 15.w,
                                        height: 15.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isError
                                              ? AppColors.semanticRed
                                              : colorScheme.primary,
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isError
                                                      ? AppColors.semanticRed
                                                      : colorScheme.primary)
                                                  .withValues(alpha: 0.7),
                                              blurRadius: 6.r,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 22.h),

                    // Tactile Liquid Glass Numeric Keypad (Taller, Prominent & Crystal-Clear)
                    ValueListenableBuilder<int>(
                      valueListenable: _stepNotifier,
                      builder: (context, step, _) {
                        return _LiquidGlassNumericKeypad(
                          onKeyPress: _onKeyPress,
                          onDeletePress: _onDeletePress,
                          onClearPress: _onClearPress,
                          onForgotPress: step == 0 && _hasExistingPin
                              ? _onForgotPin
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tactile, responsive liquid-glass numeric keypad with prominent high-contrast buttons.
class _LiquidGlassNumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onDeletePress;
  final VoidCallback onClearPress;
  final VoidCallback? onForgotPress;

  const _LiquidGlassNumericKeypad({
    required this.onKeyPress,
    required this.onDeletePress,
    required this.onClearPress,
    this.onForgotPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _GlassKeypadKey(label: '1', onTap: () => onKeyPress('1')),
            _GlassKeypadKey(label: '2', onTap: () => onKeyPress('2')),
            _GlassKeypadKey(label: '3', onTap: () => onKeyPress('3')),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _GlassKeypadKey(label: '4', onTap: () => onKeyPress('4')),
            _GlassKeypadKey(label: '5', onTap: () => onKeyPress('5')),
            _GlassKeypadKey(label: '6', onTap: () => onKeyPress('6')),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _GlassKeypadKey(label: '7', onTap: () => onKeyPress('7')),
            _GlassKeypadKey(label: '8', onTap: () => onKeyPress('8')),
            _GlassKeypadKey(label: '9', onTap: () => onKeyPress('9')),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // Left Action: Forgot? or Clear
            if (onForgotPress != null)
              _GlassKeypadKey(
                label: 'Forgot?',
                isSubtleAction: true,
                onTap: onForgotPress,
              )
            else
              _GlassKeypadKey(
                label: 'Clear',
                isSubtleAction: true,
                onTap: onClearPress,
              ),

            // Number 0
            _GlassKeypadKey(label: '0', onTap: () => onKeyPress('0')),

            // Right Action: Backspace
            _GlassKeypadKey(
              icon: Icons.backspace_outlined,
              isSubtleAction: true,
              onTap: onDeletePress,
            ),
          ],
        ),
      ],
    );
  }
}

/// Single interactive tactile liquid-glass keypad key with bold typography and high contrast.
class _GlassKeypadKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isSubtleAction;
  final VoidCallback? onTap;

  const _GlassKeypadKey({
    this.label,
    this.icon,
    this.isSubtleAction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isPressedNotifier = ValueNotifier<bool>(false);

    // Crystal clear high-contrast font colors
    final numberTextColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final actionTextColor =
        isLight ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => isPressedNotifier.value = true,
        onTapUp: (_) => isPressedNotifier.value = false,
        onTapCancel: () => isPressedNotifier.value = false,
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isPressedNotifier,
          builder: (context, isPressed, _) {
            return AnimatedScale(
              scale: isPressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOutCubic,
              child: Container(
                height: 56.h,
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPressed
                        ? [
                            colorScheme.primary
                                .withValues(alpha: isLight ? 0.25 : 0.35),
                            colorScheme.primary
                                .withValues(alpha: isLight ? 0.12 : 0.20),
                          ]
                        : isSubtleAction
                            ? [
                                isLight
                                    ? const Color(0xFFF1F5F9)
                                    : colorScheme.surfaceContainerHigh
                                        .withValues(alpha: 0.35),
                                isLight
                                    ? const Color(0xFFE2E8F0)
                                    : colorScheme.surfaceContainerLow
                                        .withValues(alpha: 0.20),
                              ]
                            : [
                                isLight
                                    ? Colors.white
                                    : colorScheme.surfaceContainerHigh
                                        .withValues(alpha: 0.50),
                                isLight
                                    ? const Color(0xFFF8FAFC)
                                    : colorScheme.surfaceContainerLow
                                        .withValues(alpha: 0.30),
                              ],
                  ),
                  border: Border.all(
                    color: isPressed
                        ? colorScheme.primary
                        : isLight
                            ? (isSubtleAction
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFFE2E8F0))
                            : (isSubtleAction
                                ? customColors.glassStroke
                                    .withValues(alpha: 0.35)
                                : customColors.glassStroke
                                    .withValues(alpha: 0.55)),
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (!isSubtleAction) ...[
                      BoxShadow(
                        color: Colors.white
                            .withValues(alpha: isLight ? 0.8 : 0.06),
                        blurRadius: 4.r,
                        spreadRadius: -1.r,
                        offset: const Offset(0, -1),
                      ),
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isLight ? 0.05 : 0.18),
                        blurRadius: 8.r,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ],
                ),
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(
                        icon,
                        color: actionTextColor,
                        size: 22.sp,
                      )
                    : Text(
                        label ?? '',
                        style: isSubtleAction
                            ? customTypography.labelMediumMono.copyWith(
                                color: actionTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5.sp,
                              )
                            : customTypography.headlineMediumMonoBold.copyWith(
                                color: numberTextColor,
                                fontSize: 23.sp,
                                fontWeight: FontWeight.w700,
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
