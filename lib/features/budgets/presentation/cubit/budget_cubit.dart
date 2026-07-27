import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/budget_repository.dart';
import 'budget_state.dart';

@injectable
class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _repository;

  BudgetCubit(this._repository) : super(BudgetInitial());

  Future<void> loadBudgets() async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getBudgets();
      emit(BudgetLoaded(budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> setBudget({
    int? categoryId,
    required double targetAmount,
  }) async {
    try {
      await _repository.setBudget(
        categoryId: categoryId,
        targetAmount: targetAmount,
      );
      emit(const BudgetActionSuccess('Budget saved successfully'));
      await loadBudgets();
    } catch (e) {
      emit(BudgetError('Failed to save budget: ${e.toString()}'));
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _repository.deleteBudget(id);
      emit(const BudgetActionSuccess('Budget removed'));
      await loadBudgets();
    } catch (e) {
      emit(BudgetError('Failed to delete budget: ${e.toString()}'));
    }
  }
}
