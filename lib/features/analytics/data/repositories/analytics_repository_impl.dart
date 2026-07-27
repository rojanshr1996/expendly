import 'package:injectable/injectable.dart';

import '../../domain/entities/analytics_report.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_local_datasource.dart';

@LazySingleton(as: AnalyticsRepository)
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsLocalDataSource _localDataSource;

  AnalyticsRepositoryImpl(this._localDataSource);

  @override
  Future<AnalyticsReport> getAnalyticsReport() =>
      _localDataSource.getAnalyticsReport();
}
