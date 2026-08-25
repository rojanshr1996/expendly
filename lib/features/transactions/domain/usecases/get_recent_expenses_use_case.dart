import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/transaction_item.dart';
import '../repositories/transaction_repository.dart';

class GetRecentExpensesParams extends Equatable {
  final int limit;
  final TransactionType type;

  const GetRecentExpensesParams({
    this.limit = 10,
    this.type = TransactionType.expense,
  });

  @override
  List<Object?> get props => [limit, type];
}

@lazySingleton
class GetRecentExpensesUseCase
    implements UseCase<List<TransactionItem>, GetRecentExpensesParams> {
  final TransactionRepository repository;

  GetRecentExpensesUseCase(this.repository);

  @override
  Future<List<TransactionItem>> call(GetRecentExpensesParams params) async {
    return await repository.getRecentTransactions(
      limit: params.limit,
      type: params.type,
    );
  }
}
