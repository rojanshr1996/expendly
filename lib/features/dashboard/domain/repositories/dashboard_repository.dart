import '../entities/financial_summary.dart';

/// Abstract repository contract for Dashboard domain logic.
abstract class DashboardRepository {
  Future<FinancialSummary> getFinancialSummary();
}
