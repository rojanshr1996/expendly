import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../domain/entities/expense_split.dart';
import '../../domain/usecases/calculate_splits.dart';
import 'participant_avatar.dart';

class SplitParticipantTile extends StatefulWidget {
  final ExpenseSplit split;
  final SplitMode splitMode;
  final bool isEqually;
  final bool isCustomized;
  final double? customAmount;
  final double? customPercentage;
  final ValueChanged<bool?> onToggle;
  final ValueChanged<String>? onPercentageChanged;
  final ValueChanged<String>? onAmountChanged;

  const SplitParticipantTile({
    super.key,
    required this.split,
    this.splitMode = SplitMode.equal,
    this.isEqually = true,
    this.isCustomized = false,
    this.customAmount,
    this.customPercentage,
    required this.onToggle,
    this.onPercentageChanged,
    this.onAmountChanged,
  });

  @override
  State<SplitParticipantTile> createState() => _SplitParticipantTileState();
}

class _SplitParticipantTileState extends State<SplitParticipantTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant SplitParticipantTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.splitMode != widget.splitMode ||
        oldWidget.isCustomized != widget.isCustomized ||
        oldWidget.customAmount != widget.customAmount ||
        oldWidget.customPercentage != widget.customPercentage) {
      _syncController();
    }
  }

  void _syncController() {
    if (widget.splitMode == SplitMode.exact) {
      if (widget.isCustomized && widget.customAmount != null) {
        final text = widget.customAmount! % 1 == 0
            ? widget.customAmount!.toInt().toString()
            : widget.customAmount!.toStringAsFixed(2);
        if (_controller.text != text &&
            double.tryParse(_controller.text) != widget.customAmount) {
          _controller.text = text;
        }
      } else if (!widget.isCustomized && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    } else if (widget.splitMode == SplitMode.percentage) {
      if (widget.isCustomized && widget.customPercentage != null) {
        final text = widget.customPercentage! % 1 == 0
            ? widget.customPercentage!.toInt().toString()
            : widget.customPercentage!.toStringAsFixed(1);
        if (_controller.text != text &&
            double.tryParse(_controller.text) != widget.customPercentage) {
          _controller.text = text;
        }
      } else if (!widget.isCustomized && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    } else {
      if (_controller.text.isNotEmpty) {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currencySymbol = getIt<PreferenceService>().currencySymbol;

    final effectiveMode = widget.isEqually ? SplitMode.equal : widget.splitMode;
    final isSelected = widget.split.isSelected;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.isCustomized
                  ? (isLight
                      ? colorScheme.primary.withValues(alpha: 0.06)
                      : colorScheme.primary.withValues(alpha: 0.12))
                  : (isLight
                      ? colorScheme.surfaceContainerLowest
                          .withValues(alpha: 0.75)
                      : colorScheme.surfaceContainerHigh
                          .withValues(alpha: 0.35)))
              : (isLight
                  ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.30)
                  : colorScheme.surfaceContainerLow.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? (widget.isCustomized
                    ? colorScheme.primary
                        .withValues(alpha: isLight ? 0.50 : 0.60)
                    : (isLight
                        ? colorScheme.outlineVariant.withValues(alpha: 0.45)
                        : customColors.glassStroke.withValues(alpha: 0.50)))
                : (isLight
                    ? colorScheme.outlineVariant.withValues(alpha: 0.20)
                    : customColors.glassStroke.withValues(alpha: 0.20)),
            width: widget.isCustomized ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Checkbox on the left for easy toggle
            Transform.scale(
              scale: 1.05,
              child: Checkbox(
                value: isSelected,
                onChanged: widget.onToggle,
                activeColor: colorScheme.primary,
                checkColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            ),
            SizedBox(width: 4.w),

            // Participant Avatar
            ParticipantAvatar(
              name: widget.split.participantName,
              colorIndex: widget.split.participantId,
            ),
            SizedBox(width: 12.w),

            // Participant Name & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.split.participantName,
                    style: context.customTypography.bodyLarge.copyWith(
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isSelected && effectiveMode != SplitMode.equal)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        effectiveMode == SplitMode.percentage
                            ? '$currencySymbol${widget.split.splitAmount.toStringAsFixed(2)} (${(widget.split.customPercentage ?? 0).toStringAsFixed(1)}%)${widget.isCustomized ? ' (custom)' : ' • auto'}'
                            : '$currencySymbol${widget.split.splitAmount.toStringAsFixed(2)} share${widget.isCustomized ? ' (custom)' : ' (auto)'}',
                        style:
                            context.customTypography.labelMediumMono.copyWith(
                          color: widget.isCustomized
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.8),
                          fontSize: 11.sp,
                          fontWeight: widget.isCustomized
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 10.w),

            // Amount Component (Frameless direct input / badge)
            if (isSelected) ...[
              if (effectiveMode == SplitMode.equal)
                _buildEqualAmountBadge(
                  context,
                  currencySymbol,
                  widget.split.splitAmount,
                )
              else if (effectiveMode == SplitMode.exact)
                _buildExactAmountInput(
                  context,
                  currencySymbol,
                  widget.split.splitAmount,
                )
              else
                _buildPercentageInput(
                  context,
                  widget.split.customPercentage,
                  widget.split.splitAmount,
                ),
            ] else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isLight
                      ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.25)
                      : colorScheme.surfaceContainerLow.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'Excluded',
                  style: context.customTypography.labelMediumMono.copyWith(
                    color: colorScheme.outline.withValues(alpha: 0.7),
                    fontSize: 11.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEqualAmountBadge(
    BuildContext context,
    String currencySymbol,
    double amount,
  ) {
    final colorScheme = context.colorScheme;

    return Text(
      '$currencySymbol${amount.toStringAsFixed(2)}',
      style: context.customTypography.headlineMediumMonoBold.copyWith(
        color: colorScheme.primary,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildExactAmountInput(
    BuildContext context,
    String currencySymbol,
    double amount,
  ) {
    final colorScheme = context.colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 70.w, maxWidth: 120.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            currencySymbol,
            style: context.customTypography.headlineMediumMonoBold.copyWith(
              color: widget.isCustomized
                  ? colorScheme.primary
                  : colorScheme.primary.withValues(alpha: 0.75),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 2.w),
          IntrinsicWidth(
            child: TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: context.customTypography.headlineMediumMonoBold.copyWith(
                fontSize: 16.sp,
                color: widget.isCustomized
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: amount > 0 ? amount.toStringAsFixed(2) : '0.00',
                hintStyle:
                    context.customTypography.headlineMediumMonoBold.copyWith(
                  fontSize: 16.sp,
                  color: colorScheme.outline.withValues(alpha: 0.45),
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onAmountChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageInput(
    BuildContext context,
    double? customPercentage,
    double amount,
  ) {
    final colorScheme = context.colorScheme;
    final calculatedPercentage = widget.split.customPercentage ?? 0.0;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 50.w, maxWidth: 90.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          IntrinsicWidth(
            child: TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: context.customTypography.headlineMediumMonoBold.copyWith(
                fontSize: 16.sp,
                color: widget.isCustomized
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: calculatedPercentage > 0
                    ? (calculatedPercentage % 1 == 0
                        ? calculatedPercentage.toInt().toString()
                        : calculatedPercentage.toStringAsFixed(1))
                    : '0',
                hintStyle:
                    context.customTypography.headlineMediumMonoBold.copyWith(
                  fontSize: 16.sp,
                  color: colorScheme.outline.withValues(alpha: 0.45),
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onPercentageChanged,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            '%',
            style: context.customTypography.labelMediumMono.copyWith(
              color: widget.isCustomized
                  ? colorScheme.primary
                  : colorScheme.primary.withValues(alpha: 0.75),
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
