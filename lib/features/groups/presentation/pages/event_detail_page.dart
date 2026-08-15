import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/status_components.dart';
import '../../domain/entities/sharing_event.dart';
import '../cubit/event_detail_cubit.dart';
import '../cubit/event_detail_state.dart';
import '../cubit/groups_cubit.dart';
import '../widgets/balances_tab_view.dart';
import '../widgets/event_detail_shimmer.dart';
import '../widgets/expenses_tab_view.dart';
import '../widgets/participant_avatar_row.dart';
import '../widgets/status_badge.dart';

@RoutePage()
class EventDetailPage extends StatefulWidget {
  final int eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final EventDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = getIt<EventDetailCubit>()..loadEventDetail(widget.eventId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _confirmDeleteEvent(BuildContext context, SharingEvent event) async {
    final confirmed = await StatusComponents.showConfirmationBottomSheet(
      context,
      title: context.l10n.deleteEventConfirmTitle,
      message: context.l10n.deleteEventConfirmMessage,
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      await getIt<GroupsCubit>().deleteEvent(event.id);
      if (context.mounted) {
        StatusComponents.showToast(
          context,
          message: context.l10n.eventDeletedSuccess,
        );
        context.router.popForced();
      }
    }
  }

  void _confirmDeleteExpense(BuildContext context, int expenseId) async {
    final confirmed = await StatusComponents.showConfirmationBottomSheet(
      context,
      title: context.l10n.deleteExpenseConfirmTitle,
      message: context.l10n.deleteExpenseConfirmMessage,
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true) {
      _cubit.deleteExpense(expenseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + kToolbarHeight;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        extendBodyBehindAppBar: true,
        appBar: LiquidGlassAppBar(
          onLeadingPressed: () => context.router.popForced(),
          title: BlocBuilder<EventDetailCubit, EventDetailState>(
            builder: (context, state) {
              if (state is EventDetailLoaded) {
                return Text(
                  state.event.name,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          actions: [
            BlocBuilder<EventDetailCubit, EventDetailState>(
              builder: (context, state) {
                if (state is EventDetailLoaded) {
                  return PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded,
                        color: colorScheme.onSurface),
                    color: colorScheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: customColors.glassStroke),
                    ),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await context.router.push(
                          NewEventRoute(event: state.event),
                        );
                        _cubit.loadEventDetail(widget.eventId);
                      } else if (value == 'export') {
                        context.router.push(
                          ExportSettleRoute(eventId: state.event.id),
                        );
                      } else if (value == 'settle') {
                        _cubit.markEventSettled();
                      } else if (value == 'delete') {
                        _confirmDeleteEvent(context, state.event);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 18, color: colorScheme.onSurface),
                            SizedBox(width: 8.w),
                            Text(context.l10n.editEvent,
                                style: TextStyle(color: colorScheme.onSurface)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.ios_share_outlined,
                                size: 18, color: colorScheme.onSurface),
                            SizedBox(width: 8.w),
                            Text(context.l10n.exportAndSettle,
                                style: TextStyle(color: colorScheme.onSurface)),
                          ],
                        ),
                      ),
                      if (state.event.status != 'settled')
                        PopupMenuItem(
                          value: 'settle',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 18, color: colorScheme.onSurface),
                              SizedBox(width: 8.w),
                              Text(context.l10n.settleUp,
                                  style:
                                      TextStyle(color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 18, color: AppColors.semanticRed),
                            SizedBox(width: 8.w),
                            const Text(
                              'Delete Event',
                              style: TextStyle(color: AppColors.semanticRed),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            if (_tabController.index != 0) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<EventDetailCubit, EventDetailState>(
              builder: (context, state) {
                if (state is EventDetailLoaded) {
                  return FloatingActionButton.extended(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 3,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      context.l10n.addExpense,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final res = await context.router.push(
                        AddExpenseRoute(
                          eventId: state.event.id,
                          participants: state.event.participants,
                        ),
                      );
                      if (res == true) {
                        _cubit.loadEventDetail(widget.eventId);
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
        body: BlocBuilder<EventDetailCubit, EventDetailState>(
          builder: (context, state) {
            if (state is EventDetailLoading || state is EventDetailInitial) {
              return Padding(
                padding: EdgeInsets.only(top: headerPaddingTop),
                child: const EventDetailShimmer(),
              );
            }

            if (state is EventDetailError) {
              return Padding(
                padding: EdgeInsets.only(top: headerPaddingTop),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.semanticRed, size: 48.w),
                      SizedBox(height: 16.h),
                      Text(
                        context.l10n.operationFailed,
                        style: context.customTypography.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AppButton(
                        text: 'Retry',
                        width: 120.w,
                        onPressed: () => _cubit.loadEventDetail(widget.eventId),
                        variant: AppButtonVariant.outlined,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is EventDetailLoaded) {
              final event = state.event;

              return Padding(
                padding: EdgeInsets.only(top: headerPaddingTop),
                child: Column(
                  children: [
                    // Event Summary Card
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: _ReportsLiquidGlassCard(
                        borderRadius: BorderRadius.circular(18.r),
                        padding: EdgeInsets.all(18.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.totalSpend,
                                      style: context
                                          .customTypography.labelMediumMono,
                                    ),
                                    SizedBox(height: 4.h),
                                    CompactAmountText(
                                      amount: event.totalSpent,
                                      style: context.customTypography
                                          .headlineMediumMonoBold
                                          .copyWith(color: colorScheme.primary),
                                    ),
                                  ],
                                ),
                                StatusBadge(status: event.status),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Divider(
                              color: customColors.glassStroke,
                              height: 1,
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParticipantAvatarRow(
                                    participants: event.participants),
                                Text(
                                  '${event.participants.length} ${context.l10n.members}',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Pinned Liquid Glass Tab Bar (identical to RefinedReportsPage)
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        final tabs = [
                          {'index': 0, 'label': context.l10n.expenses},
                          {'index': 1, 'label': context.l10n.balances},
                        ];

                        return _ReportsLiquidGlassCard(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 6.h),
                          borderRadius: BorderRadius.circular(14.r),
                          padding: EdgeInsets.all(4.w),
                          child: Row(
                            children: tabs.map((t) {
                              final tabIndex = t['index'] as int;
                              final tabLabel = t['label'] as String;
                              final isSelected =
                                  _tabController.index == tabIndex;

                              return Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 2.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      _tabController.animateTo(tabIndex);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 8.r,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        tabLabel,
                                        textAlign: TextAlign.center,
                                        style: context
                                            .customTypography.labelMediumMono
                                            .copyWith(
                                          color: isSelected
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurface,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Expenses Tab
                          ExpensesTabView(
                            expenses: state.expenses,
                            event: event,
                            onExpenseAdded: () =>
                                _cubit.loadEventDetail(widget.eventId),
                            onDeleteExpense: (expenseId) =>
                                _confirmDeleteExpense(context, expenseId),
                          ),

                          // Balances Tab
                          BalancesTabView(
                            settlements: state.settlements,
                            participants: event.participants,
                            event: event,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ReportsLiquidGlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _ReportsLiquidGlassCard({
    required this.child,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = borderRadius ?? BorderRadius.circular(16.r);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.20),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.25),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.15),
                ],
        ),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.50)
              : customColors.glassStroke.withValues(alpha: 0.40),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.5 : 0.0),
            blurRadius: 6.r,
            spreadRadius: -1.r,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.18),
            blurRadius: 12.r,
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
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
