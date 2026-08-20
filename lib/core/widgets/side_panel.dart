import 'package:flutter/material.dart';
import 'glass_container.dart';

/// A fixed-width sidebar container with glassmorphic styling for persistent context panels.
///
/// Useful for displaying Budget Health sidebars, Insights panels, or any supplementary
/// content on tablet layouts.
class SidePanel extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The fixed width of the panel. Defaults to 280.0.
  final double width;

  /// The padding to apply inside the panel. Defaults to EdgeInsets.all(20.0).
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const SidePanel({
    super.key,
    required this.child,
    this.width = 280.0,
    this.padding = const EdgeInsets.all(20.0),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassContainer(
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(16.0)),
        padding: padding ?? const EdgeInsets.all(20.0),
        child: child,
      ),
    );
  }
}
