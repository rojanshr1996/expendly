import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/transaction_item.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';
import 'quick_add_page.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/events/transaction_events.dart';

@RoutePage()
class DailyEntryPage extends StatefulWidget {
  const DailyEntryPage({super.key});

  @override
  State<DailyEntryPage> createState() => _DailyEntryPageState();
}

class _DailyEntryPageState extends State<DailyEntryPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getIt<TransactionCubit>().loadTransactions();
    TransactionEvents.transactionUpdated.addListener(_onTransactionUpdated);
  }

  @override
  void dispose() {
    TransactionEvents.transactionUpdated.removeListener(_onTransactionUpdated);
    super.dispose();
  }

  void _onTransactionUpdated() {
    getIt<TransactionCubit>().loadTransactions();
  }

  void _changeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: context.colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getSymbol(String code) {
    return NumberFormat.simpleCurrency(name: code).currencySymbol;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customColors = context.customColors;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: LiquidGlassAppBar(
        title: const Text('Daily Entry'),
        actions: [
          TextButton.icon(
            onPressed: () => _changeDate(context),
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(DateFormat('MMM d').format(_selectedDate)),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
            ),
          )
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        bloc: getIt<TransactionCubit>(),
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<TransactionItem> dailyTransactions = [];
          if (state is TransactionLoaded) {
            dailyTransactions = state.transactions.where((tx) {
              return tx.timestamp.year == _selectedDate.year &&
                  tx.timestamp.month == _selectedDate.month &&
                  tx.timestamp.day == _selectedDate.day;
            }).toList();
          }

          return Column(
            children: [
              if (dailyTransactions.isNotEmpty)
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total for today:',
                        style: textTheme.bodyLarge
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        '${dailyTransactions.isNotEmpty ? _getSymbol(dailyTransactions.first.currencyCode) : "\$"}${dailyTransactions.fold(0.0, (sum, tx) => sum + (tx.type == TransactionType.expense ? tx.amount : -tx.amount)).toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: customColors.semanticRed,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: dailyTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 48, color: colorScheme.outlineVariant),
                            SizedBox(height: 16.h),
                            Text(
                              'No transactions on this date',
                              style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: dailyTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = dailyTransactions[index];
                          return GlassContainer(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(int.parse(tx
                                          .categoryColorHex
                                          .replaceFirst('#', '0xFF')))
                                      .withValues(alpha: 0.2),
                                  child: Icon(
                                    Icons.category,
                                    color: Color(int.parse(tx.categoryColorHex
                                        .replaceFirst('#', '0xFF'))),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.categoryName,
                                          style: textTheme.titleMedium),
                                      if (tx.note != null &&
                                          tx.note!.isNotEmpty)
                                        Text(tx.note!,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-${_getSymbol(tx.currencyCode)}${tx.amount.toStringAsFixed(2)}',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: customColors.semanticRed,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Entry'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => QuickAddBottomSheet(
                            initialDate: _selectedDate,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
