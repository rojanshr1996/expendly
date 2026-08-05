import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';

/// Standardized custom text field component matching the Modern Fiscal Core design system.
/// Reusable across search bars, form inputs, numerical balance entries, and settings inputs.
///
/// Uses [HankenGrotesk] for general input fields and labels via context theme.
/// Uses [JetBrainsMono] strictly when [isAmount] is true for numerical currency entries.
/// Automatically dismisses the soft keyboard when tapping outside the text field.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool autoFocus;
  final bool enabled;
  final bool isAmount;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final FocusNode? focusNode;
  final BorderRadius? borderRadius;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.enabled = true,
    this.isAmount = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.validator,
    this.contentPadding,
    this.fillColor,
    this.focusNode,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final colorScheme = context.colorScheme;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(10.r);

    // If isAmount is true, use monospaced typography (JetBrains Mono).
    // Otherwise, use Hanken Grotesk from theme context.
    final defaultStyle = isAmount
        ? (customTypography.amountDisplay)
            .copyWith(color: colorScheme.onSurface)
        : (textTheme.bodyLarge ?? const TextStyle())
            .copyWith(color: colorScheme.onSurface);

    final defaultHintStyle = isAmount
        ? (customTypography.labelMediumMono)
            .copyWith(color: colorScheme.onSurfaceVariant)
        : (textTheme.bodyMedium ?? const TextStyle())
            .copyWith(color: colorScheme.onSurfaceVariant);

    final defaultLabelStyle =
        (textTheme.labelMedium ?? const TextStyle()).copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: labelStyle ?? defaultLabelStyle,
          ),
          SizedBox(height: 6.h),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          onTapOutside: onTapOutside ??
              (_) => FocusManager.instance.primaryFocus?.unfocus(),
          validator: validator,
          obscureText: obscureText,
          readOnly: readOnly,
          autofocus: autoFocus,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          keyboardType: keyboardType ??
              (isAmount
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : null),
          textInputAction: textInputAction,
          style: style ?? defaultStyle,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle ?? defaultHintStyle,
            errorText: errorText,
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            suffixIcon: suffixIcon,
            suffixIconConstraints: suffixIconConstraints,
            filled: true,
            fillColor: fillColor ?? colorScheme.surfaceContainerLow,
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(color: context.customColors.glassStroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(
                  color: context.customColors.glassStroke
                      .withAlpha((0.5 * 255).round())),
            ),
          ),
        ),
      ],
    );
  }
}
