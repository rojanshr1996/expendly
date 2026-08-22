import 'package:expendly/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/glass_container.dart';

/// Reusable Empty Dashboard State component matching design/stitch/screens/empty_dashboard_state.
/// Rendered for first-time users before any transactions have been added to the database.
class EmptyDashboardView extends StatefulWidget {
  final VoidCallback onAddTransaction;

  const EmptyDashboardView({
    super.key,
    required this.onAddTransaction,
  });

  @override
  State<EmptyDashboardView> createState() => _EmptyDashboardViewState();
}

class _EmptyDashboardViewState extends State<EmptyDashboardView>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _ambientController;

  late final Animation<double> _glowScaleAnimation;
  late final Animation<double> _glowOpacityAnimation;

  late final Animation<double> _backdropScaleAnimation;
  late final Animation<double> _backdropRotateAnimation;

  late final Animation<double> _mainIconScaleAnimation;
  late final Animation<double> _mainIconRotateAnimation;
  late final Animation<double> _mainIconFloatAnimation;
  late final Animation<double> _mainIconPulseAnimation;

  late final Animation<double> _topBadgeScaleAnimation;
  late final Animation<double> _bottomBadgeScaleAnimation;
  late final Animation<double> _badgeFloatAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation sequence (1000ms duration)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _glowScaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _glowOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _backdropScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _backdropRotateAnimation = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );

    _mainIconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.85, curve: Curves.elasticOut),
      ),
    );

    _mainIconRotateAnimation = Tween<double>(begin: -0.3, end: -0.08).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _topBadgeScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.9, curve: Curves.elasticOut),
      ),
    );

    _bottomBadgeScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    // 2. Ambient continuous floating & pulsing animation (3.5s cycle)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _mainIconFloatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOutSine,
      ),
    );

    _mainIconPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOutSine,
      ),
    );

    _badgeFloatAnimation = Tween<double>(begin: 5.0, end: -5.0).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Start sequence: entrance first, then continuous ambient floating
    _entranceController.forward().then((_) {
      if (mounted) {
        _ambientController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sophisticated Animated Glass Illustration Container
            SizedBox(
              width: 200.w,
              height: 200.w,
              child: AnimatedBuilder(
                animation:
                    Listenable.merge([_entranceController, _ambientController]),
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Teal Glow Pulse with ambient breathing
                      Transform.scale(
                        scale: _glowScaleAnimation.value *
                            _mainIconPulseAnimation.value,
                        child: Opacity(
                          opacity: _glowOpacityAnimation.value,
                          child: Container(
                            width: 180.w,
                            height: 180.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary.withValues(
                                alpha: isLight ? 0.08 : 0.12,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: isLight ? 0.12 : 0.25,
                                  ),
                                  blurRadius:
                                      (40 * _mainIconPulseAnimation.value).r,
                                  spreadRadius:
                                      (10 * _mainIconPulseAnimation.value).r,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Rotated Glass Card Backdrop
                      Transform.scale(
                        scale: _backdropScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _backdropRotateAnimation.value,
                          child: Container(
                            width: 140.w,
                            height: 140.w,
                            decoration: BoxDecoration(
                              color: isLight
                                  ? colorScheme.surfaceContainerLow
                                      .withValues(alpha: 0.8)
                                  : customColors.surfaceLow
                                      .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: isLight
                                    ? colorScheme.outlineVariant
                                        .withValues(alpha: 0.40)
                                    : customColors.glassStroke,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Center Main Glass Card with Animated Wallet Icon
                      AnimatedLargeIconCard(
                        icon: Icons.account_balance_wallet_rounded,
                        iconSize: 56.sp,
                        iconColor: colorScheme.primary,
                        containerSize: 140.w,
                        scaleAnimation: _mainIconScaleAnimation,
                        rotateAnimation: _mainIconRotateAnimation,
                        floatAnimation: _mainIconFloatAnimation,
                        pulseAnimation: _mainIconPulseAnimation,
                      ),

                      // Floating Top-Right Badge
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: AnimatedLargeIconCard(
                          icon: Icons.add_chart_rounded,
                          iconSize: 22.sp,
                          iconColor: colorScheme.primary,
                          containerSize: 42.w,
                          backgroundColor: isLight
                              ? colorScheme.surfaceContainerLowest
                              : customColors.surfaceLow,
                          borderRadius: BorderRadius.circular(14.r),
                          scaleAnimation: _topBadgeScaleAnimation,
                          floatAnimation: _badgeFloatAnimation,
                        ),
                      ),

                      // Floating Bottom-Left Badge
                      Positioned(
                        bottom: 12.h,
                        left: 8.w,
                        child: AnimatedLargeIconCard(
                          icon: Icons.payments_rounded,
                          iconSize: 24.sp,
                          iconColor: colorScheme.secondary,
                          containerSize: 44.w,
                          backgroundColor: isLight
                              ? colorScheme.surfaceContainerLowest
                              : customColors.surfaceLow,
                          borderRadius: BorderRadius.circular(14.r),
                          scaleAnimation: _bottomBadgeScaleAnimation,
                          floatAnimation: _badgeFloatAnimation,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            verticalMarginLarge,

            // Welcome Copy
            Text(
              context.l10n.welcomeFinancialJourney,
              textAlign: TextAlign.center,
              style: (textTheme.headlineSmall ?? AppTypography.headlineSmall)
                  .copyWith(
                fontWeight: FontWeights.bold,
                color: colorScheme.onSurface,
              ),
            ),
            verticalMarginSmall,

            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 320.w),
              child: Text(
                context.l10n.emptyDashboardDesc,
                textAlign: TextAlign.center,
                style:
                    (textTheme.bodyMedium ?? AppTypography.bodyMedium).copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            verticalMarginLarge,

            // Add First Transaction CTA Button
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340.0),
              child: AppButton(
                text: context.l10n.addFirstTransaction,
                icon: const Icon(Icons.add_rounded),
                onPressed: widget.onAddTransaction,
              ),
            ),
            verticalMarginLarge,

            // Secondary Guidance Badges Footer
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16.0,
              runSpacing: 8.0,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 15.0,
                      color: colorScheme.onSurfaceVariant
                          .withAlpha((0.6 * 255).round()),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Private & Secure',
                      style: customTypography.labelMediumMono.copyWith(
                        fontSize: 11.0,
                        color: colorScheme.onSurfaceVariant
                            .withAlpha((0.7 * 255).round()),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 4.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.outlineVariant,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 15.0,
                      color: colorScheme.onSurfaceVariant
                          .withAlpha((0.6 * 255).round()),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Offline Ready',
                      style: customTypography.labelMediumMono.copyWith(
                        fontSize: 11.0,
                        color: colorScheme.onSurfaceVariant
                            .withAlpha((0.7 * 255).round()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable animated glass card wrapper for large illustration icons.
/// Combines entrance scaling/rotation with ambient floating and pulse effects.
/// Use this component for all large icons added to empty states and dashboard screens.
class AnimatedLargeIconCard extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final double containerSize;
  final double rotateAngle;
  final Color? backgroundColor;
  final Animation<double>? scaleAnimation;
  final Animation<double>? rotateAnimation;
  final Animation<double>? floatAnimation;
  final Animation<double>? pulseAnimation;
  final BorderRadius? borderRadius;

  const AnimatedLargeIconCard({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.containerSize,
    this.rotateAngle = 0.0,
    this.backgroundColor,
    this.scaleAnimation,
    this.rotateAnimation,
    this.floatAnimation,
    this.pulseAnimation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colorScheme = Theme.of(context).colorScheme;
    final scale = scaleAnimation?.value ?? 1.0;
    final angle = rotateAnimation?.value ?? rotateAngle;
    final floatOffsetY = floatAnimation?.value ?? 0.0;
    final pulse = pulseAnimation?.value ?? 1.0;

    return Transform.translate(
      offset: Offset(0, floatOffsetY),
      child: Transform.rotate(
        angle: angle,
        child: Transform.scale(
          scale: scale * pulse,
          child: GlassContainer(
            width: containerSize,
            height: containerSize,
            padding: EdgeInsets.zero,
            borderRadius: borderRadius ?? BorderRadius.circular(24.r),
            blur: isLight ? 0 : 12,
            backgroundColor: backgroundColor ??
                (isLight
                    ? colorScheme.surfaceContainerLowest
                    : colorScheme.surfaceContainerHigh.withValues(alpha: 0.85)),
            borderStrokeColor: isLight
                ? iconColor.withValues(alpha: 0.25)
                : iconColor.withValues(alpha: 0.35),
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
