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
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_keypad.dart';
import '../../../../core/widgets/status_components.dart';
import '../widgets/reset_pin_modal.dart';

@RoutePage()
class SecurityVerificationPage extends StatefulWidget {
  const SecurityVerificationPage({super.key});

  @override
  State<SecurityVerificationPage> createState() =>
      _SecurityVerificationPageState();
}

class _SecurityVerificationPageState extends State<SecurityVerificationPage>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<String> _enteredPinNotifier = ValueNotifier<String>('');

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
    _enteredPinNotifier.dispose();
    super.dispose();
  }

  void _onKeyPress(String value) {
    if (_enteredPinNotifier.value.length < 4) {
      _enteredPinNotifier.value += value;
      if (_enteredPinNotifier.value.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePress() {
    if (_enteredPinNotifier.value.isNotEmpty) {
      _enteredPinNotifier.value = _enteredPinNotifier.value
          .substring(0, _enteredPinNotifier.value.length - 1);
    }
  }

  void _verifyPin() async {
    final prefs = getIt<PreferenceService>();
    final targetPin = prefs.securityPin ?? '1234';

    if (_enteredPinNotifier.value == targetPin) {
      HapticFeedback.heavyImpact();
      context.router.replaceAll([const DashboardRoute()]);
    } else {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0.0);
      StatusComponents.showToast(
        context,
        message: context.l10n.incorrectPinMessage,
        isError: true,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _enteredPinNotifier.value = '';
    }
  }

  void _onBiometricsPressed() {
    HapticFeedback.lightImpact();
    // Simulate biometric unlock success
    context.router.replaceAll([const DashboardRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
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
                // Scrollable Top Header & PIN Dots Section
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          verticalMarginSmall,
                          Container(
                            width: 72.w,
                            height: 72.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceLow,
                              border: Border.all(color: AppColors.glassStroke),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary
                                      .withAlpha((0.2 * 255).round()),
                                  blurRadius: 20.r,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 32.sp,
                              color: colorScheme.primary,
                            ),
                          ),
                          verticalMarginSmall,
                          Text(
                            l10n.unlockToContinue,
                            style: customTypography.headlineLargeMobile,
                            textAlign: TextAlign.center,
                          ),
                          verticalMarginXXSmall,
                          Text(
                            l10n.secureAccessTitle,
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          verticalMarginMedium,

                          // PIN Dot Indicators
                          ValueListenableBuilder<String>(
                            valueListenable: _enteredPinNotifier,
                            builder: (context, enteredPin, _) {
                              return AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_shakeAnimation.value, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(4, (index) {
                                        final isFilled =
                                            index < enteredPin.length;
                                        return Container(
                                          margin: EdgeInsets.symmetric(
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
                                                  ? colorScheme.primary
                                                  : colorScheme.outlineVariant,
                                              width: 2.0,
                                            ),
                                            boxShadow: isFilled
                                                ? [
                                                    BoxShadow(
                                                      color: colorScheme.primary
                                                          .withAlpha((0.5 * 255)
                                                              .round()),
                                                      blurRadius: 10.r,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Numeric Keypad & Footer Actions
                Column(
                  children: [
                    CustomKeypad(
                      showDecimal: false,
                      onKeyPress: _onKeyPress,
                      onDeletePress: _onDeletePress,
                    ),
                    verticalMarginXSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _onBiometricsPressed,
                          icon: Icon(
                            Icons.fingerprint_rounded,
                            color: colorScheme.primary,
                            size: 20.sp,
                          ),
                          label: Text(
                            l10n.useBiometrics,
                            style: (textTheme.bodyMedium ?? const TextStyle())
                                .copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        TextButton.icon(
                          onPressed: () => ResetPinModal.show(context),
                          icon: Icon(
                            Icons.help_outline_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 18.sp,
                          ),
                          label: Text(
                            l10n.forgotPin,
                            style: (textTheme.bodyMedium ?? const TextStyle())
                                .copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ).defaultCanvasPadding(),
          ),
        ),
      ),
    );
  }
}
