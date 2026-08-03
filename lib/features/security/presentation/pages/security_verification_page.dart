import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/biometric_auth_service.dart';
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
    with TickerProviderStateMixin {
  final ValueNotifier<String> _enteredPinNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> _isSuccessNotifier = ValueNotifier<bool>(false);

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late final AnimationController _successController;
  late final Animation<double> _successAnimation;

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

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _successAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _successController.dispose();
    _enteredPinNotifier.dispose();
    _isSuccessNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleSuccess() async {
    HapticFeedback.heavyImpact();
    _isSuccessNotifier.value = true;
    await _successController.forward(from: 0.0);
    if (mounted) {
      context.router.replaceAll([const DashboardRoute()]);
    }
  }

  void _onKeyPress(String value) {
    if (_enteredPinNotifier.value.length < 4 && !_isSuccessNotifier.value) {
      _enteredPinNotifier.value += value;
      if (_enteredPinNotifier.value.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePress() {
    if (_enteredPinNotifier.value.isNotEmpty && !_isSuccessNotifier.value) {
      _enteredPinNotifier.value = _enteredPinNotifier.value
          .substring(0, _enteredPinNotifier.value.length - 1);
    }
  }

  void _verifyPin() async {
    final prefs = getIt<PreferenceService>();
    final targetPin = prefs.securityPin ?? '1234';

    if (_enteredPinNotifier.value == targetPin) {
      await _handleSuccess();
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

  Future<void> _onBiometricsPressed() async {
    if (_isSuccessNotifier.value) return;
    HapticFeedback.lightImpact();
    if (!mounted) return;
    final reason = context.l10n.biometricReason;
    final notAvailableMsg = context.l10n.biometricNotAvailable;
    final failedMsg = context.l10n.biometricAuthFailed;

    final bioService = getIt<BiometricAuthService>();
    final isAvailable = await bioService.isBiometricAvailable();

    if (!isAvailable) {
      if (mounted) {
        StatusComponents.showToast(
          context,
          message: notAvailableMsg,
          isError: true,
        );
      }
      return;
    }

    final authenticated = await bioService.authenticate(
      localizedReason: reason,
    );

    if (authenticated) {
      if (mounted) {
        await _handleSuccess();
      }
    } else if (mounted) {
      StatusComponents.showToast(
        context,
        message: failedMsg,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;
    final isBiometricsEnabled = getIt<PreferenceService>().isBiometricsEnabled;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _successAnimation,
          builder: (context, child) {
            final progress = _successAnimation.value;
            final opacity = (1.0 - (progress * 0.9)).clamp(0.0, 1.0);
            final scale = 1.0 + (progress * 0.05);

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
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
                            ValueListenableBuilder<bool>(
                              valueListenable: _isSuccessNotifier,
                              builder: (context, isSuccess, _) {
                                final iconColor = isSuccess
                                    ? AppColors.semanticGreen
                                    : colorScheme.primary;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 72.w,
                                  height: 72.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSuccess
                                        ? AppColors.semanticGreen.withValues(alpha: 0.2)
                                        : AppColors.surfaceLow,
                                    border: Border.all(
                                      color: isSuccess
                                          ? AppColors.semanticGreen
                                          : AppColors.glassStroke,
                                      width: isSuccess ? 2.0 : 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: iconColor.withValues(
                                            alpha: isSuccess ? 0.6 : 0.2),
                                        blurRadius: isSuccess ? 30.r : 20.r,
                                        spreadRadius: isSuccess ? 4.r : 0,
                                      ),
                                    ],
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                    child: Icon(
                                      isSuccess
                                          ? Icons.lock_open_rounded
                                          : Icons.lock_outline_rounded,
                                      key: ValueKey(isSuccess),
                                      size: 32.sp,
                                      color: iconColor,
                                    ),
                                  ),
                                );
                              },
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
                        if (isBiometricsEnabled) ...[
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
                        ],
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
    ),
  );
}
}
