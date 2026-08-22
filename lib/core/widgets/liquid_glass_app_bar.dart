import 'dart:ui';

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// Reusable Liquid Glass App Bar matching the Modern Fiscal Core glass aesthetic.
/// Provides frosted background blur, delicate glass borders, subtle elevation shadow,
/// and support for under-glass scrolling when used with `extendBodyBehindAppBar: true`.
class LiquidGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double height;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onLeadingPressed;
  final bool showLeading;
  final bool primary;
  final double blur;

  const LiquidGlassAppBar({
    super.key,
    this.title,
    this.titleText,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.height = kToolbarHeight,
    this.bottom,
    this.onLeadingPressed,
    this.showLeading = true,
    this.primary = true,
    this.blur = 16.0,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AppBar(
      primary: primary,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      toolbarHeight: height,
      leading: leading ??
          (showLeading && Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: colorScheme.onSurface,
                  ),
                  onPressed:
                      onLeadingPressed ?? () => Navigator.maybePop(context),
                )
              : null),
      title: title ??
          (titleText != null
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    titleText!,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                )
              : null),
      actions: actions,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? [
                    colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
                    colorScheme.surfaceContainerHigh.withValues(alpha: 0.20),
                  ]
                : [
                    colorScheme.surfaceContainerHigh.withValues(alpha: 0.25),
                    colorScheme.surfaceContainerLow.withValues(alpha: 0.15),
                  ],
          ),
          border: Border(
            bottom: BorderSide(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.50)
                  : customColors.glassStroke.withValues(alpha: 0.40),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.15),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
