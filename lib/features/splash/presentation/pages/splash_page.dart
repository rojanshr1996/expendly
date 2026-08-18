import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();

    // 1.8 second splash delay for a responsive, polished entry flow
    _timer = Timer(const Duration(milliseconds: 1800), _navigateToNextScreen);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache both dark and light logo images in Flutter's ImageCache for instantaneous rendering
    precacheImage(Assets.images.expendlyLogo.provider(), context);
    precacheImage(Assets.images.expendlyLogoLight.provider(), context);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final prefs = getIt<PreferenceService>();
    AppLogger.i(
        'Splash flow: ${prefs.isOnboardingCompleted} ${prefs.isSecurityPinSet}');

    if (!prefs.isOnboardingCompleted) {
      AppLogger.i(
          'Splash flow: Onboarding incomplete -> Navigating to OnboardingCarouselRoute');
      context.router.replace(const OnboardingCarouselRoute());
    } else if (prefs.isSecurityPinSet) {
      AppLogger.i(
          'Splash flow: Security PIN set -> Navigating to SecurityVerificationRoute');
      context.router.replace(const SecurityVerificationRoute());
    } else {
      AppLogger.i(
          'Splash flow: Onboarding completed -> Navigating to DashboardRoute');
      context.router.replace(const DashboardRoute());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background Glow Spheres
          Positioned(
            top: -80.h,
            left: -80.w,
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withAlpha((0.15 * 255).round()),
              ),
            ),
          ),
          Positioned(
            bottom: -80.h,
            right: -80.w,
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withAlpha((0.15 * 255).round()),
              ),
            ),
          ),

          // Main Responsive Canvas
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Animated Logo Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            Container(
                              width: 130.w,
                              height: 130.w,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(28.r),
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withAlpha((0.3 * 255).round()),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary
                                        .withAlpha((0.08 * 255).round()),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: (Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Assets.images.expendlyLogoLight.image(
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true,
                                      filterQuality: FilterQuality.medium,
                                    )
                                  : Assets.images.expendlyLogo.image(
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true,
                                      filterQuality: FilterQuality.medium,
                                    )),
                            ),
                            verticalMarginLarge,
                            Text(
                              l10n.appName,
                              style:
                                  (textTheme.headlineLarge ?? const TextStyle())
                                      .copyWith(
                                color: colorScheme.primary,
                                letterSpacing: -1.2,
                              ),
                            ),
                            verticalMarginXXSmall,
                            Text(
                              l10n.financeRedefined,
                              style: customTypography.labelMediumMono.copyWith(
                                letterSpacing: 1.5,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Progress Loader
                    SizedBox(
                      width: 180.w,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.r),
                            child: LinearProgressIndicator(
                              backgroundColor: AppColors.surfaceContainer,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary),
                              minHeight: 2.5.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalMarginXLarge,

                    // Minimalist Footer Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.appVersion,
                          style: (textTheme.labelSmall ?? const TextStyle())
                              .copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withAlpha((0.5 * 255).round()),
                          ),
                        ),
                        horizontalMarginXSmall,
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        horizontalMarginXSmall,
                        Text(
                          l10n.offlineEncryption,
                          style: (textTheme.labelSmall ?? const TextStyle())
                              .copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withAlpha((0.5 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).defaultCanvasPadding(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
