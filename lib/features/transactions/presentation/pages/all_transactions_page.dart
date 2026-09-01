import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/tablet_spacing.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/animated_empty_state_hero.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/master_detail_layout.dart';
import '../../../../core/widgets/status_components.dart';
import '../../domain/entities/transaction_item.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';
import '../widgets/all_transactions_shimmer.dart';
import '../widgets/transaction_detail_panel.dart';
import '../widgets/transaction_master_list.dart';

class AllTransactionsPage extends StatefulWidget {
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const AllTransactionsPage({super.key, this.isPrivacyModeNotifier});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<String> _viewModeNotifier;
  late final ValueNotifier<DateTime> _selectedMonthNotifier;
  late final ValueNotifier<DateTime> _selectedDateNotifier;

  int _slideDirection = 0;

  late final AnimationController _pageAnimationController;
  late final Animation<double> _headerFadeAnimation;
  late final Animation<Offset> _headerSlideAnimation;
  late final TransactionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TransactionCubit>();
    if (_cubit.state is! TransactionLoaded) {
      _cubit.loadTransactions();
    }
    final prefs = getIt<PreferenceService>();
    final now = DateTime.now();

    final savedMode = prefs.activityViewMode;
    final initialMode =
        (savedMode.isEmpty || savedMode == 'list') ? 'daily' : savedMode;
    _viewModeNotifier = ValueNotifier<String>(initialMode);
    _selectedMonthNotifier =
        ValueNotifier<DateTime>(DateTime(now.year, now.month));
    _selectedDateNotifier = ValueNotifier<DateTime>(now);

    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFadeAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOutCubic,
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(_headerFadeAnimation);

