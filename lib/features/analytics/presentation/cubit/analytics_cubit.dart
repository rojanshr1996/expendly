import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/analytics_repository.dart';
import 'analytics_state.dart';

@injectable
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsCubit(this._repository) : super(AnalyticsInitial());

  Future<void> loadAnalytics() async {
    emit(AnalyticsLoading());
    try {
      final report = await _repository.getAnalyticsReport();
      emit(AnalyticsLoaded(report));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
