import 'package:equatable/equatable.dart';

/// Base Failure class representing domain-level error objects in Expendly.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Local Database Error Occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local Cache Error Occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Input Validation Failed']);
}
