import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Reusable Glassmorphic Container with blur, semi-transparent background, and 1px stroke border.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final Color borderStrokeColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.backgroundColor,
    this.borderStrokeColor = AppColors.glassStroke,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.borderLg;
    final effectiveBg =
        backgroundColor ?? AppColors.surfaceLow.withAlpha((0.7 * 255).round());

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: Border.all(color: borderStrokeColor, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(16.w),
            color: effectiveBg,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Glassmorphic App Header for top bars with backdrop blur.
class GlassHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final double blur;
  final Color backgroundColor;

  const GlassHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.blur = 20.0,
    this.backgroundColor =
        const Color(0x990E1513), // 60% opacity of Midnight Slate #0E1513
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: backgroundColor,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            title: title,
            leading: leading,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
