import 'package:equatable/equatable.dart';

/// Abstract UseCase interface for domain logic operations.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// NoParams placeholder for usecases that require no arguments.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
