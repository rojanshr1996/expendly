import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_entrance_item.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/status_components.dart';
import '../../domain/entities/event_participant.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/entities/sharing_event.dart';
import '../cubit/event_detail_cubit.dart';
import 'participant_avatar.dart';
import 'settle_up_sheet.dart';
import 'settlement_row.dart';

class BalancesView extends StatelessWidget {
  final List<Settlement> settlements;
  final List<EventParticipant> participants;
  final SharingEvent event;

  final ValueNotifier<int> _selectedUserId = ValueNotifier<int>(-1);

  BalancesView({
    super.key,
    required this.settlements,
    required this.participants,
    required this.event,
  }) {
    if (participants.isNotEmpty) {
      final owner = participants.firstWhere((p) => p.isOwner,
          orElse: () => participants.first);
      _selectedUserId.value = owner.id;
    }
  }

  void _remind(BuildContext context, Settlement settlement) async {
    final to = settlement.fromParticipant.email;
    if (to != null && to.isNotEmpty) {
      final currencySymbol = getIt<PreferenceService>().currencySymbol;
      final subject =
          Uri.encodeComponent('Reminder: Settle up for ${event.name}');
      final body = Uri.encodeComponent(
        'Hi ${settlement.fromParticipant.name},\n\nJust a quick reminder to settle up $currencySymbol${settlement.amount.toStringAsFixed(2)} for ${event.name}.\n\nThanks!',
      );
      final url = Uri.parse('mailto:$to?subject=$subject&body=$body');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else if (context.mounted) {
        StatusComponents.showToast(context,
            message: 'Could not open email client', isError: true);
      }
    } else if (context.mounted) {
      StatusComponents.showToast(context,
          message: 'No email address for ${settlement.fromParticipant.name}',
          isError: true);
    }
  }

