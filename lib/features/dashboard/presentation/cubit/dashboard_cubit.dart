import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/events/transaction_events.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_financial_summary.dart';
import 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final GetFinancialSummary _getFinancialSummary;

  DashboardCubit(this._getFinancialSummary) : super(DashboardInitial()) {
    TransactionEvents.transactionUpdated.addListener(_onTransactionUpdated);
  }

  void _onTransactionUpdated() {
    if (!isClosed) {
      loadDashboardData();
    }
  }

  @override
  Future<void> close() {
    TransactionEvents.transactionUpdated.removeListener(_onTransactionUpdated);
    return super.close();
  }

  Future<void> loadDashboardData() async {
    if (isClosed) return;
    emit(DashboardLoading());
    try {
      final summary = await _getFinancialSummary(NoParams());
      if (isClosed) return;
      emit(DashboardLoaded(summary));
    } catch (e) {
      if (isClosed) return;
      emit(DashboardError(e.toString()));
    }
  }
}
