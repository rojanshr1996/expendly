import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';
import '../extensions/shimmer_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/font_weights.dart';
import 'glass_container.dart';

/// Supported button variants for [AppButton].
enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  glass,
  danger,
}

/// A flexible, customizable, reusable button component.
///
/// Supports customizable parameters including [variant], [isLoading],
/// [icon], custom colors, dimensions, borders, and text styles.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.iconRight = false,
    this.variant = AppButtonVariant.primary,
    this.width = double.infinity,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.textStyle,
    this.padding,
    this.elevation,
  }) : assert(text != null || child != null,
            'Either text or child must be provided.');

  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool iconRight;
  final AppButtonVariant variant;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final effectiveHeight = height ?? 52.h;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(12.r);
    final isEnabled = onPressed != null && !isLoading;

    final baseColors = _computeColors(colorScheme);
    final effectiveBgColor = backgroundColor ?? baseColors.background;
    final effectiveFgColor = foregroundColor ?? baseColors.foreground;
    final effectiveBorderColor = borderColor ?? baseColors.border;

    Widget content;

    if (isLoading) {
      content = ShimmerBox(
        width: 60.w,
        height: 16.h,
        borderRadius: BorderRadius.circular(4.r),
      ).animateShimmer();
    } else if (child != null) {
      content = child!;
    } else {
      final labelStyle =
          (textStyle ?? textTheme.titleMedium ?? const TextStyle()).copyWith(
        color: effectiveFgColor,
        fontWeight: FontWeights.semiBold,
      );

      final labelWidget = Text(
        text!,
        style: labelStyle,
        textAlign: TextAlign.center,
      );

      if (icon != null) {
        content = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!iconRight) ...[
              icon!,
              SizedBox(width: 8.w),
            ],
            Flexible(child: labelWidget),
            if (iconRight) ...[
              SizedBox(width: 8.w),
              icon!,
            ],
          ],
        );
      } else {
        content = labelWidget;
      }
    }

    if (variant == AppButtonVariant.glass) {
      return SizedBox(
        width: width,
        height: effectiveHeight,
        child: GlassContainer(
          borderRadius: effectiveRadius,
          backgroundColor: isEnabled
              ? effectiveBgColor
              : AppColors.surfaceLow.withAlpha((0.3 * 255).round()),
          borderStrokeColor: effectiveBorderColor ?? AppColors.glassStroke,
          onTap: isEnabled ? onPressed : null,
          child: Center(child: content),
        ),
      );
    }

    if (variant == AppButtonVariant.outlined) {
      return SizedBox(
        width: width,
        height: effectiveHeight,
        child: OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveFgColor,
            side: BorderSide(
              color: isEnabled
                  ? (effectiveBorderColor ?? colorScheme.outline)
                  : colorScheme.outline.withAlpha((0.3 * 255).round()),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
            padding: padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          child: content,
        ),
      );
    }

    if (variant == AppButtonVariant.text) {
      return SizedBox(
        width: width,
        height: effectiveHeight,
        child: TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: effectiveFgColor,
            shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
            padding: padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveFgColor,
          elevation:
              elevation ?? (variant == AppButtonVariant.primary ? 2.0 : 0.0),
          shape: RoundedRectangleBorder(
            borderRadius: effectiveRadius,
            side: effectiveBorderColor != null
                ? BorderSide(color: effectiveBorderColor, width: 1.5)
                : BorderSide.none,
          ),
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        child: content,
      ),
    );
  }

  _ButtonColors _computeColors(ColorScheme colorScheme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _ButtonColors(
          background: colorScheme.primary,
          foreground: colorScheme.onPrimary,
        );
      case AppButtonVariant.secondary:
        return _ButtonColors(
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
        );
      case AppButtonVariant.outlined:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: colorScheme.primary,
          border: colorScheme.outline,
        );
      case AppButtonVariant.text:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: colorScheme.primary,
        );
      case AppButtonVariant.glass:
        return _ButtonColors(
          background: AppColors.surfaceLow.withAlpha((0.6 * 255).round()),
          foreground: colorScheme.onSurface,
          border: AppColors.glassStroke,
        );
      case AppButtonVariant.danger:
        return _ButtonColors(
          background: colorScheme.error,
          foreground: colorScheme.onError,
        );
    }
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
}
