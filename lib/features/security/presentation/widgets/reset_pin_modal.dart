import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_keypad.dart';
import '../../../../core/widgets/status_components.dart';

enum ResetPinStep { chooseMethod, verifyAnswer, enterNewPin, confirmNewPin }

/// Modal bottom sheet allowing users to recover and reset their PIN if forgotten.
class ResetPinModal extends StatefulWidget {
  const ResetPinModal({super.key});

  static Future<void> show(BuildContext context) {
    return AdaptiveSheet.show<void>(
      context: context,
      isScrollControlled: true,
      maxDialogWidth: 460.0,
      builder: (_) => const ResetPinModal(),
    );
  }

  @override
  State<ResetPinModal> createState() => _ResetPinModalState();
}

class _ResetPinModalState extends State<ResetPinModal> {
  final ValueNotifier<ResetPinStep> _currentStepNotifier =
      ValueNotifier<ResetPinStep>(ResetPinStep.chooseMethod);
  final TextEditingController _answerController = TextEditingController();

  final ValueNotifier<String> _newPinNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _confirmPinNotifier = ValueNotifier<String>('');

  // Random question selection state
  final ValueNotifier<String?> _randomQuestionNotifier =
      ValueNotifier<String?>(null);
  int _randomQuestionIndex = 1;

