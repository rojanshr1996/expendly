import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../domain/entities/expense_split.dart';
import '../../domain/usecases/calculate_splits.dart';
import 'participant_avatar.dart';

class SplitParticipantTile extends StatelessWidget {
  final ExpenseSplit split;
  final SplitMode splitMode;
  final bool isEqually;
  final ValueChanged<bool?> onToggle;
  final ValueChanged<String>? onPercentageChanged;
  final ValueChanged<String>? onAmountChanged;
  final TextEditingController? customValueController;

  const SplitParticipantTile({
    super.key,
    required this.split,
    this.splitMode = SplitMode.equal,
    this.isEqually = true,
    required this.onToggle,
    this.onPercentageChanged,
    this.onAmountChanged,
    this.customValueController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currencySymbol = getIt<PreferenceService>().currencySymbol;

    final effectiveMode = isEqually ? SplitMode.equal : splitMode;
    final isSelected = split.isSelected;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isLight
                  ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.75)
                  : colorScheme.surfaceContainerHigh.withValues(alpha: 0.35))
              : (isLight
                  ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.30)
                  : colorScheme.surfaceContainerLow.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? (isLight
                    ? colorScheme.outlineVariant.withValues(alpha: 0.45)
                    : customColors.glassStroke.withValues(alpha: 0.50))
                : (isLight
                    ? colorScheme.outlineVariant.withValues(alpha: 0.20)
                    : customColors.glassStroke.withValues(alpha: 0.20)),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox on the left for easy toggle
            Transform.scale(
              scale: 1.05,
              child: Checkbox(
                value: isSelected,
                onChanged: onToggle,
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
              name: split.participantName,
              colorIndex: split.participantId,
            ),
            SizedBox(width: 12.w),

            // Participant Name & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    split.participantName,
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
                        '$currencySymbol${split.splitAmount.toStringAsFixed(2)} share',
                        style:
                            context.customTypography.labelMediumMono.copyWith(
                          color: colorScheme.primary.withValues(alpha: 0.85),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 8.w),

            // Amount Component (Liquid Glass Aesthetic)
            if (isSelected) ...[
              if (effectiveMode == SplitMode.equal)
                _buildEqualAmountBadge(
                  context,
                  currencySymbol,
                  split.splitAmount,
                  isLight,
                )
              else if (effectiveMode == SplitMode.exact)
                _buildExactAmountInput(
                  context,
                  currencySymbol,
                  split.splitAmount,
                  isLight,
                )
              else
                _buildPercentageInput(
                  context,
                  split.customPercentage,
                  split.splitAmount,
                  isLight,
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
    bool isLight,
  ) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest,
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLight
              ? colorScheme.outlineVariant.withValues(alpha: 0.5)
              : customColors.glassStroke.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.03 : 0.10),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$currencySymbol${amount.toStringAsFixed(2)}',
        style: context.customTypography.headlineMediumMonoBold.copyWith(
          color: colorScheme.primary,
          fontSize: 13.5.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExactAmountInput(
    BuildContext context,
    String currencySymbol,
    double amount,
    bool isLight,
  ) {
    final colorScheme = context.colorScheme;

    return Container(
      width: 104.w,
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: isLight
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLight
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.primary.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: isLight ? 0.04 : 0.12),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            currencySymbol,
            style: context.customTypography.headlineMediumMonoBold.copyWith(
              color: colorScheme.primary,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: TextField(
              controller: customValueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: context.customTypography.headlineMediumMonoBold.copyWith(
                fontSize: 13.5.sp,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                hintText: amount > 0 ? amount.toStringAsFixed(2) : '0.00',
                hintStyle:
                    context.customTypography.headlineMediumMonoBold.copyWith(
                  fontSize: 13.sp,
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onAmountChanged,
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
    bool isLight,
  ) {
    final colorScheme = context.colorScheme;

    return Container(
      width: 84.w,
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: isLight
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLight
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.primary.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: isLight ? 0.04 : 0.12),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: customValueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: context.customTypography.headlineMediumMonoBold.copyWith(
                fontSize: 13.5.sp,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                hintText: customPercentage != null
                    ? customPercentage.toStringAsFixed(0)
                    : (amount > 0 ? (amount).toStringAsFixed(0) : '0'),
                hintStyle:
                    context.customTypography.headlineMediumMonoBold.copyWith(
                  fontSize: 13.sp,
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onPercentageChanged,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            '%',
            style: context.customTypography.labelMediumMono.copyWith(
              color: colorScheme.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
