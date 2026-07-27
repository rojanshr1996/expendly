import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';

/// Weekly Cash Flow Summary Section displaying responsive daily velocity bars.
class DashboardCashFlowChart extends StatelessWidget {
  const DashboardCashFlowChart({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final heights = [0.35, 0.45, 0.25, 0.85, 0.55, 0.90, 0.65];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cash Flow',
              style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeights.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                _buildLegendItem(AppColors.semanticGreen, 'Income', textTheme),
                horizontalMarginSmall,
                _buildLegendItem(AppColors.semanticRed, 'Expenses', textTheme),
              ],
            ),
          ],
        ),
        verticalMarginSmall,
        GlassContainer(
          height: 160.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final isPeak = index == 3 || index == 5;
              final factor = heights[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: factor,
                            widthFactor: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(6.r)),
                                color: isPeak
                                    ? colorScheme.primary
                                    : colorScheme.primary
                                        .withAlpha((0.25 * 255).round()),
                                boxShadow: isPeak
                                    ? [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withAlpha((0.3 * 255).round()),
                                          blurRadius: 8.r,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                        ),
                      ),
                      verticalMarginXXSmall,
                      Text(
                        days[index],
                        style: customTypography.labelMediumMono.copyWith(
                          fontSize: 10.sp,
                          color: isPeak
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isPeak ? FontWeights.bold : FontWeights.regular,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        horizontalMarginXXSmall,
        Text(
          label,
          style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