  final ValueNotifier<bool> _isVerifyingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier =
      ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _loadRandomSecurityQuestion();
  }

  void _loadRandomSecurityQuestion() async {
    final prefs = getIt<PreferenceService>();
    final q1 = await prefs.getSecurityQuestion1();
    final q2 = await prefs.getSecurityQuestion2();

    final available = <MapEntry<String, int>>[];
    if (q1 != null && q1.isNotEmpty) available.add(MapEntry(q1, 1));
    if (q2 != null && q2.isNotEmpty && q2 != q1) available.add(MapEntry(q2, 2));

    if (!mounted) return;

    if (available.isEmpty) {
      _randomQuestionNotifier.value = context.l10n.defaultSecurityQuestion;
      _randomQuestionIndex = 1;
    } else {
      final randomIndex = Random().nextInt(available.length);
      final chosen = available[randomIndex];
      _randomQuestionNotifier.value = chosen.key;
      _randomQuestionIndex = chosen.value;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _currentStepNotifier.dispose();
    _newPinNotifier.dispose();
    _confirmPinNotifier.dispose();
    _randomQuestionNotifier.dispose();
    _isVerifyingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  void _resetViaBiometrics() async {
    HapticFeedback.lightImpact();
    _errorMessageNotifier.value = null;
    if (!mounted) return;
    final reason = context.l10n.biometricReason;
    final notAvailableMsg = context.l10n.biometricNotAvailable;
    final failedMsg = context.l10n.biometricAuthFailed;

    final bioService = getIt<BiometricAuthService>();
    final isAvailable = await bioService.isBiometricAvailable();

    if (!isAvailable) {
      if (mounted) {
        _errorMessageNotifier.value = notAvailableMsg;
      }
      return;
    }

    final authenticated = await bioService.authenticate(
      localizedReason: reason,
    );

    if (authenticated) {
      HapticFeedback.heavyImpact();
      _errorMessageNotifier.value = null;
      _currentStepNotifier.value = ResetPinStep.enterNewPin;
    } else if (mounted) {
      _errorMessageNotifier.value = failedMsg;
    }
  }

  void _verifySecretAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    _errorMessageNotifier.value = null;
    _isVerifyingNotifier.value = true;
    final prefs = getIt<PreferenceService>();

    bool isMatch = false;

    if (_randomQuestionIndex == 1) {
      isMatch = await prefs.verifySecurityAnswer1(answer);
    } else {
      isMatch = await prefs.verifySecurityAnswer2(answer);
    }

    // Fallback check if single answer or unset
    if (!isMatch) {
      isMatch = await prefs.verifySecurityAnswer(answer);
    }

    final hasAnyAnswer = await prefs.hasSecurityAnswer();
    if (!hasAnyAnswer && answer.isNotEmpty) {
      isMatch = true; // Fallback if no answer was ever configured
    }

    _isVerifyingNotifier.value = false;

    if (isMatch) {
      HapticFeedback.lightImpact();
      _errorMessageNotifier.value = null;
      _currentStepNotifier.value = ResetPinStep.enterNewPin;
    } else {
      HapticFeedback.vibrate();
      if (mounted) {
        _errorMessageNotifier.value = context.l10n.invalidAnswerError;
      }
    }
  }

  void _onKeyPress(String value) {
    _errorMessageNotifier.value = null;
    if (_currentStepNotifier.value == ResetPinStep.enterNewPin) {
      if (_newPinNotifier.value.length < 4) {
        _newPinNotifier.value += value;
        if (_newPinNotifier.value.length == 4) {
          HapticFeedback.lightImpact();
          _currentStepNotifier.value = ResetPinStep.confirmNewPin;
        }
      }
    } else if (_currentStepNotifier.value == ResetPinStep.confirmNewPin) {
      if (_confirmPinNotifier.value.length < 4) {
        _confirmPinNotifier.value += value;
        if (_confirmPinNotifier.value.length == 4) {
          _saveNewPin();
        }
      }
    }
  }

  void _onDeletePress() {
    _errorMessageNotifier.value = null;
    if (_currentStepNotifier.value == ResetPinStep.enterNewPin) {
      if (_newPinNotifier.value.isNotEmpty) {
        _newPinNotifier.value = _newPinNotifier.value
            .substring(0, _newPinNotifier.value.length - 1);
      }
    } else if (_currentStepNotifier.value == ResetPinStep.confirmNewPin) {
      if (_confirmPinNotifier.value.isNotEmpty) {
        _confirmPinNotifier.value = _confirmPinNotifier.value
            .substring(0, _confirmPinNotifier.value.length - 1);
      } else {
        _currentStepNotifier.value = ResetPinStep.enterNewPin;
      }
    }
  }

  void _saveNewPin() async {
    final newPin = _newPinNotifier.value;
    final confirmPin = _confirmPinNotifier.value;

    if (newPin == confirmPin) {
      HapticFeedback.heavyImpact();
      final prefs = getIt<PreferenceService>();
      await prefs.setSecurityPin(confirmPin);

      if (mounted) {
        Navigator.pop(context);
        StatusComponents.showToast(
          context,
          message: context.l10n.pinResetSuccess,
          isError: false,
        );
        context.router.replaceAll([const DashboardRoute()]);
      }
    } else {
      HapticFeedback.vibrate();
      if (mounted) {
        _errorMessageNotifier.value = context.l10n.pinMismatchError;
      }
      _newPinNotifier.value = '';
      _confirmPinNotifier.value = '';
      _currentStepNotifier.value = ResetPinStep.enterNewPin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet = Breakpoints.isTablet(context);
    final maxHeight =
        isTablet ? 600.0 : MediaQuery.of(context).size.height * 0.88;

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

                // Header Row: Back (if not first step), Title, Close
                ValueListenableBuilder<ResetPinStep>(
                  valueListenable: _currentStepNotifier,
                  builder: (context, step, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (step != ResetPinStep.chooseMethod)
                          IconButton(
                            icon: Icon(Icons.arrow_back_rounded,
                                color: colorScheme.onSurface),
                            onPressed: () {
                              _errorMessageNotifier.value = null;
                              if (step == ResetPinStep.confirmNewPin) {
                                _currentStepNotifier.value =
                                    ResetPinStep.enterNewPin;
                              } else {
                                _currentStepNotifier.value =
                                    ResetPinStep.chooseMethod;
                              }
                            },
                            visualDensity: VisualDensity.compact,
                          )
                        else
                          const SizedBox(width: 40),
                        Text(
                          l10n.resetPinTitle,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
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
                        // Header Subtitle Description
                        ValueListenableBuilder<ResetPinStep>(
                          valueListenable: _currentStepNotifier,
                          builder: (context, step, _) {
                            if (step == ResetPinStep.chooseMethod) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: Text(
                                  l10n.resetPinDesc,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Modal Scoped Error Banner
                        ValueListenableBuilder<String?>(
                          valueListenable: _errorMessageNotifier,
                          builder: (context, errorMsg, _) {
                            if (errorMsg == null) {
                              return const SizedBox.shrink();
                            }
                            final redColor = isLight
                                ? const Color(0xFFDC2626)
                                : customColors.semanticRed;
                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 14.h),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: redColor.withValues(
                                    alpha: isLight ? 0.12 : 0.18),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: redColor.withValues(
                                      alpha: isLight ? 0.35 : 0.40),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline_rounded,
                                      color: redColor, size: 20.sp),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      errorMsg,
                                      style: (textTheme.bodySmall ??
                                              const TextStyle())
                                          .copyWith(
                                        color: redColor,
                                        fontWeight: FontWeights.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        ValueListenableBuilder<ResetPinStep>(
                          valueListenable: _currentStepNotifier,
                          builder: (context, currentStep, _) {
                            if (currentStep == ResetPinStep.chooseMethod) {
                              return Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? colorScheme.surfaceContainerLowest
                                              .withValues(alpha: 0.7)
                                          : colorScheme.surfaceContainerLow
                                              .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: isLight
                                            ? colorScheme.outlineVariant
                                                .withValues(alpha: 0.3)
                                            : customColors.glassStroke
                                                .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        onTap: _resetViaBiometrics,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 14.h),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(10.w),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withValues(
                                                          alpha: isLight
                                                              ? 0.14
                                                              : 0.18),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: colorScheme.primary
                                                        .withValues(
                                                            alpha: isLight
                                                                ? 0.35
                                                                : 0.30),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.fingerprint_rounded,
                                                  color: colorScheme.primary,
                                                  size: 22.sp,
                                                ),
                                              ),
                                              SizedBox(width: 14.w),
                                              Expanded(
                                                child: Text(
                                                  l10n.resetViaBiometrics,
                                                  style: (textTheme.bodyLarge ??
                                                          const TextStyle())
                                                      .copyWith(
                                                    fontWeight:
                                                        FontWeights.bold,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? colorScheme.surfaceContainerLowest
                                              .withValues(alpha: 0.7)
                                          : colorScheme.surfaceContainerLow
                                              .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: isLight
                                            ? colorScheme.outlineVariant
                                                .withValues(alpha: 0.3)
                                            : customColors.glassStroke
                                                .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        onTap: () {
                                          _errorMessageNotifier.value = null;
                                          _currentStepNotifier.value =
                                              ResetPinStep.verifyAnswer;
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 14.h),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(10.w),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withValues(
                                                          alpha: isLight
                                                              ? 0.14
                                                              : 0.18),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: colorScheme.primary
                                                        .withValues(
                                                            alpha: isLight
                                                                ? 0.35
                                                                : 0.30),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.quiz_rounded,
                                                  color: colorScheme.primary,
                                                  size: 22.sp,
                                                ),
                                              ),
                                              SizedBox(width: 14.w),
                                              Expanded(
                                                child: Text(
                                                  l10n.resetViaSecurityAnswer,
                                                  style: (textTheme.bodyLarge ??
                                                          const TextStyle())
                                                      .copyWith(
                                                    fontWeight:
                                                        FontWeights.bold,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            if (currentStep == ResetPinStep.verifyAnswer) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.securityQuestionLabel.toUpperCase(),
                                    style: customTypography.labelMediumMono
                                        .copyWith(
                                      color: colorScheme.outline,
                                      letterSpacing: 1.2,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  ValueListenableBuilder<String?>(
                                    valueListenable: _randomQuestionNotifier,
                                    builder: (context, questionText, _) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 14.h),
                                        decoration: BoxDecoration(
                                          color: isLight
                                              ? colorScheme
                                                  .surfaceContainerLowest
                                                  .withValues(alpha: 0.7)
                                              : colorScheme.surfaceContainerLow
                                                  .withValues(alpha: 0.4),
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          border: Border.all(
                                            color: isLight
                                                ? colorScheme.outlineVariant
                                                    .withValues(alpha: 0.3)
                                                : customColors.glassStroke
                                                    .withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8.w),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary
                                                    .withValues(
                                                        alpha: isLight
                                                            ? 0.14
                                                            : 0.18),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: colorScheme.primary
                                                      .withValues(
                                                          alpha: isLight
                                                              ? 0.35
                                                              : 0.30),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.help_outline_rounded,
                                                color: colorScheme.primary,
                                                size: 18.sp,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Text(
                                                questionText ??
                                                    l10n.defaultSecurityQuestion,
                                                style: (textTheme.bodyMedium ??
                                                        const TextStyle())
                                                    .copyWith(
                                                  fontWeight:
                                                      FontWeights.semiBold,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'YOUR ANSWER',
                                    style: customTypography.labelMediumMono
                                        .copyWith(
                                      color: colorScheme.outline,
                                      letterSpacing: 1.2,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  AppTextField(
                                    controller: _answerController,
                                    hintText: l10n.yourAnswerHint,
                                    prefixIcon: Icon(Icons.lock_reset_rounded,
                                        color: colorScheme.primary),
                                    onChanged: (_) {
                                      if (_errorMessageNotifier.value != null) {
                                        _errorMessageNotifier.value = null;
                                      }
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _isVerifyingNotifier,
                                    builder: (context, isVerifying, _) {
                                      return AppButton(
                                        text: l10n.verifyAnswer,
                                        isLoading: isVerifying,
                                        onPressed: isVerifying
                                            ? null
                                            : _verifySecretAnswer,
                                        variant: AppButtonVariant.primary,
                                      );
                                    },
                                  ),
                                ],
                              );
                            }

                            // Enter New PIN & Confirm New PIN
                            final pinNotifier =
                                currentStep == ResetPinStep.enterNewPin
                                    ? _newPinNotifier
                                    : _confirmPinNotifier;
                            return Column(
                              children: [
                                Container(
                                  width: 52.w,
                                  height: 52.w,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                        alpha: isLight ? 0.12 : 0.18),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                          alpha: isLight ? 0.35 : 0.30),
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
                                    currentStep == ResetPinStep.enterNewPin
                                        ? Icons.lock_outline_rounded
                                        : Icons.lock_rounded,
                                    color: colorScheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  currentStep == ResetPinStep.enterNewPin
                                      ? l10n.newPinHeader
                                      : l10n.confirmPinHeader,
                                  style: (textTheme.titleMedium ??
                                          const TextStyle())
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ValueListenableBuilder<String>(
                                  valueListenable: pinNotifier,
                                  builder: (context, pin, _) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(4, (index) {
                                        final isFilled = index < pin.length;
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
                                            color: isFilled
                                                ? colorScheme.primary
                                                : (isLight
                                                    ? colorScheme
                                                        .surfaceContainerLowest
                                                    : colorScheme
                                                        .surfaceContainerHigh
                                                        .withValues(
                                                            alpha: 0.4)),
                                            border: Border.all(
                                              color: isFilled
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
                                            boxShadow: isFilled
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
                                                : null,
                                          ),
                                          child: isFilled
                                              ? Center(
                                                  child: Container(
                                                    width: 6.w,
                                                    height: 6.w,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        );
                                      }),
                                    );
                                  },
                                ),
                                SizedBox(height: 16.h),
                                CustomKeypad(
                                  showDecimal: false,
                                  onKeyPress: _onKeyPress,
                                  onDeletePress: _onDeletePress,
                                ),
                              ],
                            );
                          },
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
