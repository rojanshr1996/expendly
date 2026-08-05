import 'package:equatable/equatable.dart';

/// Result of a CSV backup operation.
class CsvBackupResult extends Equatable {
  final String? filePath;
  final DateTime timestamp;
  final int transactionCount;
  final int totalRecordCount;
  final int sizeBytes;
  final bool isSuccess;
  final String? errorMessage;

  const CsvBackupResult({
    this.filePath,
    required this.timestamp,
    this.transactionCount = 0,
    this.totalRecordCount = 0,
    this.sizeBytes = 0,
    this.isSuccess = true,
    this.errorMessage,
  });

  factory CsvBackupResult.success({
    required String filePath,
    required int transactionCount,
    required int totalRecordCount,
    required int sizeBytes,
  }) {
    return CsvBackupResult(
      filePath: filePath,
      timestamp: DateTime.now(),
      transactionCount: transactionCount,
      totalRecordCount: totalRecordCount,
      sizeBytes: sizeBytes,
      isSuccess: true,
    );
  }

  factory CsvBackupResult.failure(String error) {
    return CsvBackupResult(
      timestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: error,
    );
  }

  @override
  List<Object?> get props => [
        filePath,
        timestamp,
        transactionCount,
        totalRecordCount,
        sizeBytes,
        isSuccess,
        errorMessage,
      ];
}

/// Per-section import counts returned after restoring a CSV backup.
class CsvImportResult extends Equatable {
  final int transactionsImported;
  final int categoriesImported;
  final int subcategoriesImported;
  final int tagsImported;
  final int budgetsImported;
  final int recurringImported;
  final int profilesImported;
  final int transactionTagsImported;
  final int skippedCount;
  final List<String> errors;
  final bool isSuccess;

  const CsvImportResult({
    this.transactionsImported = 0,
    this.categoriesImported = 0,
    this.subcategoriesImported = 0,
    this.tagsImported = 0,
    this.budgetsImported = 0,
    this.recurringImported = 0,
    this.profilesImported = 0,
    this.transactionTagsImported = 0,
    this.skippedCount = 0,
    this.errors = const [],
    this.isSuccess = true,
  });

  factory CsvImportResult.failure(String error) {
    return CsvImportResult(
      errors: [error],
      isSuccess: false,
    );
  }

  int get totalImported =>
      transactionsImported +
      categoriesImported +
      subcategoriesImported +
      tagsImported +
      budgetsImported +
      recurringImported +
      profilesImported +
      transactionTagsImported;

  @override
  List<Object?> get props => [
        transactionsImported,
        categoriesImported,
        subcategoriesImported,
        tagsImported,
        budgetsImported,
        recurringImported,
        profilesImported,
        transactionTagsImported,
        skippedCount,
        errors,
        isSuccess,
      ];
}
