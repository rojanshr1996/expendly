import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/glass_container.dart';

/// Reusable glass container widget for configuring an initial account's details
/// (title, icon, type label, currency symbol, and starting balance controller).
class AccountConfigCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String accountTypeLabel;
  final String currencySymbol;
  final TextEditingController amountController;
  final ValueChanged<String>? onChanged;

  const AccountConfigCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.accountTypeLabel,
    required this.currencySymbol,
    required this.amountController,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    final customTypography = context.customTypography;

    final amountStyle = (customTypography.amountDisplay).copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeights.bold,
    );

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: iconColor.withAlpha((0.15 * 255).round()),
                  border: Border.all(
                    color: iconColor.withAlpha((0.3 * 255).round()),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: iconColor,
                ),
              ),
              horizontalMarginSmall,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                        fontWeight: FontWeights.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      accountTypeLabel.toUpperCase(),
                      style:
                          (textTheme.labelSmall ?? const TextStyle()).copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalMarginSmall,

          // Starting Balance Input Field
          Text(
            l10n.startingBalance,
            style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeights.medium,
            ),
          ),
          verticalMarginXXSmall,
          AppTextField(
            controller: amountController,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: amountStyle,
            hintText: '0.00',
            hintStyle: amountStyle.copyWith(
              color:
                  colorScheme.onSurfaceVariant.withAlpha((0.5 * 255).round()),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Text(
                currencySymbol,
                style: amountStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
