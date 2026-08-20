import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// A responsive builder that provides different widgets based on the current window size.
class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return switch (Breakpoints.of(context)) {
      DeviceType.expanded => (expanded ?? medium ?? compact)(context),
      DeviceType.medium => (medium ?? compact)(context),
      DeviceType.compact => compact(context),
    };
  }
}
