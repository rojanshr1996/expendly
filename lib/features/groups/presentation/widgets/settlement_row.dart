import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../domain/entities/event_participant.dart';
import '../../domain/entities/settlement.dart';
import 'participant_avatar.dart';

class SettlementRow extends StatelessWidget {
  final Settlement settlement;
  final EventParticipant selectedParticipant;
  final VoidCallback? onAction;

  const SettlementRow({
    super.key,
    required this.settlement,
    required this.selectedParticipant,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = BorderRadius.circular(18.r);

    final isSelectedFrom =
        settlement.fromParticipant.id == selectedParticipant.id;
    final isSelfSelected = selectedParticipant.isOwner ||
        selectedParticipant.name.toLowerCase() == 'you';

    final otherParticipant =
        isSelectedFrom ? settlement.toParticipant : settlement.fromParticipant;
    final isOtherSelf = otherParticipant.isOwner ||
        otherParticipant.name.toLowerCase() == 'you';

    // Build natural, unconfusing wording
    final String text;
    if (isSelectedFrom) {
      // Selected person is the debtor (pays money)
      if (isSelfSelected) {
        text = context.l10n.youOweText(otherParticipant.name);
      } else if (isOtherSelf) {
        text = '${selectedParticipant.name} owes you';
      } else {
        text = '${selectedParticipant.name} owes ${otherParticipant.name}';
      }
    } else {
      // Selected person is the creditor (gets back money)
      if (isSelfSelected) {
        text = context.l10n.owesYou(otherParticipant.name);
      } else if (isOtherSelf) {
        text = 'You owe ${selectedParticipant.name}';
      } else {
        text = '${otherParticipant.name} owes ${selectedParticipant.name}';
      }
    }

    // High contrast colors for light and dark themes
    final redColor = isLight ? const Color(0xFFDC2626) : AppColors.semanticRed;
    final greenColor =
        isLight ? const Color(0xFF15803D) : AppColors.semanticGreen;

    final iconColor = isSelectedFrom ? redColor : greenColor;
    final iconData = isSelectedFrom
        ? Icons.arrow_outward_rounded
        : Icons.arrow_downward_rounded;

    // Action button label determination
    final bool isUserDebtor =
        isSelfSelected ? isSelectedFrom : isOtherSelf && !isSelectedFrom;
    final actionLabel =
        isUserDebtor ? context.l10n.settleUp : context.l10n.remind;
    final actionVariant =
        isUserDebtor ? AppButtonVariant.primary : AppButtonVariant.secondary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.80),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.40),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.32),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.18),
                ],
        ),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.75)
              : customColors.glassStroke.withValues(alpha: 0.50),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.6 : 0.0),
            blurRadius: 6.r,
            spreadRadius: -1.r,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.16),
            blurRadius: 14.r,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isLight ? 0.14 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withValues(alpha: isLight ? 0.35 : 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(iconData, color: iconColor, size: 18.w),
                ),
                SizedBox(width: 10.w),
                ParticipantAvatar(
                  name: otherParticipant.name,
                  colorIndex: otherParticipant.colorIndex,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: context.customTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (settlement.reasons.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          'For ${settlement.reasons.join(', ')}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      SizedBox(height: 4.h),
                      CompactAmountText(
                        amount: settlement.amount,
                        style: context.customTypography.headlineMediumMonoBold
                            .copyWith(
                          color: iconColor,
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onAction != null && (isSelfSelected || isOtherSelf)) ...[
                  SizedBox(width: 8.w),
                  AppButton(
                    text: actionLabel,
                    width: 86.w,
                    height: 34.h,
                    textStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    onPressed: onAction!,
                    variant: actionVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
