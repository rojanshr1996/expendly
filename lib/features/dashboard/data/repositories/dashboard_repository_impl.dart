import 'package:injectable/injectable.dart';

import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl(this.localDataSource);

  @override
  Future<FinancialSummary> getFinancialSummary() async {
    return await localDataSource.getFinancialSummary();
  }
}
