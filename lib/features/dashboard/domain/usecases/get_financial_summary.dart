import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/financial_summary.dart';
import '../repositories/dashboard_repository.dart';

@lazySingleton
class GetFinancialSummary implements UseCase<FinancialSummary, NoParams> {
  final DashboardRepository repository;

  GetFinancialSummary(this.repository);

  @override
  Future<FinancialSummary> call(NoParams params) async {
    return await repository.getFinancialSummary();
  }
}
