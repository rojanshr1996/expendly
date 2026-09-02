import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';
import 'glass_container.dart';

/// Reusable animated glass illustration card wrapper for hero icons and empty states.
/// Combines entrance scaling/rotation with ambient floating and pulse effects.
class AnimatedIllustrationCard extends StatelessWidget {
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

  const AnimatedIllustrationCard({
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

/// Rich animated illustration with entrance effects, rotated glass backdrop,
/// breathing glow, center hero icon, and floating accent badges.
class AnimatedHeroIllustration extends StatefulWidget {
  final double size;
  final IconData mainIcon;
  final Color? mainIconColor;
  final Color? glowColor;
  final IconData? topBadgeIcon;
  final Color? topBadgeColor;
  final IconData? bottomBadgeIcon;
  final Color? bottomBadgeColor;

  const AnimatedHeroIllustration({
    super.key,
    this.size = 200.0,
    required this.mainIcon,
    this.mainIconColor,
    this.glowColor,
    this.topBadgeIcon,
    this.topBadgeColor,
    this.bottomBadgeIcon,
    this.bottomBadgeColor,
  });

  @override
  State<AnimatedHeroIllustration> createState() =>
      _AnimatedHeroIllustrationState();
}

class _AnimatedHeroIllustrationState extends State<AnimatedHeroIllustration>
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    final primaryGlow = widget.glowColor ?? colorScheme.primary;
    final primaryIconColor = widget.mainIconColor ?? colorScheme.primary;
    final topBadgeIconColor = widget.topBadgeColor ?? colorScheme.primary;
    final bottomBadgeIconColor =
        widget.bottomBadgeColor ?? colorScheme.secondary;

    final scaleFactor = widget.size / 200.0;

    final glowSize = 180.0 * scaleFactor;
    final backdropSize = 140.0 * scaleFactor;
    final mainCardSize = 140.0 * scaleFactor;
    final mainIconSize = 56.0 * scaleFactor;

    final topBadgeCardSize = 42.0 * scaleFactor;
    final topBadgeIconSize = 22.0 * scaleFactor;

    final bottomBadgeCardSize = 44.0 * scaleFactor;
    final bottomBadgeIconSize = 24.0 * scaleFactor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _ambientController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow Pulse with ambient breathing
              Transform.scale(
                scale:
                    _glowScaleAnimation.value * _mainIconPulseAnimation.value,
                child: Opacity(
                  opacity: _glowOpacityAnimation.value,
                  child: Container(
                    width: glowSize,
                    height: glowSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryGlow.withValues(
                        alpha: isLight ? 0.08 : 0.12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGlow.withValues(
                            alpha: isLight ? 0.12 : 0.25,
                          ),
                          blurRadius: (40.0 *
                              scaleFactor *
                              _mainIconPulseAnimation.value),
                          spreadRadius: (10.0 *
                              scaleFactor *
                              _mainIconPulseAnimation.value),
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
                    width: backdropSize,
                    height: backdropSize,
                    decoration: BoxDecoration(
                      color: isLight
                          ? colorScheme.surfaceContainerLow
                              .withValues(alpha: 0.8)
                          : customColors.surfaceLow.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24.0 * scaleFactor),
                      border: Border.all(
                        color: isLight
                            ? colorScheme.outlineVariant.withValues(alpha: 0.40)
                            : customColors.glassStroke,
                      ),
                    ),
                  ),
                ),
              ),

              // Center Main Glass Card with Animated Icon
              AnimatedIllustrationCard(
                icon: widget.mainIcon,
                iconSize: mainIconSize,
                iconColor: primaryIconColor,
                containerSize: mainCardSize,
                borderRadius: BorderRadius.circular(24.0 * scaleFactor),
                scaleAnimation: _mainIconScaleAnimation,
                rotateAnimation: _mainIconRotateAnimation,
                floatAnimation: _mainIconFloatAnimation,
                pulseAnimation: _mainIconPulseAnimation,
              ),

              // Floating Top-Right Badge
              if (widget.topBadgeIcon != null)
                Positioned(
                  top: 10.0 * scaleFactor,
                  right: 10.0 * scaleFactor,
                  child: AnimatedIllustrationCard(
                    icon: widget.topBadgeIcon!,
                    iconSize: topBadgeIconSize,
                    iconColor: topBadgeIconColor,
                    containerSize: topBadgeCardSize,
                    backgroundColor: isLight
                        ? colorScheme.surfaceContainerLowest
                        : customColors.surfaceLow,
                    borderRadius: BorderRadius.circular(14.0 * scaleFactor),
                    scaleAnimation: _topBadgeScaleAnimation,
                    floatAnimation: _badgeFloatAnimation,
                  ),
                ),

              // Floating Bottom-Left Badge
              if (widget.bottomBadgeIcon != null)
                Positioned(
                  bottom: 12.0 * scaleFactor,
                  left: 8.0 * scaleFactor,
                  child: AnimatedIllustrationCard(
                    icon: widget.bottomBadgeIcon!,
                    iconSize: bottomBadgeIconSize,
                    iconColor: bottomBadgeIconColor,
                    containerSize: bottomBadgeCardSize,
                    backgroundColor: isLight
                        ? colorScheme.surfaceContainerLowest
                        : customColors.surfaceLow,
                    borderRadius: BorderRadius.circular(14.0 * scaleFactor),
                    scaleAnimation: _bottomBadgeScaleAnimation,
                    floatAnimation: _badgeFloatAnimation,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
