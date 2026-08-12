import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../database/enums/database_enums.dart';
import '../di/injection.dart';
import '../extensions/amount_formatting_extensions.dart';
import '../extensions/context_extensions.dart';
import '../services/preference_service.dart';
import '../theme/font_weights.dart';

/// Reusable Widget that displays amounts compactly (K, M, B for >= 100,000)
/// and prevents layout overflow using scale down fitting.
/// Tapping the widget displays a sleek tooltip showing the full exact amount.
class CompactAmountText extends StatefulWidget {
  final num amount;
  final String? currencySymbol;
  final TextStyle? style;
  final bool isPrivacyMode;
  final bool showSign;
  final bool? isIncome;
  final TransactionType? type;
  final bool compact;
  final bool animate;

  const CompactAmountText({
    super.key,
    required this.amount,
    this.currencySymbol,
    this.style,
    this.isPrivacyMode = false,
    this.showSign = false,
    this.isIncome,
    this.type,
    this.compact = true,
    this.animate = true,
  });

  @override
  State<CompactAmountText> createState() => _CompactAmountTextState();
}

class _CompactAmountTextState extends State<CompactAmountText> {
  late num _previousAmount;

  @override
  void initState() {
    super.initState();
    _previousAmount = widget.animate ? 0 : widget.amount;
  }

  @override
  void didUpdateWidget(covariant CompactAmountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _previousAmount = oldWidget.amount;
    }
  }

  void _showFullAmountTooltip(BuildContext context, String effectiveSymbol) {
    if (widget.isPrivacyMode || !widget.compact) return;

    final colorScheme = context.colorScheme;
    final fullFormatted = widget.amount.formatCurrency(
      effectiveSymbol,
      isPrivacyMode: false,
      compact: false,
      showSign: widget.showSign,
      isIncome: widget.isIncome,
      type: widget.type,
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
                            style: (context.textTheme.labelSmall ??
                                    const TextStyle())
                                .copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeights.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            fullFormatted,
                            style: (context.customTypography.labelMediumMono)
                                .copyWith(
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
    final prefs = getIt<PreferenceService>();

    return ValueListenableBuilder<String>(
      valueListenable: prefs.currencySymbolNotifier,
      builder: (context, activeSymbol, _) {
        final effectiveSymbol =
            (widget.currencySymbol != null && widget.currencySymbol!.isNotEmpty)
                ? widget.currencySymbol!
                : activeSymbol;

        if (widget.animate && !widget.isPrivacyMode) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: _previousAmount.toDouble(),
              end: widget.amount.toDouble(),
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, animVal, _) {
              final displayText = animVal.formatCurrency(
                effectiveSymbol,
                isPrivacyMode: false,
                compact: widget.compact,
                showSign: widget.showSign,
                isIncome: widget.isIncome,
                type: widget.type,
              );

              return GestureDetector(
                onTap: widget.compact
                    ? () => _showFullAmountTooltip(context, effectiveSymbol)
                    : null,
                behavior: HitTestBehavior.opaque,
                child: Tooltip(
                  message: (!widget.compact || widget.isPrivacyMode)
                      ? ''
                      : 'Tap to see full amount',
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      displayText,
                      style: widget.style,
                      maxLines: 1,
                    ),
                  ),
                ),
              );
            },
          );
        }

        final displayText = widget.amount.formatCurrency(
          effectiveSymbol,
          isPrivacyMode: widget.isPrivacyMode,
          compact: widget.compact,
          showSign: widget.showSign,
          isIncome: widget.isIncome,
          type: widget.type,
        );

        return GestureDetector(
          onTap: widget.compact
              ? () => _showFullAmountTooltip(context, effectiveSymbol)
              : null,
          behavior: HitTestBehavior.opaque,
          child: Tooltip(
            message: (!widget.compact || widget.isPrivacyMode)
                ? ''
                : 'Tap to see full amount',
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                displayText,
                style: widget.style,
                maxLines: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
