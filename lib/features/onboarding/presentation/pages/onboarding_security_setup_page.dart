import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_keypad.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/status_components.dart';
import '../widgets/onboarding_header.dart';

@RoutePage()
class OnboardingSecuritySetupPage extends StatefulWidget {
  const OnboardingSecuritySetupPage({super.key});

  @override
  State<OnboardingSecuritySetupPage> createState() =>
      _OnboardingSecuritySetupPageState();
}

class _OnboardingSecuritySetupPageState
    extends State<OnboardingSecuritySetupPage>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<String> _firstPinNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _confirmPinNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> _isConfirmingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPinSetNotifier = ValueNotifier<bool>(false);

  final TextEditingController _answer1Controller = TextEditingController();
  final TextEditingController _answer2Controller = TextEditingController();

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
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
    _shakeController.dispose();
    _firstPinNotifier.dispose();
    _confirmPinNotifier.dispose();
    _isConfirmingNotifier.dispose();
    _isPinSetNotifier.dispose();
    _answer1Controller.dispose();
    _answer2Controller.dispose();
    super.dispose();
  }

  void _onKeyPress(String value) {
    if (!_isConfirmingNotifier.value) {
      if (_firstPinNotifier.value.length < 4) {
        _firstPinNotifier.value += value;
        if (_firstPinNotifier.value.length == 4) {
          HapticFeedback.lightImpact();
          _isConfirmingNotifier.value = true;
        }
      }
    } else {
      if (_confirmPinNotifier.value.length < 4) {
        _confirmPinNotifier.value += value;
        if (_confirmPinNotifier.value.length == 4) {
          _verifyPinMatch();
        }
      }
    }
  }

  void _onDeletePress() {
    if (!_isConfirmingNotifier.value) {
      if (_firstPinNotifier.value.isNotEmpty) {
        _firstPinNotifier.value = _firstPinNotifier.value
            .substring(0, _firstPinNotifier.value.length - 1);
      }
    } else {
      if (_confirmPinNotifier.value.isNotEmpty) {
        _confirmPinNotifier.value = _confirmPinNotifier.value
            .substring(0, _confirmPinNotifier.value.length - 1);
      } else {
        _isConfirmingNotifier.value = false;
      }
    }
  }

  void _verifyPinMatch() async {
    final firstPin = _firstPinNotifier.value;
    final confirmPin = _confirmPinNotifier.value;

    if (firstPin == confirmPin) {
      HapticFeedback.heavyImpact();
      _isPinSetNotifier.value = true;
    } else {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0.0);
      StatusComponents.showToast(
        context,
        message: context.l10n.pinMismatchError,
        isError: true,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _firstPinNotifier.value = '';
      _confirmPinNotifier.value = '';
      _isConfirmingNotifier.value = false;
    }
  }

  void _saveSecurityConfiguration() async {
    final ans1 = _answer1Controller.text.trim();
    final ans2 = _answer2Controller.text.trim();

    if (ans1.isEmpty || ans2.isEmpty) {
      HapticFeedback.vibrate();
      StatusComponents.showToast(
        context,
        message: context.l10n.securityQuestionsRequired,
        isError: true,
      );
      return;
    }

    final prefs = getIt<PreferenceService>();
    final confirmPin = _confirmPinNotifier.value;
    final q1 = context.l10n.recoveryQuestion1;
    final q2 = context.l10n.recoveryQuestion2;

    await prefs.setSecurityPin(confirmPin);
    await prefs.setSecurityQuestion1(q1);
    await prefs.setSecurityAnswer1(ans1);

    await prefs.setSecurityQuestion2(q2);
    await prefs.setSecurityAnswer2(ans2);

    if (mounted) {
      StatusComponents.showToast(
        context,
        message: context.l10n.securitySetupComplete,
        isError: false,
      );
      context.router.push(const FinalSetupRoute());
    }
  }

  void _onSkip() {
    context.router.push(const FinalSetupRoute());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Progress Header
                ValueListenableBuilder<bool>(
                  valueListenable: _isPinSetNotifier,
                  builder: (context, isPinSet, _) {
                    return OnboardingHeader(
                      progress: 0.90,
                      stepLabel: l10n.setupStep4,
                      titleLabel: l10n.stepSecurity,
                      onSkip: isPinSet ? null : _onSkip,
                    );
                  },
                ),

                // Content View: Switch between PIN setup & 2 Secret Recovery Questions setup
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isPinSetNotifier,
                        builder: (context, isPinSet, _) {
                          if (!isPinSet) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Header Section
                                ValueListenableBuilder<bool>(
                                  valueListenable: _isConfirmingNotifier,
                                  builder: (context, isConfirming, _) {
                                    return Column(
                                      children: [
                                        Text(
                                          isConfirming
                                              ? l10n.confirmPinHeader
                                              : l10n.setPinHeader,
                                          style: customTypography
                                              .headlineLargeMobile,
                                          textAlign: TextAlign.center,
                                        ),
                                        verticalMarginXXSmall,
                                        Text(
                                          l10n.setupPinDesc,
                                          style: textTheme.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                verticalMarginLarge,

                                // PIN Dots
                                ValueListenableBuilder<bool>(
                                  valueListenable: _isConfirmingNotifier,
                                  builder: (context, isConfirming, _) {
                                    final targetNotifier = isConfirming
                                        ? _confirmPinNotifier
                                        : _firstPinNotifier;
                                    return ValueListenableBuilder<String>(
                                      valueListenable: targetNotifier,
                                      builder: (context, pinValue, _) {
                                        return AnimatedBuilder(
                                          animation: _shakeAnimation,
                                          builder: (context, child) {
                                            return Transform.translate(
                                              offset: Offset(
                                                  _shakeAnimation.value, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children:
                                                    List.generate(4, (index) {
                                                  final isFilled =
                                                      index < pinValue.length;
                                                  return Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.w),
                                                    width: 16.w,
                                                    height: 16.w,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: isFilled
                                                          ? colorScheme.primary
                                                          : Colors.transparent,
                                                      border: Border.all(
                                                        color: isFilled
                                                            ? colorScheme
                                                                .primary
                                                            : colorScheme
                                                                .outlineVariant,
                                                        width: 2.0,
                                                      ),
                                                      boxShadow: isFilled
                                                          ? [
                                                              BoxShadow(
                                                                color: colorScheme
                                                                    .primary
                                                                    .withAlpha((0.5 *
                                                                            255)
                                                                        .round()),
                                                                blurRadius:
                                                                    10.r,
                                                              ),
                                                            ]
                                                          : [],
                                                    ),
                                                  );
                                                }),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          }

                          // Step B: Set 2 Secret Recovery Questions Overall
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.setupRecoveryTitle,
                                style: customTypography.headlineLargeMobile,
                                textAlign: TextAlign.center,
                              ),
                              verticalMarginXXSmall,
                              Text(
                                l10n.setupRecoveryDesc,
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              verticalMarginMedium,

                              // Question 1 Card
                              GlassContainer(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.question1Label,
                                      style: (textTheme.labelSmall ??
                                              const TextStyle())
                                          .copyWith(
                                        fontWeight: FontWeights.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    verticalMarginXXSmall,
                                    Text(
                                      l10n.recoveryQuestion1,
                                      style: (textTheme.bodyLarge ??
                                              const TextStyle())
                                          .copyWith(
                                        fontWeight: FontWeights.semiBold,
                                      ),
                                    ),
                                    verticalMarginSmall,
                                    AppTextField(
                                      controller: _answer1Controller,
                                      hintText: l10n.enterAnswerHint,
                                      prefixIcon: Icon(Icons.shield_rounded,
                                          color: colorScheme.primary,
                                          size: 20.sp),
                                    ),
                                  ],
                                ),
                              ),
                              verticalMarginSmall,

                              // Question 2 Card
                              GlassContainer(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.question2Label,
                                      style: (textTheme.labelSmall ??
                                              const TextStyle())
                                          .copyWith(
                                        fontWeight: FontWeights.bold,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    verticalMarginXXSmall,
                                    Text(
                                      l10n.recoveryQuestion2,
                                      style: (textTheme.bodyLarge ??
                                              const TextStyle())
                                          .copyWith(
                                        fontWeight: FontWeights.semiBold,
                                      ),
                                    ),
                                    verticalMarginSmall,
                                    AppTextField(
                                      controller: _answer2Controller,
                                      hintText: l10n.enterAnswerHint,
                                      prefixIcon: Icon(Icons.lock_rounded,
                                          color: colorScheme.secondary,
                                          size: 20.sp),
                                    ),
                                  ],
                                ),
                              ),
                              verticalMarginMedium,

                              AppButton(
                                text: l10n.saveSecuritySetup,
                                onPressed: _saveSecurityConfiguration,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Keypad (Visible only during PIN entry)
                ValueListenableBuilder<bool>(
                  valueListenable: _isPinSetNotifier,
                  builder: (context, isPinSet, _) {
                    if (isPinSet) return const SizedBox.shrink();
                    return CustomKeypad(
                      showDecimal: false,
                      onKeyPress: _onKeyPress,
                      onDeletePress: _onDeletePress,
                    );
                  },
                ),
              ],
            ).defaultCanvasPadding(),
          ),
        ),
      ),
    );
  }
}
