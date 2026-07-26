import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';

@RoutePage()
class FinalSetupPage extends StatefulWidget {
  const FinalSetupPage({super.key});

  @override
  State<FinalSetupPage> createState() => _FinalSetupPageState();
}

class _FinalSetupPageState extends State<FinalSetupPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final ValueNotifier<bool> _enableBiometricsNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> _enableNotificationsNotifier =
      ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _enableBiometricsNotifier.dispose();
    _enableNotificationsNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  void _onGetStarted() async {
    _isLoadingNotifier.value = true;

    final prefs = getIt<PreferenceService>();
    await prefs.setBiometricsEnabled(_enableBiometricsNotifier.value);
    await prefs.setOnboardingCompleted(true);

    // Trigger local SQLite DB connection to seed default categories if needed
    final db = getIt<AppDatabase>();
    await db.select(db.categories).get();

    if (mounted) {
      context.router.replaceAll([const DashboardRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<PreferenceService>();
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Celebratory Hero Graphic
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.05);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 140.w,
                          height: 140.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceLow,
                            border: Border.all(
                              color: colorScheme.primary
                                  .withAlpha((0.3 * 255).round()),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary
                                    .withAlpha((0.2 * 255).round()),
                                blurRadius: 30.r,
                                spreadRadius: 5.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.task_alt_rounded,
                            size: 64.sp,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  verticalMarginLarge,

                  // Header Text
                  Text(
                    l10n.youAreAllSet,
                    style: customTypography.headlineLargeMobile,
                    textAlign: TextAlign.center,
                  ),
                  verticalMarginXSmall,
                  Text(
                    l10n.allSetDescription,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  verticalMarginLarge,

                  // Bento Summary Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          padding: EdgeInsets.all(14.w),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                color: colorScheme.secondary,
                                size: 24.sp,
                              ),
                              verticalMarginXXSmall,
                              Text(
                                l10n.defaultWallet,
                                style:
                                    (textTheme.labelSmall ?? const TextStyle())
                                        .copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              verticalMarginTiny,
                              Text(
                                l10n.personalLedger,
                                style:
                                    (textTheme.bodyMedium ?? const TextStyle())
                                        .copyWith(
                                  fontWeight: FontWeights.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      horizontalMarginSmall,
                      Expanded(
                        child: GlassContainer(
                          padding: EdgeInsets.all(14.w),
                          child: Column(
                            children: [
                              Icon(
                                Icons.currency_exchange_rounded,
                                color: colorScheme.tertiary,
                                size: 24.sp,
                              ),
                              verticalMarginXXSmall,
                              Text(
                                l10n.currency,
                                style:
                                    (textTheme.labelSmall ?? const TextStyle())
                                        .copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              verticalMarginTiny,
                              Text(
                                '${prefs.currencyCode} (${prefs.currencySymbol})',
                                style:
                                    (textTheme.bodyMedium ?? const TextStyle())
                                        .copyWith(
                                  fontWeight: FontWeights.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalMarginLarge,

                  // Preference Toggles Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.preferences,
                      style:
                          (textTheme.labelMedium ?? const TextStyle()).copyWith(
                        fontWeight: FontWeights.semiBold,
                        letterSpacing: 1.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  verticalMarginSmall,

                  // Biometrics Toggle Card
                  GlassContainer(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.fingerprint_rounded,
                            color: colorScheme.primary,
                            size: 22.sp,
                          ),
                        ),
                        horizontalMarginSmall,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.biometricUnlock,
                                style:
                                    (textTheme.bodyLarge ?? const TextStyle())
                                        .copyWith(
                                  fontWeight: FontWeights.semiBold,
                                ),
                              ),
                              Text(
                                l10n.biometricsDescription,
                                style:
                                    (textTheme.labelMedium ?? const TextStyle())
                                        .copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: _enableBiometricsNotifier,
                          builder: (context, enableBiometrics, _) {
                            return Switch.adaptive(
                              value: enableBiometrics,
                              activeColor: colorScheme.primary,
                              onChanged: (val) =>
                                  _enableBiometricsNotifier.value = val,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  verticalMarginXSmall,

                  // Push Notifications Toggle Card
                  GlassContainer(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            color: colorScheme.secondary,
                            size: 22.sp,
                          ),
                        ),
                        horizontalMarginSmall,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.pushNotifications,
                                style:
                                    (textTheme.bodyLarge ?? const TextStyle())
                                        .copyWith(
                                  fontWeight: FontWeights.semiBold,
                                ),
                              ),
                              Text(
                                l10n.notificationsDescription,
                                style:
                                    (textTheme.labelMedium ?? const TextStyle())
                                        .copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: _enableNotificationsNotifier,
                          builder: (context, enableNotifications, _) {
                            return Switch.adaptive(
                              value: enableNotifications,
                              activeColor: colorScheme.primary,
                              onChanged: (val) =>
                                  _enableNotificationsNotifier.value = val,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  verticalMarginXLarge,

                  // Get Started Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isLoadingNotifier,
                      builder: (context, isLoading, _) {
                        return ElevatedButton(
                          onPressed: isLoading ? null : _onGetStarted,
                          child: isLoading
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary),
                                  ),
                                )
                              : Text(l10n.getStarted),
                        );
                      },
                    ),
                  ),
                  verticalMarginSmall,
                  Text(
                    l10n.agreePolicyText,
                    style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