    _pageAnimationController.forward();
  }

  final ValueNotifier<TransactionItem?> _selectedTransactionNotifier =
      ValueNotifier<TransactionItem?>(null);

  @override
  void dispose() {
    _selectedTransactionNotifier.dispose();
    _viewModeNotifier.dispose();
    _selectedMonthNotifier.dispose();
    _selectedDateNotifier.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  void _previousPeriod() {
    _slideDirection = -1;
    final mode = _viewModeNotifier.value;
    final currentMonth = _selectedMonthNotifier.value;
    final now = DateTime.now();

    if (mode == 'monthly') {
      _selectedMonthNotifier.value =
          DateTime(currentMonth.year - 1, currentMonth.month);
    } else {
      final prevMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      _selectedMonthNotifier.value = prevMonth;
      if (prevMonth.year == now.year && prevMonth.month == now.month) {
        _selectedDateNotifier.value = now;
      } else {
        _selectedDateNotifier.value =
            DateTime(prevMonth.year, prevMonth.month, 1);
      }
    }
  }

  void _nextPeriod() {
    _slideDirection = 1;
    final mode = _viewModeNotifier.value;
    final currentMonth = _selectedMonthNotifier.value;
    final now = DateTime.now();

    if (mode == 'monthly') {
      _selectedMonthNotifier.value =
          DateTime(currentMonth.year + 1, currentMonth.month);
    } else {
      final nextMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      _selectedMonthNotifier.value = nextMonth;
      if (nextMonth.year == now.year && nextMonth.month == now.month) {
        _selectedDateNotifier.value = now;
      } else {
        _selectedDateNotifier.value =
            DateTime(nextMonth.year, nextMonth.month, 1);
      }
    }
  }

  void _toggleViewMode(String mode) {
    _slideDirection = 0;
    _viewModeNotifier.value = mode;
    getIt<PreferenceService>().setActivityViewMode(mode);
    if (mode == 'calendar') {
      final now = DateTime.now();
      _selectedMonthNotifier.value = DateTime(now.year, now.month);
      _selectedDateNotifier.value = now;
    }
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final currentMonth = _selectedMonthNotifier.value;
    final currentDate = _selectedDateNotifier.value;

    final daysInPickedMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    final initialDay = currentDate.day.clamp(1, daysInPickedMonth);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(currentMonth.year, currentMonth.month, initialDay),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: context.l10n.selectMonthAndYear,
    );
    if (picked != null) {
      final newMonth = DateTime(picked.year, picked.month);
      if (newMonth.isAfter(currentMonth)) {
        _slideDirection = 1;
      } else if (newMonth.isBefore(currentMonth)) {
        _slideDirection = -1;
      } else {
        _slideDirection = 0;
      }
      _selectedMonthNotifier.value = newMonth;
      if (picked.year == now.year && picked.month == now.month) {
        _selectedDateNotifier.value = now;
      } else {
        _selectedDateNotifier.value = DateTime(picked.year, picked.month, 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Builder(
        builder: (context) {
          final isTablet = Breakpoints.isTablet(context);
          if (isTablet) {
            return _buildTabletLayout(context);
          }
          return _buildCompactLayout(context);
        },
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const AllTransactionsShimmer();
          }

          final transactions = state is TransactionLoaded
              ? state.transactions
              : <TransactionItem>[];

          return ValueListenableBuilder<TransactionItem?>(
            valueListenable: _selectedTransactionNotifier,
            builder: (context, selectedTx, _) {
              final activeTx = selectedTx ??
                  (transactions.isNotEmpty ? transactions.first : null);

              return MasterDetailLayout(
                masterFlex: 4,
                detailFlex: 6,
                gutterWidth: TabletSpacing.gridGutter,
                showDivider: true,
                master: TransactionMasterList(
                  transactions: transactions,
                  selectedTransaction: activeTx,
                  onTransactionSelected: (item) {
                    _selectedTransactionNotifier.value = item;
                  },
                  isPrivacyModeNotifier: widget.isPrivacyModeNotifier,
                  selectedMonthNotifier: _selectedMonthNotifier,
                  viewModeNotifier: _viewModeNotifier,
                  onAddTransaction: () async {
                    final result =
                        await context.router.push(ModernAddTransactionRoute());
                    if (result == true && mounted) {
                      _cubit.loadTransactions();
                    }
                  },
                ),
                detail: TransactionDetailPanel(
                  transaction: activeTx,
                  isPrivacyModeNotifier: widget.isPrivacyModeNotifier,
                  onEdit: activeTx == null
                      ? null
                      : () async {
                          final result = await context.router.push(
                            ModernAddTransactionRoute(
                                initialTransaction: activeTx),
                          );
                          if (result == true && mounted) {
                            _cubit.loadTransactions();
                          }
                        },
                  onDelete: activeTx == null
                      ? null
                      : () async {
                          final l10n = context.l10n;
                          final confirmed = await StatusComponents
                              .showConfirmationBottomSheet(
                            context,
                            title: l10n.deleteTransactionConfirmTitle,
                            message: l10n.deleteTransactionConfirmDesc,
                            confirmLabel: l10n.confirm,
                            cancelLabel: l10n.cancel,
                            isDestructive: true,
                          );
                          if (confirmed == true && mounted) {
                            _cubit.deleteTransaction(activeTx.id);
                            _selectedTransactionNotifier.value = null;
                          }
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final topInset = MediaQuery.of(context).padding.top;
    final headerPaddingTop = topInset + kToolbarHeight;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: LiquidGlassAppBar(
        title: ValueListenableBuilder<String>(
          valueListenable: _viewModeNotifier,
          builder: (context, viewMode, _) {
            return ValueListenableBuilder<DateTime>(
              valueListenable: _selectedMonthNotifier,
              builder: (context, selectedMonth, _) {
                final locale = Localizations.localeOf(context).languageCode;
                final periodText = viewMode == 'monthly'
                    ? DateFormat.y(locale).format(selectedMonth)
                    : DateFormat.yMMMM(locale).format(selectedMonth);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: colorScheme.onSurface,
                        size: 26.r,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _previousPeriod,
                    ),
                    SizedBox(width: 4.w),
                    InkWell(
                      onTap: () => _pickMonth(context),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final isIncoming =
                                child.key == ValueKey(periodText);
                            final beginOffset = _slideDirection != 0
                                ? (isIncoming
                                    ? Offset(_slideDirection * 0.4, 0.0)
                                    : Offset(-_slideDirection * 0.4, 0.0))
                                : const Offset(0.0, 0.2);

                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: beginOffset,
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: isIncoming
                                        ? Curves.easeOutCubic
                                        : Curves.easeInCubic,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            periodText,
                            key: ValueKey(periodText),
                            style: (textTheme.titleMedium ?? const TextStyle())
                                .copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeights.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurface,
                        size: 26.r,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _nextPeriod,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: headerPaddingTop),
        child: Column(
          children: [
            // Top View Mode Tab Selector (Daily | Calendar | Monthly | List)
            ValueListenableBuilder<String>(
              valueListenable: _viewModeNotifier,
              builder: (context, viewMode, _) {
                return _ViewModeTabBar(
                  currentMode: viewMode,
                  onModeSelected: _toggleViewMode,
                );
              },
            ),

            // Search Bar Header with Entrance Animation
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: SlideTransition(
                position: _headerSlideAnimation,
                child: _LiquidGlassCard(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 6.h,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  child: AppTextField(
                    hintText: context.l10n.searchCategoryHint,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.outline,
                    ),
                    fillColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    onChanged: (val) {
                      context.read<TransactionCubit>().filterSearch(val);
                    },
                  ),
                ),
              ),
            ),

            // Transaction Type Filter Row (All, Expenses, Income, Transfer)
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: SlideTransition(
                position: _headerSlideAnimation,
                child: BlocBuilder<TransactionCubit, TransactionState>(
                  builder: (context, state) {
                    final selectedType =
                        state is TransactionLoaded ? state.selectedType : null;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 6.h,
                      ),
                      child: Row(
                        children: [
                          _TypeFilterChip(
                            label: 'All',
                            icon: Icons.tune_rounded,
                            isSelected: selectedType == null,
                            activeColor: colorScheme.primary,
                            onTap: () {
                              context.read<TransactionCubit>().filterType(null);
                            },
                          ),
                          SizedBox(width: 8.w),
                          _TypeFilterChip(
                            label: context.l10n.expenses,
                            icon: Icons.arrow_downward_rounded,
                            isSelected: selectedType == TransactionType.expense,
                            activeColor: context.customColors.semanticRed,
                            onTap: () {
                              context.read<TransactionCubit>().filterType(
                                    selectedType == TransactionType.expense
                                        ? null
                                        : TransactionType.expense,
                                  );
                            },
                          ),
                          SizedBox(width: 8.w),
                          _TypeFilterChip(
                            label: context.l10n.income,
                            icon: Icons.arrow_upward_rounded,
                            isSelected: selectedType == TransactionType.income,
                            activeColor: context.customColors.semanticGreen,
                            onTap: () {
                              context.read<TransactionCubit>().filterType(
                                    selectedType == TransactionType.income
                                        ? null
                                        : TransactionType.income,
                                  );
                            },
                          ),
                          SizedBox(width: 8.w),
                          _TypeFilterChip(
                            label: context.l10n.transfer,
                            icon: Icons.swap_horiz_rounded,
                            isSelected:
                                selectedType == TransactionType.transfer,
                            activeColor: context.customColors.semanticBlue,
                            onTap: () {
                              context.read<TransactionCubit>().filterType(
                                    selectedType == TransactionType.transfer
                                        ? null
                                        : TransactionType.transfer,
                                  );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Sub-headers for Calendar & List Mode
            ValueListenableBuilder<String>(
              valueListenable: _viewModeNotifier,
              builder: (context, viewMode, _) {
                if (viewMode == 'calendar') {
                  return ValueListenableBuilder<DateTime>(
                    valueListenable: _selectedMonthNotifier,
                    builder: (context, selectedMonth, _) {
                      return ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDateNotifier,
                        builder: (context, selectedDate, _) {
                          final monthKey = ValueKey(
                              'dates_${selectedMonth.year}_${selectedMonth.month}');

                          return SizedBox(
                            height: 84.h,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final isIncoming = child.key == monthKey;
                                final beginOffset = _slideDirection != 0
                                    ? (isIncoming
                                        ? Offset(_slideDirection * 0.3, 0.0)
                                        : Offset(-_slideDirection * 0.3, 0.0))
                                    : const Offset(0.0, 0.15);

                                return FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  ),
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: beginOffset,
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: isIncoming
                                            ? Curves.easeOutCubic
                                            : Curves.easeInCubic,
                                      ),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child: _HorizontalDateSelector(
                                key: monthKey,
                                selectedMonth: selectedMonth,
                                selectedDate: selectedDate,
                                onDateSelected: (date) {
                                  _selectedDateNotifier.value = date;
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Transactions Content Area wrapped in GestureDetector for swipe gestures
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < -200) {
                      HapticFeedback.lightImpact();
                      _nextPeriod();
                    } else if (details.primaryVelocity! > 200) {
                      HapticFeedback.lightImpact();
                      _previousPeriod();
                    }
                  }
                },
                child: ValueListenableBuilder<String>(
                  valueListenable: _viewModeNotifier,
                  builder: (context, viewMode, _) {
                    return ValueListenableBuilder<DateTime>(
                      valueListenable: _selectedMonthNotifier,
                      builder: (context, selectedMonth, _) {
                        return ValueListenableBuilder<DateTime>(
                          valueListenable: _selectedDateNotifier,
                          builder: (context, selectedDate, _) {
                            final currentContentKey = ValueKey(
                              'content_${viewMode}_${selectedMonth.year}_${selectedMonth.month}_${viewMode == 'calendar' ? selectedDate.day : 0}',
                            );

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                if (_slideDirection == 0) {
                                  return FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    ),
                                    child: ScaleTransition(
                                      scale:
                                          Tween<double>(begin: 0.96, end: 1.0)
                                              .animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                      child: child,
                                    ),
                                  );
                                }

                                final isIncoming =
                                    child.key == currentContentKey;
                                final beginOffset = isIncoming
                                    ? Offset(_slideDirection * 0.25, 0.0)
                                    : Offset(-_slideDirection * 0.25, 0.0);

                                return FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  ),
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: beginOffset,
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: isIncoming
                                            ? Curves.easeOutCubic
                                            : Curves.easeInCubic,
                                      ),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: currentContentKey,
                                child: BlocBuilder<TransactionCubit,
                                    TransactionState>(
                                  builder: (context, state) {
                                    if (state is TransactionLoading) {
                                      return const AllTransactionsShimmer();
                                    }

                                    if (state is TransactionLoaded) {
                                      final items = state.filteredTransactions;
                                      if (items.isEmpty) {
                                        return _EmptyStateView(
                                          title:
                                              context.l10n.noTransactionsFound,
                                          subtitle:
                                              context.l10n.noTransactionsDesc,
                                        );
                                      }

                                      // --- DAILY BALANCE SHEET MODE ---
                                      if (viewMode == 'daily') {
                                        final monthItems = items.where((tx) {
                                          return tx.timestamp.year ==
                                                  selectedMonth.year &&
                                              tx.timestamp.month ==
                                                  selectedMonth.month;
                                        }).toList();

                                        final totalIncome = monthItems
                                            .where((tx) =>
                                                tx.type ==
                                                TransactionType.income)
                                            .fold(
                                              0.0,
                                              (sum, tx) => sum + tx.amount,
                                            );
                                        final totalExpense = monthItems.fold(
                                          0.0,
                                          (sum, tx) =>
                                              sum +
                                              (tx.type ==
                                                      TransactionType.expense
                                                  ? tx.amount
                                                  : _parseTransferFeeFromNote(
                                                      tx.note)),
                                        );

                                        final Map<DateTime,
                                                List<TransactionItem>>
                                            dailyGrouped = {};
                                        for (final item in monthItems) {
                                          final dayKey = DateTime(
                                            item.timestamp.year,
                                            item.timestamp.month,
                                            item.timestamp.day,
                                          );
                                          dailyGrouped
                                              .putIfAbsent(dayKey, () => [])
                                              .add(item);
                                        }

                                        final sortedDays =
                                            dailyGrouped.keys.toList()
                                              ..sort(
                                                (a, b) => b.compareTo(a),
                                              );

                                        return RefreshIndicator(
                                          color: colorScheme.primary,
                                          onRefresh: () => context
                                              .read<TransactionCubit>()
                                              .loadTransactions(isSilent: true),
                                          child: ListView(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: EdgeInsets.only(
                                              bottom: 120.h,
                                            ),
                                            children: [
                                              _BalanceSheetSummaryHeader(
                                                totalIncome: totalIncome,
                                                totalExpense: totalExpense,
                                              ),
                                              if (sortedDays.isEmpty)
                                                _EmptyStateView(
                                                  title: context
                                                      .l10n.noTransactionsFound,
                                                  subtitle: context
                                                      .l10n.noTransactionsDesc,
                                                )
                                              else
                                                ...sortedDays.map((dayDate) {
                                                  final dayTxList =
                                                      dailyGrouped[dayDate]!;
                                                  final dayIncome = dayTxList
                                                      .where(
                                                        (tx) =>
                                                            tx.type ==
                                                            TransactionType
                                                                .income,
                                                      )
                                                      .fold(
                                                        0.0,
                                                        (sum, tx) =>
                                                            sum + tx.amount,
                                                      );
                                                  final dayExpense =
                                                      dayTxList.fold(
                                                    0.0,
                                                    (sum, tx) =>
                                                        sum +
                                                        (tx.type ==
                                                                TransactionType
                                                                    .expense
                                                            ? tx.amount
                                                            : _parseTransferFeeFromNote(
                                                                tx.note)),
                                                  );

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _DailyGroupHeader(
                                                        date: dayDate,
                                                        incomeSum: dayIncome,
                                                        expenseSum: dayExpense,
                                                      ),
                                                      ...dayTxList
                                                          .asMap()
                                                          .entries
                                                          .map(
                                                            (entry) =>
                                                                _StaggeredListViewItem(
                                                              index: entry.key,
                                                              child:
                                                                  _TransactionListTile(
                                                                transaction:
                                                                    entry.value,
                                                                isPrivacyModeNotifier:
                                                                    widget
                                                                        .isPrivacyModeNotifier,
                                                                onDelete: () {
                                                                  context
                                                                      .read<
                                                                          TransactionCubit>()
                                                                      .deleteTransaction(
                                                                        entry
                                                                            .value
                                                                            .id,
                                                                      );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                    ],
                                                  );
                                                }),
                                            ],
                                          ),
                                        );
                                      }

                                      // --- MONTHLY BALANCE SHEET MODE ---
                                      if (viewMode == 'monthly') {
                                        final yearItems = items.where((tx) {
                                          return tx.timestamp.year ==
                                              selectedMonth.year;
                                        }).toList();

                                        final totalIncome = yearItems
                                            .where((tx) =>
                                                tx.type ==
                                                TransactionType.income)
                                            .fold(
                                              0.0,
                                              (sum, tx) => sum + tx.amount,
                                            );
                                        final totalExpense = yearItems.fold(
                                          0.0,
                                          (sum, tx) =>
                                              sum +
                                              (tx.type ==
                                                      TransactionType.expense
                                                  ? tx.amount
                                                  : _parseTransferFeeFromNote(
                                                      tx.note)),
                                        );

                                        final Map<DateTime,
                                                List<TransactionItem>>
                                            monthlyGrouped = {};
                                        for (final item in yearItems) {
                                          final monthKey = DateTime(
                                            item.timestamp.year,
                                            item.timestamp.month,
                                          );
                                          monthlyGrouped
                                              .putIfAbsent(monthKey, () => [])
                                              .add(item);
                                        }

                                        final sortedMonths =
                                            monthlyGrouped.keys.toList()
                                              ..sort(
                                                (a, b) => b.compareTo(a),
                                              );

                                        return RefreshIndicator(
                                          color: colorScheme.primary,
                                          onRefresh: () => context
                                              .read<TransactionCubit>()
                                              .loadTransactions(isSilent: true),
                                          child: ListView(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: EdgeInsets.only(
                                              bottom: 120.h,
                                            ),
                                            children: [
                                              _BalanceSheetSummaryHeader(
                                                totalIncome: totalIncome,
                                                totalExpense: totalExpense,
                                              ),
                                              if (sortedMonths.isEmpty)
                                                _EmptyStateView(
                                                  title: context
                                                      .l10n.noTransactionsFound,
                                                  subtitle: context
                                                      .l10n.noTransactionsDesc,
                                                )
                                              else
                                                ...sortedMonths
                                                    .map((monthDate) {
                                                  final monthTxList =
                                                      monthlyGrouped[
                                                          monthDate]!;
                                                  final monthIncome =
                                                      monthTxList
                                                          .where(
                                                            (tx) =>
                                                                tx.type ==
                                                                TransactionType
                                                                    .income,
                                                          )
                                                          .fold(
                                                            0.0,
                                                            (sum, tx) =>
                                                                sum + tx.amount,
                                                          );
                                                  final monthExpense =
                                                      monthTxList
                                                          .where(
                                                            (tx) =>
                                                                tx.type ==
                                                                TransactionType
                                                                    .expense,
                                                          )
                                                          .fold(
                                                            0.0,
                                                            (sum, tx) =>
                                                                sum + tx.amount,
                                                          );

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _MonthlyGroupHeader(
                                                        date: monthDate,
                                                        incomeSum: monthIncome,
                                                        expenseSum:
                                                            monthExpense,
                                                      ),
                                                      ...monthTxList
                                                          .asMap()
                                                          .entries
                                                          .map(
                                                            (entry) =>
                                                                _StaggeredListViewItem(
                                                              index: entry.key,
                                                              child:
                                                                  _TransactionListTile(
                                                                transaction:
                                                                    entry.value,
                                                                isPrivacyModeNotifier:
                                                                    widget
                                                                        .isPrivacyModeNotifier,
                                                                onDelete: () {
                                                                  context
                                                                      .read<
                                                                          TransactionCubit>()
                                                                      .deleteTransaction(
                                                                        entry
                                                                            .value
                                                                            .id,
                                                                      );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                    ],
                                                  );
                                                }),
                                            ],
                                          ),
                                        );
                                      }

                                      // --- CALENDAR MODE & LIST MODE ---
                                      List<TransactionItem> displayItems =
                                          items;

                                      if (viewMode == 'calendar') {
                                        displayItems = items.where((tx) {
                                          return tx.timestamp.year ==
                                                  selectedDate.year &&
                                              tx.timestamp.month ==
                                                  selectedDate.month &&
                                              tx.timestamp.day ==
                                                  selectedDate.day;
                                        }).toList();

                                        if (displayItems.isEmpty) {
                                          final locale = Localizations.localeOf(
                                            context,
                                          ).languageCode;
                                          final formattedDate =
                                              DateFormat.yMMMd(locale)
                                                  .format(selectedDate);
                                          return _EmptyStateView(
                                            title: context.l10n
                                                .noTransactionsOnDate(
                                              formattedDate,
                                            ),
                                            subtitle:
                                                context.l10n.noTransactionsDesc,
                                          );
                                        }
                                      }

                                      final Map<String, List<TransactionItem>>
                                          grouped = {};
                                      for (final item in displayItems) {
                                        final dateKey = _formatDateHeader(
                                          context,
                                          item.timestamp,
                                        );
                                        grouped
                                            .putIfAbsent(
                                              dateKey,
                                              () => [],
                                            )
                                            .add(item);
                                      }

                                      if (grouped.isEmpty) {
                                        return _EmptyStateView(
                                          title:
                                              context.l10n.noTransactionsFound,
                                          subtitle:
                                              context.l10n.noTransactionsDesc,
                                        );
                                      }

                                      return RefreshIndicator(
                                        color: colorScheme.primary,
                                        onRefresh: () => context
                                            .read<TransactionCubit>()
                                            .loadTransactions(isSilent: true),
                                        child: ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: EdgeInsets.only(
                                            bottom: 120.h,
                                          ),
                                          itemCount: grouped.keys.length,
                                          itemBuilder: (context, index) {
                                            final dateKey =
                                                grouped.keys.elementAt(index);
                                            final dateItems = grouped[dateKey]!;
                                            final baseStaggerIndex = index * 3;

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _StaggeredListViewItem(
                                                  index: baseStaggerIndex,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 20.w,
                                                      vertical: 8.h,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          dateKey.toUpperCase(),
                                                          style: customTypography
                                                              .labelMediumMono
                                                              .copyWith(
                                                            color: colorScheme
                                                                .outline,
                                                            letterSpacing: 1.2,
                                                          ),
                                                        ),
                                                        Text(
                                                          context.l10n
                                                              .transactionsCount(
                                                            dateItems.length,
                                                          ),
                                                          style: customTypography
                                                              .labelMediumMono
                                                              .copyWith(
                                                            color: colorScheme
                                                                .onSurfaceVariant,
                                                            fontSize: 11.sp,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                ...dateItems
                                                    .asMap()
                                                    .entries
                                                    .map(
                                                      (entry) =>
                                                          _StaggeredListViewItem(
                                                        index:
                                                            baseStaggerIndex +
                                                                entry.key +
                                                                1,
                                                        child:
                                                            _TransactionListTile(
                                                          transaction:
                                                              entry.value,
                                                          isPrivacyModeNotifier:
                                                              widget
                                                                  .isPrivacyModeNotifier,
                                                          onDelete: () {
                                                            context
                                                                .read<
                                                                    TransactionCubit>()
                                                                .deleteTransaction(
                                                                  entry
                                                                      .value.id,
                                                                );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateHeader(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final check = DateTime(dt.year, dt.month, dt.day);

    if (check == today) return context.l10n.today;
    if (check == yesterday) return context.l10n.yesterday;

    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMd(locale).format(dt);
  }
}

class _HorizontalDateSelector extends StatefulWidget {
  final DateTime selectedMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _HorizontalDateSelector({
    super.key,
    required this.selectedMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_HorizontalDateSelector> createState() =>
      _HorizontalDateSelectorState();
}

class _HorizontalDateSelectorState extends State<_HorizontalDateSelector> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(widget.selectedDate, animated: false);
    });
  }

  @override
  void didUpdateWidget(covariant _HorizontalDateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToDate(widget.selectedDate, animated: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDate(DateTime date, {bool animated = true}) {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.positions.length != 1) return;
    final itemWidth = 60.0.w;
    final index = date.day - 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset =
        (16.0.w + index * itemWidth + (itemWidth / 2)) - (screenWidth / 2);
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    if (animated) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final locale = Localizations.localeOf(context).languageCode;

    final daysInMonth = DateUtils.getDaysInMonth(
      widget.selectedMonth.year,
      widget.selectedMonth.month,
    );
    final List<DateTime> dates = List.generate(
      daysInMonth,
      (i) => DateTime(
          widget.selectedMonth.year, widget.selectedMonth.month, i + 1),
    );

    return SizedBox(
      height: 84.h,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final now = DateTime.now();
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;

          final weekdayStr = DateFormat.E(locale).format(date);

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 250 + (index.clamp(0, 10) * 20)),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return Opacity(
                opacity: animValue.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + (animValue * 0.15),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52.w,
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : isToday
                            ? colorScheme.primary
                                .withValues(alpha: isLight ? 0.14 : 0.18)
                            : (isLight
                                ? colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.45)
                                : colorScheme.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary
                                  .withValues(alpha: isLight ? 0.22 : 0.28),
                              blurRadius: 8.r,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : isToday
                              ? colorScheme.primary.withValues(alpha: 0.75)
                              : (isLight
                                  ? colorScheme.outlineVariant
                                      .withValues(alpha: 0.6)
                                  : context.customColors.glassStroke),
                      width: isSelected ? 1.5 : (isToday ? 1.4 : 1.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdayStr.toUpperCase(),
                        style: customTypography.labelMediumMono.copyWith(
                          fontSize: 10.sp,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : isToday
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected || isToday
                              ? FontWeights.bold
                              : FontWeights.medium,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${date.day}',
                        style: customTypography.bodyLargeBold.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : isToday
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                          fontSize: 18.sp,
                        ),
                      ),
                      if (isToday) ...[
                        SizedBox(height: 2.h),
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyStateView({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedEmptyStateHero(
              primaryIcon: Icons.receipt_long_rounded,
              primaryColor: colorScheme.primary,
              secondaryBadgeTop: Icons.payments_outlined,
              secondaryColorTop: colorScheme.secondary,
              secondaryBadgeBottom: Icons.calendar_today_rounded,
              secondaryColorBottom: colorScheme.primary,
              containerSize: 104.w,
              heroSize: 154.w,
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: customTypography.bodyLargeBold.copyWith(
                color: colorScheme.onSurface,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: customTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionListTile extends StatelessWidget {
  final TransactionItem transaction;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final VoidCallback onDelete;

  const _TransactionListTile({
    required this.transaction,
    this.isPrivacyModeNotifier,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final customTypography = context.customTypography;
    final customColors = context.customColors;
    final catColor = transaction.type == TransactionType.income
        ? customColors.semanticGreen
        : transaction.type == TransactionType.transfer
            ? customColors.semanticBlue
            : customColors.semanticRed;

    return InkWell(
      onTap: () {
        context.router.push(
          TransactionDetailsRoute(
            transaction: transaction,
            isPrivacyModeNotifier: isPrivacyModeNotifier,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.customColors.glassStroke),
        ),
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                transaction.type == TransactionType.transfer
                    ? Icons.swap_horiz_rounded
                    : _getIconData(transaction.categoryIcon),
                color: catColor,
                size: 22.r,
              ),
            ),
            SizedBox(width: 14.w),

            // Title & Note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.type == TransactionType.transfer
                        ? context.l10n.transfer
                        : transaction.categoryName,
                    style: customTypography.bodyLargeBold.copyWith(
                      color: context.colorScheme.onSurface,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (transaction.note?.isNotEmpty == true)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        transaction.note!,
                        style: customTypography.bodyMedium.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Amount Display
            ValueListenableBuilder<bool>(
              valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
              builder: (context, isPrivacy, _) {
                final color = transaction.type == TransactionType.income
                    ? context.customColors.semanticGreen
                    : transaction.type == TransactionType.transfer
                        ? context.customColors.semanticBlue
                        : context.customColors.semanticRed;

                return CompactAmountText(
                  amount: transaction.amount,
                  isPrivacyMode: isPrivacy,
                  showSign: true,
                  type: transaction.type,
                  isIncome: transaction.type == TransactionType.income
                      ? true
                      : (transaction.type == TransactionType.expense
                          ? false
                          : null),
                  style: customTypography.headlineMediumMonoBold.copyWith(
                    color: color,
                    fontSize: 16.sp,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'storefront':
        return Icons.storefront_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

/// Helper widget for staggered list view entrance animations.
class _StaggeredListViewItem extends StatelessWidget {
  final Widget child;
  final int index;

  const _StaggeredListViewItem({
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIndex = index.clamp(0, 10);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 320 + (effectiveIndex * 35)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * 18.h),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Helper widget for animated type filter chip segment buttons.
class _TypeFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final onActiveTextColor = (activeColor == colorScheme.primary && !isLight)
        ? colorScheme.onPrimary
        : Colors.white;

    return AnimatedScale(
      scale: isSelected ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor
                  : (isLight
                      ? colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6)
                      : colorScheme.surfaceContainerLow),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : (isLight
                        ? colorScheme.outlineVariant.withValues(alpha: 0.6)
                        : context.customColors.glassStroke),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            activeColor.withValues(alpha: isLight ? 0.35 : 0.4),
                        blurRadius: 8.r,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16.r,
                  color: isSelected
                      ? onActiveTextColor
                      : colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: customTypography.labelMediumMono.copyWith(
                    color:
                        isSelected ? onActiveTextColor : colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeights.bold : FontWeights.medium,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper widget for the top view mode tab bar (Daily | Calendar | Monthly).
class _ViewModeTabBar extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeSelected;

  const _ViewModeTabBar({
    required this.currentMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    final modes = [
      {'id': 'daily', 'label': 'Daily'},
      {'id': 'calendar', 'label': 'Calendar'},
      {'id': 'monthly', 'label': 'Monthly'},
    ];

    return _LiquidGlassCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      padding: EdgeInsets.all(4.w),
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        children: modes.map((m) {
          final modeId = m['id']!;
          final isSelected = currentMode == modeId;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: GestureDetector(
                onTap: () => onModeSelected(modeId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8.r,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    m['label']!,
                    textAlign: TextAlign.center,
                    style: customTypography.labelMediumMono.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeights.bold : FontWeights.medium,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _LiquidGlassCard({
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

/// Balance Sheet Summary Card showing INCOME, EXPENSES, and TOTAL BALANCE.
class _BalanceSheetSummaryHeader extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const _BalanceSheetSummaryHeader({
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final balance = totalIncome - totalExpense;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.customColors.glassStroke),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10.r,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: getIt<PreferenceService>().currencySymbolNotifier,
        builder: (context, symbol, _) {
          final customColors = context.customColors;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryColumn(
                label: 'INCOME',
                amount: totalIncome,
                symbol: symbol,
                color: customColors.semanticGreen,
              ),
              Container(
                height: 36.h,
                width: 1.w,
                color: customColors.glassStroke,
              ),
              _SummaryColumn(
                label: 'EXPENSES',
                amount: totalExpense,
                symbol: symbol,
                color: customColors.semanticRed,
              ),
              Container(
                height: 36.h,
                width: 1.w,
                color: customColors.glassStroke,
              ),
              _SummaryColumn(
                label: 'TOTAL BALANCE',
                amount: balance.abs(),
                symbol: symbol,
                isNegative: balance < 0,
                color: balance >= 0
                    ? colorScheme.onSurface
                    : customColors.semanticRed,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final double amount;
  final String symbol;
  final Color color;
  final bool isNegative;

  const _SummaryColumn({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.color,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final customTypography = context.customTypography;
    final colorScheme = context.colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: customTypography.labelMediumMono.copyWith(
              color: colorScheme.outline,
              fontSize: 10.sp,
              letterSpacing: 0.8,
              fontWeight: FontWeights.semiBold,
            ),
          ),
          SizedBox(height: 4.h),
          CompactAmountText(
            amount: amount,
            currencySymbol: symbol,
            showSign: isNegative,
            isIncome: !isNegative,
            style: customTypography.bodyLargeBold.copyWith(
              color: color,
              fontWeight: FontWeights.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily group header matching reference design: 28 Tue 07.2026 ... +$0.00 -$1,688.75
class _DailyGroupHeader extends StatelessWidget {
  final DateTime date;
  final double incomeSum;
  final double expenseSum;

  const _DailyGroupHeader({
    required this.date,
    required this.incomeSum,
    required this.expenseSum,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final locale = Localizations.localeOf(context).languageCode;

    final dayStr = DateFormat('dd').format(date);
    final weekdayStr = DateFormat('EEE', locale).format(date);
    final monthYearStr = DateFormat('MM.yyyy').format(date);

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: context.customColors.glassStroke,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  dayStr,
                  style: customTypography.bodyLargeBold.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeights.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    weekdayStr,
                    style: customTypography.labelMediumMono.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeights.medium,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    monthYearStr,
                    overflow: TextOverflow.ellipsis,
                    style: customTypography.labelMediumMono.copyWith(
                      color: colorScheme.outline,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: getIt<PreferenceService>().currencySymbolNotifier,
            builder: (context, activeSymbol, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CompactAmountText(
                    amount: incomeSum,
                    currencySymbol: activeSymbol,
                    showSign: true,
                    isIncome: true,
                    style: customTypography.labelMediumMono.copyWith(
                      color: context.customColors.semanticGreen,
                      fontWeight: FontWeights.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CompactAmountText(
                    amount: expenseSum,
                    currencySymbol: activeSymbol,
                    showSign: true,
                    isIncome: false,
                    style: customTypography.labelMediumMono.copyWith(
                      color: context.customColors.semanticRed,
                      fontWeight: FontWeights.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Monthly group header for monthly balance sheet mode
class _MonthlyGroupHeader extends StatelessWidget {
  final DateTime date;
  final double incomeSum;
  final double expenseSum;

  const _MonthlyGroupHeader({
    required this.date,
    required this.incomeSum,
    required this.expenseSum,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final locale = Localizations.localeOf(context).languageCode;

    final monthStr = DateFormat.yMMMM(locale).format(date);

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: context.customColors.glassStroke,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              monthStr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: customTypography.bodyLargeBold.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeights.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: getIt<PreferenceService>().currencySymbolNotifier,
            builder: (context, activeSymbol, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CompactAmountText(
                    amount: incomeSum,
                    currencySymbol: activeSymbol,
                    showSign: true,
                    isIncome: true,
                    style: customTypography.labelMediumMono.copyWith(
                      color: context.customColors.semanticGreen,
                      fontWeight: FontWeights.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CompactAmountText(
                    amount: expenseSum,
                    currencySymbol: activeSymbol,
                    showSign: true,
                    isIncome: false,
                    style: customTypography.labelMediumMono.copyWith(
                      color: context.customColors.semanticRed,
                      fontWeight: FontWeights.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

double _parseTransferFeeFromNote(String? note) {
  if (note == null || !note.contains('(Fee:')) return 0.0;
  final regExp = RegExp(r'\(Fee:\s*[^0-9]*([0-9]+(?:\.[0-9]+)?)\)');
  final match = regExp.firstMatch(note);
  if (match != null && match.groupCount >= 1) {
    return double.tryParse(match.group(1)!) ?? 0.0;
  }
  return 0.0;
}
