import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Extension methods for app-wide shimmer loading states powered by [Skeletonizer].
extension ShimmerExtension on Widget {
  /// Wraps any Widget in a [Skeletonizer] shimmer animation effect.
  Widget animateShimmer({
    bool enabled = true,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: baseColor ?? Colors.grey.withAlpha((0.15 * 255).round()),
        highlightColor: highlightColor ?? Colors.grey.withAlpha((0.35 * 255).round()),
        duration: const Duration(milliseconds: 1200),
      ),
      child: this,
    );
  }

  /// Simple skeletonizer wrapper with default theme effect.
  Widget toSkeleton({bool enabled = true}) {
    return Skeletonizer(
      enabled: enabled,
      child: this,
    );
  }
}

/// Reusable rectangular or rounded shimmer placeholder block.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Standalone StatelessWidget wrapper for applying Skeletonizer shimmer animations.
class AppShimmerWrapper extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const AppShimmerWrapper({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return child.animateShimmer(enabled: enabled);
  }
}
