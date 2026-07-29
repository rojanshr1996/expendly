import 'package:flutter/material.dart';
import '../entities/analytics_report.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsReport> getAnalyticsReport({
    String period = 'Monthly',
    DateTimeRange? customRange,
  });
}
