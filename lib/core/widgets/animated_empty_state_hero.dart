import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';
import 'glass_container.dart';

/// Reusable animated illustration widget for empty states.
/// Features an entrance elastic pop with continuous ambient floating and glowing pulse.
class AnimatedEmptyStateHero extends StatefulWidget {
  final IconData primaryIcon;
  final Color? primaryColor;
  final IconData? secondaryBadgeTop;
  final Color? secondaryColorTop;
  final IconData? secondaryBadgeBottom;
  final Color? secondaryColorBottom;
  final double? containerSize;
  final double? heroSize;

  const AnimatedEmptyStateHero({
    super.key,
    required this.primaryIcon,
    this.primaryColor,
    this.secondaryBadgeTop,
    this.secondaryColorTop,
    this.secondaryBadgeBottom,
    this.secondaryColorBottom,
    this.containerSize,
    this.heroSize,
  });

  @override
  State<AnimatedEmptyStateHero> createState() => _AnimatedEmptyStateHeroState();
}

class _AnimatedEmptyStateHeroState extends State<AnimatedEmptyStateHero>
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

    // 1. Entrance animation sequence (900ms duration)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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

    _backdropRotateAnimation = Tween<double>(begin: 0.0, end: 0.14).animate(
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

    _mainIconRotateAnimation = Tween<double>(begin: -0.25, end: -0.06).animate(
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

    // 2. Ambient continuous floating & pulsing animation (3.2s cycle)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _mainIconFloatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOutSine,
      ),
    );

    _mainIconPulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOutSine,
      ),
    );

    _badgeFloatAnimation = Tween<double>(begin: 4.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOutSine,
      ),
    );

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

    final primaryCol = widget.primaryColor ?? colorScheme.primary;
    final topBadgeCol = widget.secondaryColorTop ?? colorScheme.primary;
    final bottomBadgeCol = widget.secondaryColorBottom ?? colorScheme.secondary;

    final totalSize = widget.heroSize ?? 170.w;
    final mainCardSize = widget.containerSize ?? 116.w;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _ambientController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Ambient Glow Pulse
              Transform.scale(
                scale:
                    _glowScaleAnimation.value * _mainIconPulseAnimation.value,
                child: Opacity(
                  opacity: _glowOpacityAnimation.value,
                  child: Container(
                    width: totalSize * 0.85,
                    height: totalSize * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          primaryCol.withValues(alpha: isLight ? 0.08 : 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryCol.withValues(
                            alpha: isLight ? 0.12 : 0.22,
                          ),
                          blurRadius: (32 * _mainIconPulseAnimation.value).r,
                          spreadRadius: (6 * _mainIconPulseAnimation.value).r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Rotated Backdrop Card
              Transform.scale(
                scale: _backdropScaleAnimation.value,
                child: Transform.rotate(
                  angle: _backdropRotateAnimation.value,
                  child: Container(
                    width: mainCardSize,
                    height: mainCardSize,
                    decoration: BoxDecoration(
                      color: isLight
                          ? colorScheme.surfaceContainerLow
                              .withValues(alpha: 0.8)
                          : customColors.surfaceLow.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: isLight
                            ? colorScheme.outlineVariant.withValues(alpha: 0.40)
                            : customColors.glassStroke,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Center Main Card with Primary Icon
              Transform.translate(
                offset: Offset(0, _mainIconFloatAnimation.value),
                child: Transform.rotate(
                  angle: _mainIconRotateAnimation.value,
                  child: Transform.scale(
                    scale: _mainIconScaleAnimation.value *
                        _mainIconPulseAnimation.value,
                    child: GlassContainer(
                      width: mainCardSize,
                      height: mainCardSize,
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(22.r),
                      blur: isLight ? 0 : 12,
                      backgroundColor: isLight
                          ? colorScheme.surfaceContainerLowest
                          : colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.85),
                      borderStrokeColor: isLight
                          ? primaryCol.withValues(alpha: 0.25)
                          : primaryCol.withValues(alpha: 0.35),
                      child: Center(
                        child: Icon(
                          widget.primaryIcon,
                          size: (mainCardSize * 0.42).sp,
                          color: primaryCol,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Floating Top-Right Mini Badge
              if (widget.secondaryBadgeTop != null)
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: Transform.translate(
                    offset: Offset(0, _badgeFloatAnimation.value),
                    child: Transform.scale(
                      scale: _topBadgeScaleAnimation.value,
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: isLight
                              ? colorScheme.surfaceContainerLowest
                              : colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isLight
                                ? topBadgeCol.withValues(alpha: 0.25)
                                : topBadgeCol.withValues(alpha: 0.35),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: topBadgeCol.withValues(
                                alpha: isLight ? 0.12 : 0.20,
                              ),
                              blurRadius: 8.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.secondaryBadgeTop,
                          size: 18.sp,
                          color: topBadgeCol,
                        ),
                      ),
                    ),
                  ),
                ),

              // 5. Floating Bottom-Left Mini Badge
              if (widget.secondaryBadgeBottom != null)
                Positioned(
                  bottom: 8.h,
                  left: 6.w,
                  child: Transform.translate(
                    offset: Offset(0, -_badgeFloatAnimation.value),
                    child: Transform.scale(
                      scale: _bottomBadgeScaleAnimation.value,
                      child: Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: isLight
                              ? colorScheme.surfaceContainerLowest
                              : colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isLight
                                ? bottomBadgeCol.withValues(alpha: 0.25)
                                : bottomBadgeCol.withValues(alpha: 0.35),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: bottomBadgeCol.withValues(
                                alpha: isLight ? 0.12 : 0.20,
                              ),
                              blurRadius: 8.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.secondaryBadgeBottom,
                          size: 19.sp,
                          color: bottomBadgeCol,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
