import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/events/transaction_events.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../domain/repositories/budget_repository.dart';
import 'budget_state.dart';

@lazySingleton
class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _repository;

  BudgetCubit(this._repository) : super(BudgetInitial()) {
    TransactionEvents.transactionUpdated.addListener(_onTransactionUpdated);
  }

  void _onTransactionUpdated() {
    if (!isClosed) {
      loadBudgets();
    }
  }

  @override
  Future<void> close() {
    TransactionEvents.transactionUpdated
        .removeListener(_onTransactionUpdated);
    return super.close();
  }

  Future<void> loadBudgets() async {
    if (isClosed) return;
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getBudgets();
      if (isClosed) return;
      emit(BudgetLoaded(budgets));
    } catch (e) {
      if (isClosed) return;
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> setBudget({
    int? categoryId,
    required double targetAmount,
    BudgetPeriod period = BudgetPeriod.monthly,
    bool notifyAtThreshold = true,
    int thresholdPercentage = 80,
  }) async {
    if (isClosed) return;
    try {
      await _repository.setBudget(
        categoryId: categoryId,
        targetAmount: targetAmount,
        period: period,
        notifyAtThreshold: notifyAtThreshold,
        thresholdPercentage: thresholdPercentage,
      );
      if (isClosed) return;
      emit(const BudgetActionSuccess('Budget saved successfully'));
      await loadBudgets();
      _refreshDashboard();
    } catch (e) {
      final msg = e
          .toString()
          .replaceAll('StateError: ', '')
          .replaceAll('Exception: ', '')
          .replaceAll('Failed to save budget: ', '');
      if (isClosed) return;
      emit(BudgetError(msg));
    }
  }

  Future<void> deleteBudget(int id) async {
    if (isClosed) return;
    try {
      await _repository.deleteBudget(id);
      if (isClosed) return;
      emit(const BudgetActionSuccess('Budget removed'));
      await loadBudgets();
      _refreshDashboard();
    } catch (e) {
      if (isClosed) return;
      emit(BudgetError('Failed to delete budget: ${e.toString()}'));
    }
  }

  void _refreshDashboard() {
    try {
      getIt<DashboardCubit>().loadDashboardData();
    } catch (_) {}
  }
}