  void _settleUp(BuildContext context, Settlement settlement) {
    SettleUpSheet.show(
      context,
      settlement: settlement,
      onConfirm: (amount, note) async {
        await context.read<EventDetailCubit>().recordSettlement(
              fromParticipantId: settlement.fromParticipant.id,
              toParticipantId: settlement.toParticipant.id,
              amount: amount,
              note: note,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currencySymbol = getIt<PreferenceService>().currencySymbol;

    final redColor = isLight ? const Color(0xFFDC2626) : AppColors.semanticRed;
    final greenColor =
        isLight ? const Color(0xFF15803D) : AppColors.semanticGreen;

    // Compute overall group balances for all participants
    final Map<int, double> groupBalances = {
      for (var p in participants) p.id: 0.0,
    };
    for (var s in settlements) {
      groupBalances[s.toParticipant.id] =
          (groupBalances[s.toParticipant.id] ?? 0.0) + s.amount;
      groupBalances[s.fromParticipant.id] =
          (groupBalances[s.fromParticipant.id] ?? 0.0) - s.amount;
    }

    if (settlements.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: GlassContainer(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: greenColor.withValues(alpha: isLight ? 0.14 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: greenColor.withValues(alpha: isLight ? 0.35 : 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: greenColor,
                    size: 28.w,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'All Settled Up',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                Text(
                  'No pending balances or settlements for this event.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final br = BorderRadius.circular(18.r);

    return ValueListenableBuilder<int>(
      valueListenable: _selectedUserId,
      builder: (context, selectedId, child) {
        final selectedParticipant = participants.firstWhere(
          (p) => p.id == selectedId,
          orElse: () => participants.first,
        );
        final isSelf = selectedParticipant.isOwner ||
            selectedParticipant.name.toLowerCase() == 'you';

        final filteredSettlements = settlements
            .where((s) =>
                s.fromParticipant.id == selectedId ||
                s.toParticipant.id == selectedId)
            .toList();

        final netPosition = groupBalances[selectedId] ?? 0.0;

        final String netPositionText;
        if (isSelf) {
          netPositionText = netPosition >= 0
              ? context.l10n.youAreOwed(
                  '$currencySymbol${netPosition.toStringAsFixed(2)}')
              : context.l10n.youOwe(
                  '$currencySymbol${(-netPosition).toStringAsFixed(2)}');
        } else {
          netPositionText = netPosition >= 0
              ? '${selectedParticipant.name} is owed $currencySymbol${netPosition.toStringAsFixed(2)}'
              : '${selectedParticipant.name} owes $currencySymbol${(-netPosition).toStringAsFixed(2)}';
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(0, 16.h, 0, 32.h),
          children: [
            // User selector
            SizedBox(
              height: 76.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: participants.length,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemBuilder: (context, index) {
                  final p = participants[index];
                  final isSelected = p.id == selectedId;
                  final bal = groupBalances[p.id] ?? 0.0;

                  return GestureDetector(
                    onTap: () => _selectedUserId.value = p.id,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                padding: EdgeInsets.all(2.w),
                                child: ParticipantAvatar(
                                    name: p.name, colorIndex: p.colorIndex),
                              ),
                              if (bal.abs() > 0.01)
                                Positioned(
                                  right: -2.w,
                                  bottom: -2.h,
                                  child: Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: BoxDecoration(
                                      color: bal > 0 ? greenColor : redColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.surface,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            p.name,
                            style: context.textTheme.labelSmall!.copyWith(
                              color: isSelected
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Net position card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: br,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isLight
                        ? [
                            colorScheme.surfaceContainerLowest
                                .withValues(alpha: 0.80),
                            colorScheme.surfaceContainerHigh
                                .withValues(alpha: 0.40),
                          ]
                        : [
                            colorScheme.surfaceContainerHigh
                                .withValues(alpha: 0.32),
                            colorScheme.surfaceContainerLow
                                .withValues(alpha: 0.18),
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
                      color:
                          Colors.white.withValues(alpha: isLight ? 0.6 : 0.0),
                      blurRadius: 6.r,
                      spreadRadius: -1.r,
                      offset: const Offset(0, -1),
                    ),
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isLight ? 0.04 : 0.16),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        children: [
                          Text(
                            context.l10n.netPosition,
                            style: context.customTypography.labelMediumMono,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            netPositionText,
                            style: context
                                .customTypography.headlineMediumMonoBold
                                .copyWith(
                              color: netPosition >= 0 ? greenColor : redColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Settlements list or participant empty state
            if (filteredSettlements.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: GlassContainer(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: greenColor.withValues(
                              alpha: isLight ? 0.14 : 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: greenColor.withValues(
                                alpha: isLight ? 0.35 : 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: greenColor,
                          size: 28.w,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'All Settled Up',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        isSelf
                            ? 'No pending balances or settlements for you.'
                            : 'No pending balances or settlements for ${selectedParticipant.name}.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: filteredSettlements.asMap().entries.map((entry) {
                    final index = entry.key;
                    final s = entry.value;

                    return AnimatedEntranceItem(
                      index: index,
                      child: SettlementRow(
                        settlement: s,
                        selectedParticipant: selectedParticipant,
                        onAction: () {
                          final isUserDebtor =
                              s.fromParticipant.id == selectedId;
                          if (isUserDebtor) {
                            _settleUp(context, s);
                          } else {
                            _remind(context, s);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            SizedBox(height: 20.h),

            // All Members Balance Overview Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GlassContainer(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GROUP BALANCES OVERVIEW',
                      style: context.customTypography.labelMediumMono.copyWith(
                        color: colorScheme.outline,
                        letterSpacing: 1.2,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...participants.map((p) {
                      final bal = groupBalances[p.id] ?? 0.0;
                      final isSelected = p.id == selectedId;

                      final String balanceBadge;
                      final Color badgeColor;
                      if (bal > 0.01) {
                        balanceBadge =
                            'Gets back $currencySymbol${bal.toStringAsFixed(2)}';
                        badgeColor = greenColor;
                      } else if (bal < -0.01) {
                        balanceBadge =
                            'Owes $currencySymbol${(-bal).toStringAsFixed(2)}';
                        badgeColor = redColor;
                      } else {
                        balanceBadge = 'Settled';
                        badgeColor = colorScheme.outline;
                      }

                      return InkWell(
                        onTap: () => _selectedUserId.value = p.id,
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 8.h),
                          margin: EdgeInsets.only(bottom: 6.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                    .withValues(alpha: isLight ? 0.08 : 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              ParticipantAvatar(
                                name: p.name,
                                colorIndex: p.colorIndex,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  p.isOwner ? '${p.name} (You)' : p.name,
                                  style: context.customTypography.bodyMedium
                                      .copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                balanceBadge,
                                style: context
                                    .customTypography.headlineMediumMonoBold
                                    .copyWith(
                                  color: badgeColor,
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
