import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../responsive/breakpoints.dart';

/// A utility that shows content as a modal bottom sheet on compact layouts,
/// or as a centered dialog on tablet layouts.
class AdaptiveSheet {
  /// Shows the provided builder as a modal bottom sheet or dialog depending on screen size.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double maxDialogWidth = 480,
    bool isDismissible = true,
    bool useRootNavigator = true,
    bool isScrollControlled = true,
  }) async {
    final isTablet = Breakpoints.isTablet(context);

    if (isTablet) {
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        useRootNavigator: useRootNavigator,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: dialogContext.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxDialogWidth),
              child: builder(dialogContext),
            ),
          );
        },
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        isDismissible: isDismissible,
        useRootNavigator: useRootNavigator,
        isScrollControlled: isScrollControlled,
        backgroundColor: context.colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        clipBehavior: Clip.antiAlias,
        builder: builder,
      );
    }
  }
}
