import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/amount_formatting_extensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/transaction_item.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';
import '../widgets/all_transactions_shimmer.dart';

class AllTransactionsPage extends StatefulWidget {
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const AllTransactionsPage({super.key, this.isPrivacyModeNotifier});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  late final ValueNotifier<String> _viewModeNotifier;
  late final ValueNotifier<DateTime> _selectedMonthNotifier;
  late final ValueNotifier<DateTime> _selectedDateNotifier;
  late final ValueNotifier<DateTime?> _startDateNotifier;
  late final ValueNotifier<DateTime?> _endDateNotifier;

  final ScrollController _calendarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final prefs = getIt<PreferenceService>();
    final now = DateTime.now();

    _viewModeNotifier = ValueNotifier<String>(prefs.activityViewMode);
    _selectedMonthNotifier = ValueNotifier<DateTime>(DateTime(now.year, now.month));
    _selectedDateNotifier = ValueNotifier<DateTime>(now);
    _startDateNotifier = ValueNotifier<DateTime?>(null);
    _endDateNotifier = ValueNotifier<DateTime?>(null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animated: false);
    });
  }

  @override
  void dispose() {
    _viewModeNotifier.dispose();
    _selectedMonthNotifier.dispose();
    _selectedDateNotifier.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    _calendarScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate({bool animated = true}) {
    if (!_calendarScrollController.hasClients) return;
    final itemWidth = 60.0.w;
    final index = _selectedDateNotifier.value.day - 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (16.0.w + index * itemWidth + (itemWidth / 2)) - (screenWidth / 2);
    final maxScroll = _calendarScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    if (animated) {
      _calendarScrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _calendarScrollController.jumpTo(clampedOffset);
    }
  }

  void _toggleViewMode(String mode) {
    _viewModeNotifier.value = mode;
    getIt<PreferenceService>().setActivityViewMode(mode);
    if (mode == 'calendar') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate(animated: false);
      });
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
      _selectedMonthNotifier.value = DateTime(picked.year, picked.month);
      if (picked.year == now.year && picked.month == now.month) {
        _selectedDateNotifier.value = now;
      } else {
        _selectedDateNotifier.value = DateTime(picked.year, picked.month, 1);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate(animated: true);
      });
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final start = _startDateNotifier.value;
    final end = _endDateNotifier.value;

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: start != null && end != null
          ? DateTimeRange(start: start, end: end)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: context.colorScheme.copyWith(
              primary: AppColors.primaryContainer,
              onPrimary: AppColors.onPrimaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _startDateNotifier.value = picked.start;
      _endDateNotifier.value = picked.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return BlocProvider.value(
      value: () {
        final cubit = getIt<TransactionCubit>();
        if (!cubit.isClosed) {
          cubit.loadTransactions();
        }
        return cubit;
      }(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              automaticallyImplyLeading: true,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Text(
                context.l10n.activity,
                style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeights.bold,
                ),
              ),
              actions: [
                ValueListenableBuilder<String>(
                  valueListenable: _viewModeNotifier,
                  builder: (context, viewMode, _) {
                    return Container(
                      margin: EdgeInsets.only(right: 16.w),
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.glassStroke),
                      ),
                      child: Row(
                        children: [
                          _ViewModeToggleButton(
                            icon: Icons.calendar_month_rounded,
                            mode: 'calendar',
                            currentMode: viewMode,
                            tooltip: context.l10n.calendarView,
                            onTap: () => _toggleViewMode('calendar'),
                          ),
                          _ViewModeToggleButton(
                            icon: Icons.format_list_bulleted_rounded,
                            mode: 'list',
                            currentMode: viewMode,
                            tooltip: context.l10n.listView,
                            onTap: () => _toggleViewMode('list'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Search Bar Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: AppTextField(
                    hintText: context.l10n.searchCategoryHint,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.outline,
                    ),
                    fillColor: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16.r),
                    onChanged: (val) {
                      context.read<TransactionCubit>().filterSearch(val);
                    },
                  ),
                ),

                // View Mode Content Headers
                ValueListenableBuilder<String>(
                  valueListenable: _viewModeNotifier,
                  builder: (context, viewMode, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          ),
                        );
                      },
                      child: viewMode == 'calendar'
                          ? Column(
                              key: const ValueKey('calendar_header'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 4.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ValueListenableBuilder<DateTime>(
                                        valueListenable: _selectedMonthNotifier,
                                        builder: (context, selectedMonth, _) {
                                          final monthYearStr = DateFormat.yMMMM(
                                            Localizations.localeOf(context).languageCode,
                                          ).format(selectedMonth);

                                          return InkWell(
                                            onTap: () => _pickMonth(context),
                                            borderRadius: BorderRadius.circular(12.r),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.surfaceContainerHigh,
                                                borderRadius: BorderRadius.circular(12.r),
                                                border: Border.all(
                                                  color: AppColors.glassStroke,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    monthYearStr,
                                                    style: customTypography.bodyLargeBold
                                                        .copyWith(
                                                      color: colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Icon(
                                                    Icons.expand_more_rounded,
                                                    color: colorScheme.primary,
                                                    size: 20.r,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ValueListenableBuilder<DateTime>(
                                        valueListenable: _selectedDateNotifier,
                                        builder: (context, selectedDate, _) {
                                          final dateStr = DateFormat.MMMd(
                                            Localizations.localeOf(context).languageCode,
                                          ).format(selectedDate);

                                          return Text(
                                            dateStr,
                                            style: customTypography.labelMediumMono
                                                .copyWith(
                                              color: colorScheme.outline,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                ValueListenableBuilder<DateTime>(
                                  valueListenable: _selectedMonthNotifier,
                                  builder: (context, selectedMonth, _) {
                                    return ValueListenableBuilder<DateTime>(
                                      valueListenable: _selectedDateNotifier,
                                      builder: (context, selectedDate, _) {
                                        return _HorizontalDateSelector(
                                          selectedMonth: selectedMonth,
                                          selectedDate: selectedDate,
                                          scrollController: _calendarScrollController,
                                          onDateSelected: (date) {
                                            _selectedDateNotifier.value = date;
                                            _scrollToSelectedDate(animated: true);
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: 8.h),
                              ],
                            )
                          : Column(
                              key: const ValueKey('list_header'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 4.h,
                                  ),
                                  child: ValueListenableBuilder<DateTime?>(
                                    valueListenable: _startDateNotifier,
                                    builder: (context, startDate, _) {
                                      return ValueListenableBuilder<DateTime?>(
                                        valueListenable: _endDateNotifier,
                                        builder: (context, endDate, _) {
                                          final hasFilter =
                                              startDate != null && endDate != null;
                                          final locale = Localizations.localeOf(context)
                                              .languageCode;
                                          final dateRangeText = hasFilter
                                              ? '${DateFormat.yMMMd(locale).format(startDate)} – ${DateFormat.yMMMd(locale).format(endDate)}'
                                              : context.l10n.filterByDateRangeAllTime;

                                          return Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () => _pickDateRange(context),
                                                  borderRadius:
                                                      BorderRadius.circular(12.r),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 8.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: hasFilter
                                                          ? AppColors.primaryContainer
                                                              .withValues(alpha: 0.15)
                                                          : colorScheme
                                                              .surfaceContainerHigh,
                                                      borderRadius:
                                                          BorderRadius.circular(12.r),
                                                      border: Border.all(
                                                        color: hasFilter
                                                            ? colorScheme.primary
                                                                .withValues(alpha: 0.5)
                                                            : AppColors.glassStroke,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.date_range_rounded,
                                                          size: 18.r,
                                                          color: hasFilter
                                                              ? colorScheme.primary
                                                              : colorScheme.outline,
                                                        ),
                                                        SizedBox(width: 8.w),
                                                        Expanded(
                                                          child: Text(
                                                            dateRangeText,
                                                            style: customTypography
                                                                .labelMediumMono
                                                                .copyWith(
                                                              color: hasFilter
                                                                  ? colorScheme.primary
                                                                  : colorScheme
                                                                      .onSurfaceVariant,
                                                              fontWeight: hasFilter
                                                                  ? FontWeights.bold
                                                                  : FontWeights.regular,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (hasFilter) ...[
                                                SizedBox(width: 6.w),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.clear_rounded,
                                                    size: 20.r,
                                                  ),
                                                  color: colorScheme.outline,
                                                  onPressed: () {
                                                    _startDateNotifier.value = null;
                                                    _endDateNotifier.value = null;
                                                  },
                                                  tooltip: context.l10n.clearDateFilter,
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 8.h),
                              ],
                            ),
                    );
                  },
                ),

                // Transactions Content
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: _viewModeNotifier,
                    builder: (context, viewMode, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.96, end: 1.0)
                                  .animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey('content_$viewMode'),
                          child: ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDateNotifier,
                        builder: (context, selectedDate, _) {
                          return ValueListenableBuilder<DateTime?>(
                            valueListenable: _startDateNotifier,
                            builder: (context, startDate, _) {
                              return ValueListenableBuilder<DateTime?>(
                                valueListenable: _endDateNotifier,
                                builder: (context, endDate, _) {
                                  return BlocBuilder<TransactionCubit,
                                      TransactionState>(
                                    builder: (context, state) {
                                      if (state is TransactionLoading) {
                                        return const AllTransactionsShimmer();
                                      }

                                      if (state is TransactionLoaded) {
                                        final items =
                                            state.filteredTransactions;
                                        if (items.isEmpty) {
                                          return _EmptyStateView(
                                            title: context
                                                .l10n.noTransactionsFound,
                                            subtitle: context
                                                .l10n.noTransactionsDesc,
                                          );
                                        }

                                        List<TransactionItem> displayItems =
                                            items;

                                        // Filter by selected date in Calendar mode
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
                                            final locale =
                                                Localizations.localeOf(context)
                                                    .languageCode;
                                            final formattedDate =
                                                DateFormat.yMMMd(locale)
                                                    .format(selectedDate);
                                            return Center(
                                              child: Text(
                                                context.l10n
                                                    .noTransactionsOnDate(
                                                        formattedDate),
                                                style: customTypography
                                                    .bodyMedium
                                                    .copyWith(
                                                  color: colorScheme.outline,
                                                ),
                                              ),
                                            );
                                          }
                                        }

                                        // Filter by date range in List mode
                                        if (viewMode == 'list' &&
                                            startDate != null &&
                                            endDate != null) {
                                          final start = DateTime(
                                            startDate.year,
                                            startDate.month,
                                            startDate.day,
                                          );
                                          final end = DateTime(
                                            endDate.year,
                                            endDate.month,
                                            endDate.day,
                                            23,
                                            59,
                                            59,
                                          );

                                          displayItems = items.where((tx) {
                                            return tx.timestamp.isAfter(
                                                  start.subtract(
                                                    const Duration(seconds: 1),
                                                  ),
                                                ) &&
                                                tx.timestamp.isBefore(
                                                  end.add(
                                                    const Duration(seconds: 1),
                                                  ),
                                                );
                                          }).toList();

                                          if (displayItems.isEmpty) {
                                            return Center(
                                              child: Text(
                                                context.l10n
                                                    .noTransactionsInDateRange,
                                                style: customTypography
                                                    .bodyMedium
                                                    .copyWith(
                                                  color: colorScheme.outline,
                                                ),
                                              ),
                                            );
                                          }
                                        }

                                        // Group transactions by Date
                                        final Map<String, List<TransactionItem>>
                                            grouped = {};
                                        for (final item in displayItems) {
                                          final dateKey = _formatDateHeader(
                                            context,
                                            item.timestamp,
                                          );
                                          grouped
                                              .putIfAbsent(dateKey, () => [])
                                              .add(item);
                                        }

                                        return RefreshIndicator(
                                          color: AppColors.primary,
                                          onRefresh: () => context
                                              .read<TransactionCubit>()
                                              .loadTransactions(),
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding:
                                                EdgeInsets.only(bottom: 120.h),
                                            itemCount: grouped.keys.length,
                                            itemBuilder: (context, index) {
                                              final dateKey =
                                                  grouped.keys.elementAt(index);
                                              final dateItems =
                                                  grouped[dateKey]!;

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Date Header
                                                  Padding(
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
                                                          style:
                                                              customTypography
                                                                  .labelMediumMono
                                                                  .copyWith(
                                                            color: AppColors
                                                                .outline,
                                                            letterSpacing: 1.2,
                                                          ),
                                                        ),
                                                        Text(
                                                          context.l10n
                                                              .transactionsCount(
                                                            dateItems.length,
                                                          ),
                                                          style:
                                                              customTypography
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

                                                  // Date Items
                                                  ...dateItems.map(
                                                    (tx) =>
                                                        _TransactionListTile(
                                                      transaction: tx,
                                                      isPrivacyModeNotifier: widget
                                                          .isPrivacyModeNotifier,
                                                      onDelete: () {
                                                        context
                                                            .read<
                                                                TransactionCubit>()
                                                            .deleteTransaction(
                                                              tx.id,
                                                            );
                                                      },
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
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
              ],
            ),
          );
        },
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

class _ViewModeToggleButton extends StatelessWidget {
  final IconData icon;
  final String mode;
  final String currentMode;
  final String tooltip;
  final VoidCallback onTap;

  const _ViewModeToggleButton({
    required this.icon,
    required this.mode,
    required this.currentMode,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == mode;
    final colorScheme = context.colorScheme;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 18.r,
            color: isSelected ? Colors.black : colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _HorizontalDateSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final DateTime selectedDate;
  final ScrollController scrollController;
  final ValueChanged<DateTime> onDateSelected;

  const _HorizontalDateSelector({
    required this.selectedMonth,
    required this.selectedDate,
    required this.scrollController,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final locale = Localizations.localeOf(context).languageCode;

    final daysInMonth = DateUtils.getDaysInMonth(
      selectedMonth.year,
      selectedMonth.month,
    );
    final List<DateTime> dates = List.generate(
      daysInMonth,
      (i) => DateTime(selectedMonth.year, selectedMonth.month, i + 1),
    );

    return SizedBox(
      height: 76.h,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          final weekdayStr = DateFormat.E(locale).format(date);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.5)
                      : AppColors.glassStroke,
                  width: isSelected ? 1.5 : 1.0,
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
                          ? colorScheme.primary
                          : colorScheme.outline,
                      fontWeight: isSelected
                          ? FontWeights.bold
                          : FontWeights.regular,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${date.day}',
                    style: customTypography.bodyLargeBold.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.r,
            color: colorScheme.outline,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: customTypography.bodyLargeBold.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: customTypography.bodyMedium.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
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
    final catColor = _parseColor(transaction.categoryColorHex);

    return Dismissible(
      key: Key('tx_${transaction.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        color: AppColors.semanticRed.withValues(alpha: 0.8),
        child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24.r),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
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
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.glassStroke),
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
                _getIconData(transaction.categoryIcon),
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
                    transaction.categoryName,
                    style: customTypography.bodyLargeBold.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (transaction.note?.isNotEmpty == true)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        transaction.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: customTypography.bodyMedium.copyWith(
                          color: AppColors.outline,
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
                final symbol = getIt<PreferenceService>().currencySymbol;
                final formatted = transaction.amount.formatCurrency(
                  symbol,
                  isPrivacyMode: isPrivacy,
                  showSign: true,
                  isIncome: transaction.isIncome,
                );
                final color = transaction.isIncome
                    ? AppColors.semanticGreen
                    : AppColors.semanticRed;

                return Text(
                  formatted,
                  style: customTypography.headlineMediumMonoBold.copyWith(
                    color: color,
                    fontSize: 16.sp,
                  ),
                );
              },
            ),

            SizedBox(width: 8.w),

            // Edit Action Button
            IconButton(
              icon: Icon(
                Icons.edit_rounded,
                size: 18.r,
                color: context.colorScheme.outline,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Edit transaction',
              onPressed: () async {
                final result = await context.router.push(
                  ModernAddTransactionRoute(initialTransaction: transaction),
                );
                if (result == true && context.mounted) {
                  context.read<TransactionCubit>().loadTransactions();
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return AppColors.primary;
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
