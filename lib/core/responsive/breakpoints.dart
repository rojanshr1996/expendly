import 'package:flutter/material.dart';

/// Device type classification based on window width.
enum DeviceType { compact, medium, expanded }

/// Breakpoint utility matching Material 3 canonical window size classes.
/// - compact: < 600px (phones portrait)
/// - medium: 600px – 839px (small tablets, large phones landscape, foldables)
/// - expanded: >= 840px (standard tablets)
class Breakpoints {
  Breakpoints._();

  static const double compactMax = 600;
  static const double expandedMin = 840;

  /// Returns the [DeviceType] for the current window width.
  static DeviceType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= expandedMin) return DeviceType.expanded;
    if (width >= compactMax) return DeviceType.medium;
    return DeviceType.compact;
  }

  /// Whether the current layout qualifies as tablet (medium or expanded).
  static bool isTablet(BuildContext context) =>
      of(context) != DeviceType.compact;

  /// Whether the current layout qualifies as expanded (full tablet).
  static bool isExpanded(BuildContext context) =>
      of(context) == DeviceType.expanded;
}
