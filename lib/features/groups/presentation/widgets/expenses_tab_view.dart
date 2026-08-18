import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/widgets/animated_entrance_item.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/group_expense.dart';
import '../../domain/entities/sharing_event.dart';

class ExpensesTabView extends StatelessWidget {
  final List<GroupExpense> expenses;
  final SharingEvent event;
  final VoidCallback? onExpenseAdded;
  final void Function(int expenseId)? onDeleteExpense;

  const ExpensesTabView({
    super.key,
    required this.expenses,
    required this.event,
    this.onExpenseAdded,
    this.onDeleteExpense,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (expenses.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding:
              EdgeInsets.only(left: 20.w, right: 20.w, top: 68.h, bottom: 24.h),
          child: GlassContainer(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: colorScheme.primary,
                    size: 28.w,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  context.l10n.noExpensesYet,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Log your first shared expense to start splitting costs.',
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateFormat = DateFormat('MMM d, yyyy');

    // Group expenses by date string
    final Map<String, List<GroupExpense>> grouped = {};
    for (final exp in expenses) {
      final expDate = DateTime(exp.date.year, exp.date.month, exp.date.day);
      final diff = today.difference(expDate).inDays;
      String header;
      if (diff == 0) {
        header = 'TODAY';
      } else if (diff == 1) {
        header = 'YESTERDAY';
      } else {
        header = dateFormat.format(exp.date).toUpperCase();
      }
      grouped.putIfAbsent(header, () => []).add(exp);
    }

    int itemGlobalIndex = 0;
    final br = BorderRadius.circular(18.r);

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 96.h),
      itemCount: grouped.keys.length,
      itemBuilder: (context, groupIndex) {
        final header = grouped.keys.elementAt(groupIndex);
        final groupExpenses = grouped[header]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: groupIndex == 0 ? 0 : 16.h, bottom: 8.h),
              child: Text(
                header,
                style: context.customTypography.labelMediumMono.copyWith(
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...groupExpenses.map((expense) {
              final currentIndex = itemGlobalIndex++;

              return AnimatedEntranceItem(
                index: currentIndex,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
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
                          color: Colors.white
                              .withValues(alpha: isLight ? 0.6 : 0.0),
                          blurRadius: 6.r,
                          spreadRadius: -1.r,
                          offset: const Offset(0, -1),
                        ),
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isLight ? 0.04 : 0.16),
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: br,
                            onTap: () async {
                              final result = await context.router.push(
                                ExpenseDetailsRoute(
                                  expense: expense,
                                  event: event,
                                  onDeleteExpense: onDeleteExpense,
                                ),
                              );
                              if (result == true) {
                                onExpenseAdded?.call();
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 12.h),
                              child: Row(
                                children: [
                                  // Avatar circle with liquid glass styling
                                  Container(
                                    width: 42.w,
                                    height: 42.w,
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment.topLeft,
                                        radius: 1.2,
                                        colors: isLight
                                            ? [
                                                colorScheme.primary
                                                    .withValues(alpha: 0.16),
                                                colorScheme.primary
                                                    .withValues(alpha: 0.08),
                                              ]
                                            : [
                                                colorScheme.primary
                                                    .withValues(alpha: 0.28),
                                                colorScheme.primary
                                                    .withValues(alpha: 0.14),
                                              ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isLight
                                            ? Colors.white
                                                .withValues(alpha: 0.8)
                                            : customColors.glassStroke
                                                .withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        expense.paidByName.isNotEmpty
                                            ? expense.paidByName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: customTypography
                                            .headlineMediumMonoBold
                                            .copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),

                                  // Expense Title & Paid By
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.title,
                                          style: context
                                              .customTypography.bodyLargeBold
                                              .copyWith(
                                            color: colorScheme.onSurface,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        Row(
                                          children: [
                                            Text(
                                              context.l10n
                                                  .paidBy(expense.paidByName),
                                              style: context
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Amount & Shares
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CompactAmountText(
                                        amount: expense.amount,
                                        style: customTypography
                                            .headlineMediumMonoBold
                                            .copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        context.l10n
                                            .nShares(expense.splits.length),
                                        style: customTypography.labelMediumMono
                                            .copyWith(
                                          color: colorScheme.outline,
                                          fontSize: 10.sp,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 4.w),

                                  // Delete Action Button
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18.w,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    padding: EdgeInsets.all(6.w),
                                    constraints: const BoxConstraints(),
                                    onPressed: () =>
                                        onDeleteExpense?.call(expense.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
