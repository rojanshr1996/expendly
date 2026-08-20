import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// A reusable master-detail split pane layout for tablet UI.
///
/// This widget creates a side-by-side layout commonly used on larger screens,
/// where a list or menu is shown on the left (master) and content on the right (detail).
class MasterDetailLayout extends StatelessWidget {
  /// The widget to display in the master panel (left).
  final Widget master;

  /// The widget to display in the detail panel (right).
  final Widget detail;

  /// The flex factor for the master panel. Defaults to 1.
  final int masterFlex;

  /// The flex factor for the detail panel. Defaults to 2.
  final int detailFlex;

  /// The width of the gap between the master and detail panels. Defaults to 16.0.
  final double gutterWidth;

  /// Whether to display a thin vertical divider in the gutter. Defaults to false.
  final bool showDivider;

  const MasterDetailLayout({
    super.key,
    required this.master,
    required this.detail,
    this.masterFlex = 1,
    this.detailFlex = 2,
    this.gutterWidth = 16.0,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: masterFlex,
          child: master,
        ),
        if (showDivider)
          VerticalDivider(
            width: gutterWidth,
            thickness: 1,
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          )
        else
          SizedBox(width: gutterWidth),
        Expanded(
          flex: detailFlex,
          child: detail,
        ),
      ],
    );
  }
}
