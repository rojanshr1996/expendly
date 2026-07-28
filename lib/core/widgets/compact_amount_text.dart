import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/amount_formatting_extensions.dart';
import '../extensions/context_extensions.dart';
import '../theme/font_weights.dart';

/// Reusable Widget that displays amounts compactly (K, M, B for >= 100,000)
/// and prevents layout overflow using scale down fitting.
/// Tapping the widget displays a sleek tooltip showing the full exact amount.
class CompactAmountText extends StatelessWidget {
  final num amount;
  final String currencySymbol;
  final TextStyle? style;
  final bool isPrivacyMode;
  final bool showSign;
  final bool? isIncome;

  const CompactAmountText({
    super.key,
    required this.amount,
    required this.currencySymbol,
    this.style,
    this.isPrivacyMode = false,
    this.showSign = false,
    this.isIncome,
  });

  void _showFullAmountTooltip(BuildContext context) {
    if (isPrivacyMode) return;

    final colorScheme = context.colorScheme;
    final fullFormatted = amount.formatCurrency(
      currencySymbol,
      isPrivacyMode: false,
      compact: false,
      showSign: showSign,
      isIncome: isIncome,
    );

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.15,
          left: 24.w,
          right: 24.w,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, val, child) {
                return Opacity(
                  opacity: val,
                  child: Transform.scale(
                    scale: 0.95 + (0.05 * val),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: colorScheme.primary.withAlpha((0.4 * 255).round()),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.3 * 255).round()),
                      blurRadius: 16.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Full Exact Amount',
                            style: (context.textTheme.labelSmall ?? const TextStyle()).copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeights.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            fullFormatted,
                            style: (context.customTypography.labelMediumMono).copyWith(
                              color: colorScheme.onSurface,
                              fontSize: 16.sp,
                              fontWeight: FontWeights.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayText = amount.formatCurrency(
      currencySymbol,
      isPrivacyMode: isPrivacyMode,
      compact: true,
      showSign: showSign,
      isIncome: isIncome,
    );

    return GestureDetector(
      onTap: () => _showFullAmountTooltip(context),
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: isPrivacyMode ? '' : 'Tap to see full amount',
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            displayText,
            style: style,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
