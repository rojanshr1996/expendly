import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/analytics_repository.dart';
import 'analytics_state.dart';

@injectable
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;
  String currentPeriod = 'Monthly';
  DateTimeRange? currentCustomRange;

  AnalyticsCubit(this._repository) : super(AnalyticsInitial());

  Future<void> loadAnalytics({
    String? period,
    DateTimeRange? customRange,
  }) async {
    if (period != null) currentPeriod = period;
    if (customRange != null) currentCustomRange = customRange;

    if (isClosed) return;
    emit(AnalyticsLoading());
    try {
      final report = await _repository.getAnalyticsReport(
        period: currentPeriod,
        customRange: currentCustomRange,
      );
      if (isClosed) return;
      emit(AnalyticsLoaded(report));
    } catch (e) {
      if (isClosed) return;
      emit(AnalyticsError(e.toString()));
    }
  }
}
