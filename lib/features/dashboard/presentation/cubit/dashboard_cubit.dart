import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_financial_summary.dart';
import 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final GetFinancialSummary _getFinancialSummary;

  DashboardCubit(this._getFinancialSummary) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final summary = await _getFinancialSummary(NoParams());
      emit(DashboardLoaded(summary));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
