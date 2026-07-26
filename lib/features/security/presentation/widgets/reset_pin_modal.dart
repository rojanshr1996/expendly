import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_keypad.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/status_components.dart';

enum ResetPinStep { chooseMethod, verifyAnswer, enterNewPin, confirmNewPin }

/// Modal bottom sheet allowing users to recover and reset their PIN if forgotten.
class ResetPinModal extends StatefulWidget {
  const ResetPinModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
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

  void _resetViaBiometrics() {
    HapticFeedback.heavyImpact();
    _errorMessageNotifier.value = null;
    _currentStepNotifier.value = ResetPinStep.enterNewPin;
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
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: GlassContainer(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          backgroundColor:
              AppColors.surfaceContainerHigh.withAlpha((0.95 * 255).round()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Handle
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant
                      .withAlpha((0.4 * 255).round()),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              verticalMarginSmall,

              // Header Title
              Text(
                l10n.resetPinTitle,
                style: customTypography.headlineLargeMobile,
                textAlign: TextAlign.center,
              ),
              verticalMarginXXSmall,
              Text(
                l10n.resetPinDesc,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              verticalMarginSmall,

              // Flexible Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modal Scoped Error Banner
                      ValueListenableBuilder<String?>(
                        valueListenable: _errorMessageNotifier,
                        builder: (context, errorMsg, _) {
                          if (errorMsg == null) return const SizedBox.shrink();
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.semanticRed
                                  .withAlpha((0.2 * 255).round()),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: AppColors.semanticRed
                                      .withAlpha((0.5 * 255).round())),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: AppColors.semanticRed, size: 20.sp),
                                horizontalMarginSmall,
                                Expanded(
                                  child: Text(
                                    errorMsg,
                                    style: (textTheme.bodySmall ??
                                            const TextStyle())
                                        .copyWith(
                                      color: AppColors.semanticRed,
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
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 8.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      side: const BorderSide(
                                          color: AppColors.glassStroke),
                                    ),
                                    tileColor: AppColors.surfaceLow,
                                    leading: Icon(Icons.fingerprint_rounded,
                                        color: colorScheme.primary,
                                        size: 28.sp),
                                    title: Text(
                                      l10n.resetViaBiometrics,
                                      style: (textTheme.bodyLarge ??
                                              const TextStyle())
                                          .copyWith(
                                              fontWeight: FontWeights.bold),
                                    ),
                                    trailing: Icon(Icons.chevron_right_rounded,
                                        color: colorScheme.onSurfaceVariant),
                                    onTap: _resetViaBiometrics,
                                  ),
                                ),
                                verticalMarginSmall,
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 8.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      side: const BorderSide(
                                          color: AppColors.glassStroke),
                                    ),
                                    tileColor: AppColors.surfaceLow,
                                    leading: Icon(Icons.quiz_outlined,
                                        color: colorScheme.secondary,
                                        size: 28.sp),
                                    title: Text(
                                      l10n.resetViaSecurityAnswer,
                                      style: (textTheme.bodyLarge ??
                                              const TextStyle())
                                          .copyWith(
                                              fontWeight: FontWeights.bold),
                                    ),
                                    trailing: Icon(Icons.chevron_right_rounded,
                                        color: colorScheme.onSurfaceVariant),
                                    onTap: () {
                                      _errorMessageNotifier.value = null;
                                      _currentStepNotifier.value =
                                          ResetPinStep.verifyAnswer;
                                    },
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
                                  l10n.securityQuestionLabel,
                                  style: (textTheme.labelMedium ??
                                          const TextStyle())
                                      .copyWith(
                                    fontWeight: FontWeights.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                verticalMarginXXSmall,
                                ValueListenableBuilder<String?>(
                                  valueListenable: _randomQuestionNotifier,
                                  builder: (context, questionText, _) {
                                    return GlassContainer(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 12.h),
                                      child: Row(
                                        children: [
                                          Icon(Icons.help_outline_rounded,
                                              color: colorScheme.primary,
                                              size: 20.sp),
                                          horizontalMarginSmall,
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
                                verticalMarginMedium,
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
                                verticalMarginLarge,
                                ValueListenableBuilder<bool>(
                                  valueListenable: _isVerifyingNotifier,
                                  builder: (context, isVerifying, _) {
                                    return AppButton(
                                      text: l10n.verifyAnswer,
                                      onPressed: isVerifying
                                          ? null
                                          : _verifySecretAnswer,
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
                              Text(
                                currentStep == ResetPinStep.enterNewPin
                                    ? l10n.newPinHeader
                                    : l10n.confirmPinHeader,
                                style:
                                    (textTheme.bodyLarge ?? const TextStyle())
                                        .copyWith(fontWeight: FontWeights.bold),
                              ),
                              verticalMarginSmall,
                              ValueListenableBuilder<String>(
                                valueListenable: pinNotifier,
                                builder: (context, pin, _) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(4, (index) {
                                      final isFilled = index < pin.length;
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 8.w),
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
                                                : colorScheme.outlineVariant,
                                            width: 2.0,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                              verticalMarginMedium,
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
    );
  }
}
