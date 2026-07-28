import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
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
  late String _viewMode; // 'calendar' or 'list'
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final prefs = getIt<PreferenceService>();
    _viewMode = prefs.activityViewMode;
  }

  void _toggleViewMode(String mode) {
    setState(() {
      _viewMode = mode;
    });
    getIt<PreferenceService>().setActivityViewMode(mode);
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'SELECT MONTH & YEAR',
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        if (_selectedMonth.year == now.year &&
            _selectedMonth.month == now.month) {
          _selectedDate = now;
        } else {
          _selectedDate = DateTime(picked.year, picked.month, 1);
        }
      });
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return BlocProvider(
      create: (_) {
        try {
          return getIt<TransactionCubit>()..loadTransactions();
        } catch (_) {
          final db = getIt<AppDatabase>();
          final ds = TransactionLocalDataSourceImpl(db);
          final repo = TransactionRepositoryImpl(ds);
          return TransactionCubit(repo)..loadTransactions();
        }
      },
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
                      icon: Icon(Icons.arrow_back_rounded,
                          color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Text(
                context.l10n.activity,
                style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // View Mode Segmented Toggle (Calendar vs List)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassStroke),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton(
                        icon: Icons.calendar_month_rounded,
                        mode: 'calendar',
                        tooltip: 'Calendar View',
                      ),
                      _buildToggleButton(
                        icon: Icons.format_list_bulleted_rounded,
                        mode: 'list',
                        tooltip: 'List View',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // Search Bar Header using custom AppTextField component
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: AppTextField(
                    hintText: context.l10n.searchCategoryHint,
                    prefixIcon:
                        Icon(Icons.search_rounded, color: colorScheme.outline),
                    fillColor: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    onChanged: (val) {
                      context.read<TransactionCubit>().filterSearch(val);
                    },
                  ),
                ),

                // Calendar Mode: Month Selector + Horizontal Date Strip
                if (_viewMode == 'calendar') ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => _pickMonth(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassStroke),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatMonthYear(_selectedMonth),
                                  style: customTypography.bodyLargeBold.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.expand_more_rounded,
                                    color: colorScheme.primary, size: 20),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          '${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                          style: customTypography.labelMediumMono.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildHorizontalDateSelector(),
                  const SizedBox(height: 8),
                ],

                // List Mode: Start & End Date Range Filter Bar
                if (_viewMode == 'list') ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDateRange(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: (_startDate != null && _endDate != null)
                                    ? AppColors.primaryContainer
                                        .withValues(alpha: 0.15)
                                    : colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (_startDate != null && _endDate != null)
                                      ? colorScheme.primary
                                          .withValues(alpha: 0.5)
                                      : AppColors.glassStroke,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.date_range_rounded,
                                    size: 18,
                                    color: (_startDate != null &&
                                            _endDate != null)
                                        ? colorScheme.primary
                                        : colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (_startDate != null && _endDate != null)
                                          ? '${_formatShortDate(_startDate!)} – ${_formatShortDate(_endDate!)}'
                                          : 'Filter by Date Range (All Time)',
                                      style: customTypography.labelMediumMono
                                          .copyWith(
                                        color: (_startDate != null &&
                                                _endDate != null)
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                        fontWeight: (_startDate != null &&
                                                _endDate != null)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_startDate != null && _endDate != null) ...[
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            color: colorScheme.outline,
                            onPressed: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                            tooltip: 'Clear Date Filter',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Transactions Content
                Expanded(
                  child: BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return const AllTransactionsShimmer();
                      }


                      if (state is TransactionLoaded) {
                        final items = state.filteredTransactions;
                        if (items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.l10n.noTransactionsFound,
                                  style:
                                      customTypography.bodyLargeBold.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.noTransactionsDesc,
                                  style: customTypography.bodyMedium.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        List<TransactionItem> displayItems = items;

                        // Filter by selected date in Calendar mode
                        if (_viewMode == 'calendar') {
                          displayItems = items.where((tx) {
                            return tx.timestamp.year == _selectedDate.year &&
                                tx.timestamp.month == _selectedDate.month &&
                                tx.timestamp.day == _selectedDate.day;
                          }).toList();

                          if (displayItems.isEmpty) {
                            return Center(
                              child: Text(
                                'No transactions on ${_formatDateKey(_selectedDate)}',
                                style: customTypography.bodyMedium.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            );
                          }
                        }

                        // Filter by date range in List mode
                        if (_viewMode == 'list' &&
                            _startDate != null &&
                            _endDate != null) {
                          final start = DateTime(_startDate!.year,
                              _startDate!.month, _startDate!.day);
                          final end = DateTime(_endDate!.year, _endDate!.month,
                              _endDate!.day, 23, 59, 59);

                          displayItems = items.where((tx) {
                            return tx.timestamp.isAfter(start.subtract(
                                    const Duration(seconds: 1))) &&
                                tx.timestamp.isBefore(
                                    end.add(const Duration(seconds: 1)));
                          }).toList();

                          if (displayItems.isEmpty) {
                            return Center(
                              child: Text(
                                'No transactions found in selected date range',
                                style: customTypography.bodyMedium.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            );
                          }
                        }

                        // Group transactions by Date
                        final Map<String, List<TransactionItem>> grouped = {};
                        for (final item in displayItems) {
                          final dateKey = _formatDateKey(item.timestamp);
                          grouped.putIfAbsent(dateKey, () => []).add(item);
                        }

                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => context
                              .read<TransactionCubit>()
                              .loadTransactions(),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: grouped.keys.length,
                            itemBuilder: (context, index) {
                              final dateKey = grouped.keys.elementAt(index);
                              final dateItems = grouped[dateKey]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dateKey.toUpperCase(),
                                          style: customTypography
                                              .labelMediumMono
                                              .copyWith(
                                            color: AppColors.outline,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Text(
                                          '${dateItems.length} Transaction${dateItems.length > 1 ? "s" : ""}',
                                          style: customTypography
                                              .labelMediumMono
                                              .copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Date Items
                                  ...dateItems.map(
                                    (tx) => _TransactionListTile(
                                      transaction: tx,
                                      isPrivacyModeNotifier:
                                          widget.isPrivacyModeNotifier,
                                      onDelete: () {
                                        context
                                            .read<TransactionCubit>()
                                            .deleteTransaction(tx.id);
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String mode,
    required String tooltip,
  }) {
    final isSelected = _viewMode == mode;
    final colorScheme = context.colorScheme;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => _toggleViewMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.black : colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalDateSelector() {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    final daysInMonth = DateUtils.getDaysInMonth(
        _selectedMonth.year, _selectedMonth.month);
    final List<DateTime> dates = List.generate(
      daysInMonth,
      (i) => DateTime(_selectedMonth.year, _selectedMonth.month, i + 1),
    );

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          final weekdayStr = weekdays[date.weekday - 1];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
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
                      fontSize: 10,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: customTypography.bodyLargeBold.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontSize: 18,
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

  String _formatMonthYear(DateTime dt) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _monthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatShortDate(DateTime dt) {
    return '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
  }

  String _formatDateKey(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final check = DateTime(dt.year, dt.month, dt.day);

    if (check == today) return 'Today';
    if (check == yesterday) return 'Yesterday';

    return '${_monthName(dt.month)} ${dt.day}, ${dt.year}';
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
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.semanticRed.withValues(alpha: 0.8),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassStroke),
        ),
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(transaction.categoryIcon),
                color: catColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

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
                      padding: const EdgeInsets.only(top: 2),
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
                final isIncome = transaction.isIncome;
                final sign = isIncome ? '+' : '-';
                final color =
                    isIncome ? AppColors.semanticGreen : AppColors.semanticRed;
                final symbol = getIt<PreferenceService>().currencySymbol;
                final amountText = isPrivacy
                    ? '•••••'
                    : '$sign$symbol${transaction.amount.toStringAsFixed(2)}';

                return Text(
                  amountText,
                  style: customTypography.headlineMediumMonoBold.copyWith(
                    color: color,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ],
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
