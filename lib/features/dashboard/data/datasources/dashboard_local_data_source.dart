import 'package:injectable/injectable.dart';

import '../models/financial_summary_model.dart';

abstract class DashboardLocalDataSource {
  Future<FinancialSummaryModel> getFinancialSummary();
}

@LazySingleton(as: DashboardLocalDataSource)
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  @override
  Future<FinancialSummaryModel> getFinancialSummary() async {
    // Simulated local data fetch for initial core implementation
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return FinancialSummaryModel(
      totalBalance: 14850.50,
      totalIncome: 18500.00,
      totalExpense: 3649.50,
      currencySymbol: '\$',
      periodStart: DateTime(now.year, now.month, 1),
      periodEnd: now,
    );
  }
}
