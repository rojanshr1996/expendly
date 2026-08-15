import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/status_components.dart';
import '../../domain/entities/group_expense.dart';
import '../../domain/entities/sharing_event.dart';
import '../../domain/repositories/groups_repository.dart';
import '../widgets/status_badge.dart';

@RoutePage()
class ExpenseDetailsPage extends StatelessWidget {
  final GroupExpense expense;
  final SharingEvent event;
  final void Function(int expenseId)? onDeleteExpense;

  const ExpenseDetailsPage({
    super.key,
    required this.expense,
    required this.event,
    this.onDeleteExpense,
  });

  Future<void> _confirmAndDelete(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await StatusComponents.showConfirmationBottomSheet(
      context,
      title: l10n.deleteExpenseConfirmTitle,
      message: l10n.deleteExpenseConfirmMessage,
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        if (onDeleteExpense != null) {
          onDeleteExpense!(expense.id);
        } else if (getIt.isRegistered<GroupsRepository>()) {
          await getIt<GroupsRepository>().deleteExpense(expense.id);
        }

        if (context.mounted) {
          StatusComponents.showToast(
            context,
            message: l10n.expenseDeletedSuccess,
            isSuccess: true,
          );
          context.router.maybePop(true);
        }
      } catch (e) {
        if (context.mounted) {
          StatusComponents.showToast(
            context,
            message: l10n.operationFailed,
            isSuccess: false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;
    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + kToolbarHeight;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: LiquidGlassAppBar(
        titleText: l10n.expenseDetails,
        onLeadingPressed: () => context.router.maybePop(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.customColors.semanticRed,
            ),
            tooltip: l10n.deleteExpense,
            onPressed: () => _confirmAndDelete(context),
          ),
        ],
      ),
      bottomNavigationBar: _LiquidGlassBottomBar(
        child: _DeleteExpenseButton(
          onDeletePressed: () => _confirmAndDelete(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: headerPaddingTop,
          bottom: 90.h + MediaQuery.of(context).viewPadding.bottom,
        ),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                verticalMarginMedium,

                // Hero Header Card (Delay 0ms)
                _StaggeredEntrance(
                  delayMs: 0,
                  child: _HeroExpenseCard(
                    expense: expense,
                  ),
                ),
                verticalMarginMedium,

                // Event Context Card (Delay 80ms)
                _StaggeredEntrance(
                  delayMs: 80,
                  child: _EventContextCard(
                    event: event,
                    expenseAmount: expense.amount,
                  ),
                ),
                verticalMarginMedium,

                // Split Breakdown Section (Delay 160ms)
                _StaggeredEntrance(
                  delayMs: 160,
                  child: _SplitBreakdownCard(
                    expense: expense,
                  ),
                ),
                verticalMarginMedium,

                // Metadata Details Section (Delay 240ms)
                _StaggeredEntrance(
                  delayMs: 240,
                  child: _ExpenseMetadataCard(
                    expense: expense,
                  ),
                ),
                verticalMarginLarge,
              ],
            ).defaultCanvasPadding(),
          ),
        ),
      ),
    );
  }
}

class _HeroExpenseCard extends StatelessWidget {
  final GroupExpense expense;

