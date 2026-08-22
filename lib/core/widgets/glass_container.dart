import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_radius.dart';

/// Reusable Glassmorphic Container with rich blur, semi-transparent liquid gradient background, and specular stroke border.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final Color? borderStrokeColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.backgroundColor,
    this.borderStrokeColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final effectiveRadius = borderRadius ?? AppRadius.borderLg;
    final effectiveBg = backgroundColor ??
        (isLight
            ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.90)
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.45));
    final effectiveStroke = borderStrokeColor ??
        (isLight
            ? colorScheme.outlineVariant.withValues(alpha: 0.50)
            : customColors.glassStroke.withValues(alpha: 0.45));
    final effectiveBlur = blur == 24.0 ? 16.0 : blur;

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveStroke, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: Container(
            padding: padding ?? EdgeInsets.all(16.w),
            color: Colors.transparent,
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
  final Color? backgroundColor;

  const GlassHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.blur = 20.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ??
        Theme.of(context).colorScheme.surface.withValues(alpha: 0.8);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: effectiveBg,
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
