import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Extension on [BuildContext] to quickly access responsive breakpoint utilities.
extension ResponsiveExtension on BuildContext {
  /// Returns the [DeviceType] for the current window width.
  DeviceType get deviceType => Breakpoints.of(this);

  /// Whether the current layout qualifies as tablet (medium or expanded).
  bool get isTablet => Breakpoints.isTablet(this);

  /// Whether the current layout qualifies as expanded (full tablet).
  bool get isExpanded => Breakpoints.isExpanded(this);

  /// Whether the current layout qualifies as compact (phones).
  bool get isCompact => deviceType == DeviceType.compact;
}