  const _HeroExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        children: [
          // Payer Avatar with liquid glass styling (Scale & Fade)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.65 + (value * 0.35),
                  child: child,
                ),
              );
            },
            child: Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: isLight
                      ? [
                          colorScheme.primary.withValues(alpha: 0.20),
                          colorScheme.primary.withValues(alpha: 0.08),
                        ]
                      : [
                          colorScheme.primary.withValues(alpha: 0.35),
                          colorScheme.primary.withValues(alpha: 0.15),
                        ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLight
                      ? Colors.white.withValues(alpha: 0.8)
                      : customColors.glassStroke,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary
                        .withValues(alpha: isLight ? 0.12 : 0.25),
                    blurRadius: 16.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  expense.paidByName.isNotEmpty
                      ? expense.paidByName[0].toUpperCase()
                      : '?',
                  style: customTypography.headlineLargeMonoBold.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                  ),
                ),
              ),
            ),
          ),
          verticalMarginSmall,

          // Expense Title
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1.0 - value) * -8.h),
                  child: child,
                ),
              );
            },
            child: Text(
              expense.title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          verticalMarginXXSmall,

          // Paid By Tag Chip
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + (value * 0.15),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 14.sp,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    context.l10n.paidBy(expense.paidByName),
                    style: customTypography.labelMediumMono.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          verticalMarginMedium,

          // Monetary Amount Display
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.88 + (value * 0.12),
                  child: child,
                ),
              );
            },
            child: CompactAmountText(
              amount: expense.amount,
              compact: false,
              style: customTypography.headlineLargeMonoBold.copyWith(
                color: colorScheme.primary,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          verticalMarginSmall,

          // Formatted Date Subtitle
          Text(
            DateFormat.yMMMMd(Localizations.localeOf(context).languageCode)
                .add_jm()
                .format(expense.date),
            style: customTypography.labelMediumMono.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventContextCard extends StatelessWidget {
  final SharingEvent event;
  final double expenseAmount;

  const _EventContextCard({
    required this.event,
    required this.expenseAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;

    final pctOfTotal = event.totalSpent > 0
        ? ((expenseAmount / event.totalSpent) * 100).clamp(0.0, 100.0)
        : 100.0;

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: colorScheme.secondary,
                  size: 20.sp,
                ),
              ),
              horizontalMarginSmall,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EVENT / GROUP',
                      style: customTypography.labelMediumMono.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10.sp,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      event.name,
                      style: context.customTypography.bodyLargeBold.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: event.status),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: customColors.glassStroke),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group Total Spend',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              CompactAmountText(
                amount: event.totalSpent,
                style: customTypography.labelMediumMono.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Share of Group Total',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${pctOfTotal.toStringAsFixed(1)}%',
                style: customTypography.labelMediumMono.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitBreakdownCard extends StatelessWidget {
  final GroupExpense expense;

  const _SplitBreakdownCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final l10n = context.l10n;
    // final isLight = Theme.of(context).brightness == Brightness.light;

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.splitBreakdown,
                style: customTypography.labelMediumMono.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
              Text(
                l10n.nShares(expense.splits.length),
                style: customTypography.labelMediumMono.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...expense.splits.asMap().entries.map((entry) {
            final index = entry.key;
            final split = entry.value;
            final isPayer = split.participantId == expense.paidByParticipantId;
            final isLast = index == expense.splits.length - 1;

            final pct = split.customPercentage ??
                (expense.splits.isNotEmpty
                    ? 100.0 / expense.splits.length
                    : 0.0);

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      // Avatar circle
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPayer
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHigh
                                  .withValues(alpha: 0.6),
                          border: Border.all(
                            color: isPayer
                                ? colorScheme.primary.withValues(alpha: 0.5)
                                : customColors.glassStroke,
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            split.participantName.isNotEmpty
                                ? split.participantName[0].toUpperCase()
                                : '?',
                            style: customTypography.labelMediumMono.copyWith(
                              color: isPayer
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Member Name & Status Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    split.participantName,
                                    style: context
                                        .customTypography.bodyLargeBold
                                        .copyWith(
                                      color: colorScheme.onSurface,
                                      fontSize: 13.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isPayer) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 1.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'PAYER',
                                      style: customTypography.labelMediumMono
                                          .copyWith(
                                        color: colorScheme.primary,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              isPayer
                                  ? 'Paid full • Gets back ${(expense.amount - split.splitAmount).toStringAsFixed(2)}'
                                  : 'Owes ${(split.splitAmount).toStringAsFixed(2)}',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: isPayer
                                    ? customColors.semanticGreen
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Share Amount & Percentage
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CompactAmountText(
                            amount: split.splitAmount,
                            style: customTypography.headlineMediumMonoBold
                                .copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: customTypography.labelMediumMono.copyWith(
                              color: colorScheme.outline,
                              fontSize: 10.sp,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, color: customColors.glassStroke),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ExpenseMetadataCard extends StatelessWidget {
  final GroupExpense expense;

  const _ExpenseMetadataCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final formattedCreatedAt =
        DateFormat.yMMMMd(locale).add_jm().format(expense.createdAt);

    final rows = <Widget>[
      _ExpenseDetailRow(
        icon: Icons.calendar_today_rounded,
        label: l10n.dateAndTimeLabel,
        value: DateFormat.yMMMMd(locale).add_jm().format(expense.date),
        isMonospace: true,
      ),
      _ExpenseDetailRow(
        icon: Icons.tag_rounded,
        label: 'Expense ID',
        value: '#${expense.id}',
        isMonospace: true,
      ),
      _ExpenseDetailRow(
        icon: Icons.access_time_rounded,
        label: 'Recorded On',
        value: formattedCreatedAt,
        isMonospace: true,
      ),
    ];

    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
        children
            .add(Divider(height: 22, color: context.customColors.glassStroke));
      }
      children.add(rows[i]);
    }

    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: children,
      ),
    );
  }
}

class _ExpenseDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  const _ExpenseDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    return Row(
      children: [
        Icon(
          icon,
          size: 18.r,
          color: colorScheme.outline,
        ),
        horizontalMarginSmall,
        Text(
          label,
          style: customTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13.sp,
          ),
        ),
        horizontalMarginSmall,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: isMonospace
                ? customTypography.labelMediumMono.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 12.sp,
                  )
                : customTypography.bodyLargeBold.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 13.sp,
                  ),
          ),
        ),
      ],
    );
  }
}

class _LiquidGlassBottomBar extends StatelessWidget {
  final Widget child;

  const _LiquidGlassBottomBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: 16.h + MediaQuery.of(context).viewPadding.bottom,
          ),
          decoration: BoxDecoration(
            color: isLight
                ? colorScheme.surface.withValues(alpha: 0.85)
                : colorScheme.surface.withValues(alpha: 0.75),
            border: Border(
              top: BorderSide(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.8)
                    : customColors.glassStroke.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DeleteExpenseButton extends StatelessWidget {
  final VoidCallback onDeletePressed;

  const _DeleteExpenseButton({required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final customTypography = context.customTypography;
    final customColors = context.customColors;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onDeletePressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: customColors.semanticRed,
          side: BorderSide(
            color: customColors.semanticRed.withValues(alpha: 0.7),
            width: 1.2,
          ),
          backgroundColor: customColors.semanticRed.withValues(alpha: 0.08),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        icon: Icon(Icons.delete_outline_rounded, size: 20.r),
        label: Text(
          l10n.deleteExpense,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: customTypography.bodyLargeBold.copyWith(
            color: customColors.semanticRed,
          ),
        ),
      ),
    );
  }
}

class _StaggeredEntrance extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _StaggeredEntrance({
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * 16.h),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
