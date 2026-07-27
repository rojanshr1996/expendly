import '../entities/analytics_report.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsReport> getAnalyticsReport();
}
