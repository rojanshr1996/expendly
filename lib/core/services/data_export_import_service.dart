import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../database/enums/database_enums.dart';
import '../di/injection.dart';
import '../events/transaction_events.dart';
import '../utils/app_logger.dart';
import '../../features/analytics/domain/entities/analytics_report.dart';
import '../../features/budgets/presentation/cubit/budget_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'encryption_service.dart';
import 'preference_service.dart';

/// Data Export & Import Service utilizing AES-256 encryption.
/// Manages secure JSON serialization, AES-256 payload encryption, file saving,
/// and database restoration.
@lazySingleton
class DataExportImportService {
  final AppDatabase _db;
  final EncryptionService _encryptionService;
  final PreferenceService _preferenceService;

  DataExportImportService(
    this._db,
    this._encryptionService,
    this._preferenceService,
  );

  /// Exports a detailed Financial Analytics Report into Downloads/Expendly folder.
  Future<String> exportAnalyticsReportToCsv({
    required AnalyticsReport report,
    String periodName = 'Monthly',
    bool openAfterExport = true,
  }) async {
    try {
      final currency = _preferenceService.currencyCode;
      final buffer = StringBuffer();

      buffer.writeln('===============================================');
      buffer.writeln('EXPENDLY FINANCIAL ANALYTICS & TREND REPORT');
      buffer.writeln('Generated Date,${DateTime.now().toIso8601String().substring(0, 19)}');
      buffer.writeln('Period,${report.periodName}');
      buffer.writeln('Currency,$currency');
      buffer.writeln('===============================================');
      buffer.writeln('');

      // KPI Summary Section
      buffer.writeln('--- FINANCIAL SUMMARY ---');
      buffer.writeln('Metric,Amount');
      buffer.writeln('Total Income,${report.totalIncome.toStringAsFixed(2)}');
      buffer.writeln('Total Expenses,${report.totalExpense.toStringAsFixed(2)}');
      buffer.writeln('Net Savings,${report.netSavings.toStringAsFixed(2)}');
      buffer.writeln('Savings Rate,${report.savingsRatePercentage.toStringAsFixed(1)}%');
      buffer.writeln('Average Daily Spend,${report.avgDailySpend.toStringAsFixed(2)}');
      buffer.writeln('Budget Health,${report.budgetHealthPercentage.toStringAsFixed(0)}% (${report.budgetHealthStatus})');
      buffer.writeln('');

      // Top Category Insights
      if (report.topCategoryName != null) {
        buffer.writeln('--- HIGHLIGHT INSIGHTS ---');
        buffer.writeln('Top Expense Category,"${report.topCategoryName}"');
        buffer.writeln('Top Category Share,${report.topCategoryPercentage?.toStringAsFixed(1)}%');
        buffer.writeln('');
      }

      // Category Breakdown Table
      buffer.writeln('--- CATEGORY BREAKDOWN ---');
      buffer.writeln('Category,Amount,Percentage Share');
      for (final cat in report.categoryBreakdowns) {
        final catEscaped = cat.categoryName.replaceAll('"', '""');
        buffer.writeln('"$catEscaped",${cat.amount.toStringAsFixed(2)},${cat.percentage.toStringAsFixed(1)}%');
      }
      buffer.writeln('');

      // Detailed Transactions
      final categoriesList = await _db.select(_db.categories).get();
      final transactionsList = await _db.select(_db.transactions).get();
      final categoryMap = {for (var c in categoriesList) c.id: c.name};

      buffer.writeln('--- ITEMIZATION LIST ---');
      buffer.writeln('ID,Date,Type,Category,Amount,Payment Method,Note');
      for (final t in transactionsList) {
        final catName = categoryMap[t.categoryId] ?? 'Uncategorized';
        final amountFormatted = (t.amount / 100.0).toStringAsFixed(2);
        final dateStr = t.timestamp.toIso8601String().replaceAll('T', ' ').substring(0, 19);
        final typeStr = t.type.name.toUpperCase();
        final pmStr = t.paymentMethod?.name.toUpperCase() ?? '';
        final noteEscaped = (t.note ?? '').replaceAll('"', '""');

        buffer.writeln('${t.id},"$dateStr","$typeStr","$catName",$amountFormatted,"$pmStr","$noteEscaped"');
      }

      final exportDir = await _getExportDirectory();
      final fileName = 'expendly_financial_report_${report.periodName.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = p.join(exportDir.path, fileName);
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      AppLogger.i('DataExportImportService: Financial Report exported to $filePath');

      if (openAfterExport) {
        await OpenFile.open(filePath, type: 'text/csv');
      }

      return filePath;
    } catch (e, stack) {
      AppLogger.e('DataExportImportService: Analytics CSV Export failed', e, stack);
      rethrow;
    }
  }

  /// Exports all application data into an AES-256 encrypted .expendly file.
  Future<Map<String, dynamic>> exportEncryptedData({String? passphrase}) async {
    try {
      final categoriesList = await _db.select(_db.categories).get();
      final transactionsList = await _db.select(_db.transactions).get();
      final budgetsList = await _db.select(_db.budgets).get();

      final exportPayload = {
        'version': 1,
        'app': 'Expendly',
        'exportedAt': DateTime.now().toIso8601String(),
        'currencyCode': _preferenceService.currencyCode,
        'currencySymbol': _preferenceService.currencySymbol,
        'categories': categoriesList.map((c) => {
          'id': c.id,
          'name': c.name,
          'icon': c.icon,
          'color': c.color,
          'type': c.type.name,
          'isDefault': c.isDefault,
          'sortOrder': c.sortOrder,
        }).toList(),
        'budgets': budgetsList.map((b) => {
          'id': b.id,
          'categoryId': b.categoryId,
          'targetAmount': b.targetAmount,
          'period': b.period.name,
          'year': b.year,
          'month': b.month,
          'currencyCode': b.currencyCode,
          'notifyAtThreshold': b.notifyAtThreshold,
          'thresholdPercentage': b.thresholdPercentage,
        }).toList(),
        'transactions': transactionsList.map((t) => {
          'id': t.id,
          'type': t.type.name,
          'amount': t.amount,
          'categoryId': t.categoryId,
          'timestamp': t.timestamp.toIso8601String(),
          'note': t.note,
          'paymentMethod': t.paymentMethod?.name,
          'currencyCode': t.currencyCode,
        }).toList(),
      };

      final jsonString = jsonEncode(exportPayload);

      // Encrypt string with AES-256
      final encryptedPayload = await _encryptionService.encryptString(
        jsonString,
        customKeyOrPassphrase: passphrase,
      );

      // Resolve platform export directory (Download/Expendly for Android, Documents/Expendly for iOS)
      final exportDir = await _getExportDirectory();
      final fileName = 'expendly_backup_${DateTime.now().millisecondsSinceEpoch}.expendly';
      final filePath = p.join(exportDir.path, fileName);
      final file = File(filePath);
      await file.writeAsString(encryptedPayload);

      AppLogger.i('DataExportImportService: AES-256 backup saved to $filePath');

      return {
        'filePath': filePath,
        'fileName': fileName,
        'payload': encryptedPayload,
        'transactionCount': transactionsList.length,
        'budgetCount': budgetsList.length,
      };
    } catch (e, stack) {
      AppLogger.e('DataExportImportService: Export failed', e, stack);
      rethrow;
    }
  }

  /// Exports transactions to a standard .csv file in Expenditure platform folder,
  /// and prompts user to open file with external app (Google Sheets, Excel, Browser, etc.) via open_file_plus.
  Future<String> exportDataToCsv({bool openAfterExport = true}) async {
    try {
      final categoriesList = await _db.select(_db.categories).get();
      final transactionsList = await _db.select(_db.transactions).get();

      final categoryMap = {for (var c in categoriesList) c.id: c.name};

      final buffer = StringBuffer();
      // CSV Header
      buffer.writeln('ID,Date,Type,Category,Amount,Currency,Payment Method,Note');

      for (final t in transactionsList) {
        final catName = categoryMap[t.categoryId] ?? 'Uncategorized';
        final amountFormatted = (t.amount / 100.0).toStringAsFixed(2);
        final dateStr = t.timestamp.toIso8601String().replaceAll('T', ' ').substring(0, 19);
        final typeStr = t.type.name.toUpperCase();
        final pmStr = t.paymentMethod?.name.toUpperCase() ?? '';
        final noteEscaped = (t.note ?? '').replaceAll('"', '""');

        buffer.writeln('${t.id},"$dateStr","$typeStr","$catName",$amountFormatted,"${t.currencyCode}","$pmStr","$noteEscaped"');
      }

      final exportDir = await _getExportDirectory();
      final fileName = 'expendly_transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = p.join(exportDir.path, fileName);
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      AppLogger.i('DataExportImportService: CSV file exported to $filePath');

      if (openAfterExport) {
        final openResult = await OpenFile.open(filePath, type: 'text/csv');
        AppLogger.i('DataExportImportService: OpenFile result: ${openResult.type} ${openResult.message}');
      }

      return filePath;
    } catch (e, stack) {
      AppLogger.e('DataExportImportService: CSV Export failed', e, stack);
      rethrow;
    }
  }

  /// Restores application data from an AES-256 encrypted payload.
  Future<int> importEncryptedData(String encryptedPayload, {String? passphrase}) async {
    try {
      final decryptedJsonString = await _encryptionService.decryptString(
        encryptedPayload.trim(),
        customKeyOrPassphrase: passphrase,
      );

      final Map<String, dynamic> data = jsonDecode(decryptedJsonString);
      if (data['app'] != 'Expendly' && data['categories'] == null) {
        throw const FormatException('Invalid Expendly backup payload format.');
      }

      final categoriesData = (data['categories'] as List? ?? []);
      final budgetsData = (data['budgets'] as List? ?? []);
      final transactionsData = (data['transactions'] as List? ?? []);

      await _db.transaction(() async {
        // Clear existing transactions & budgets before import
        await _db.delete(_db.transactions).go();
        await _db.delete(_db.budgets).go();

        // Restore Categories
        for (final item in categoriesData) {
          final catType = TransactionType.values.firstWhere(
            (e) => e.name == item['type'],
            orElse: () => TransactionType.expense,
          );
          await _db.into(_db.categories).insertOnConflictUpdate(
                CategoriesCompanion.insert(
                  id: Value(item['id'] as int),
                  name: item['name'] as String,
                  icon: item['icon'] as String,
                  color: item['color'] as String,
                  type: catType,
                  isDefault: Value(item['isDefault'] as bool? ?? false),
                  sortOrder: Value(item['sortOrder'] as int? ?? 0),
                ),
              );
        }

        // Restore Budgets
        for (final item in budgetsData) {
          final period = BudgetPeriod.values.firstWhere(
            (e) => e.name == item['period'],
            orElse: () => BudgetPeriod.monthly,
          );
          final int targetAmountInt = (item['targetAmount'] is int)
              ? (item['targetAmount'] as int)
              : ((item['targetAmount'] as num) * 100).round();

          await _db.into(_db.budgets).insertOnConflictUpdate(
                BudgetsCompanion.insert(
                  id: Value(item['id'] as int),
                  categoryId: Value(item['categoryId'] as int?),
                  targetAmount: targetAmountInt,
                  period: period,
                  year: Value(item['year'] as int? ?? DateTime.now().year),
                  month: Value(item['month'] as int? ?? DateTime.now().month),
                  currencyCode: Value(item['currencyCode'] as String? ?? 'USD'),
                  notifyAtThreshold: Value(item['notifyAtThreshold'] as bool? ?? true),
                  thresholdPercentage: Value(item['thresholdPercentage'] as int? ?? 80),
                ),
              );
        }

        // Restore Transactions
        for (final item in transactionsData) {
          final txType = TransactionType.values.firstWhere(
            (e) => e.name == item['type'],
            orElse: () => TransactionType.expense,
          );
          PaymentMethod? pm;
          if (item['paymentMethod'] != null) {
            try {
              pm = PaymentMethod.values.firstWhere((e) => e.name == item['paymentMethod']);
            } catch (_) {}
          }
          final int amountInt = (item['amount'] is int)
              ? (item['amount'] as int)
              : ((item['amount'] as num) * 100).round();

          await _db.into(_db.transactions).insertOnConflictUpdate(
                TransactionsCompanion.insert(
                  id: Value(item['id'] as int),
                  type: txType,
                  amount: amountInt,
                  categoryId: item['categoryId'] as int,
                  timestamp: DateTime.parse(item['timestamp'] as String),
                  note: Value(item['note'] as String?),
                  paymentMethod: Value(pm),
                  currencyCode: Value(item['currencyCode'] as String? ?? 'USD'),
                ),
              );
        }
      });

      // Update preferences if available
      if (data['currencyCode'] != null && data['currencySymbol'] != null) {
        await _preferenceService.setCurrency(
          code: data['currencyCode'] as String,
          symbol: data['currencySymbol'] as String,
        );
      }

      // Notify app-wide listeners and Cubits
      TransactionEvents.notifyUpdated();
      try {
        getIt<BudgetCubit>().loadBudgets();
      } catch (_) {}
      try {
        getIt<DashboardCubit>().loadDashboardData();
      } catch (_) {}

      AppLogger.i('DataExportImportService: Data imported successfully (${transactionsData.length} transactions)');
      return transactionsData.length;
    } catch (e, stack) {
      AppLogger.e('DataExportImportService: Import failed', e, stack);
      rethrow;
    }
  }

  /// Resolves user-visible platform export directory:
  /// - Android: `/storage/emulated/0/Download/Expendly` or `Downloads/Expendly`
  /// - iOS: `Documents/Expendly`
  Future<Directory> _getExportDirectory() async {
    Directory targetDir;
    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        targetDir = Directory('/storage/emulated/0/Download/Expendly');
      } else {
        final downloads = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        targetDir = Directory(p.join(downloads.path, 'Expendly'));
      }
    } else if (Platform.isIOS) {
      final docsDir = await getApplicationDocumentsDirectory();
      targetDir = Directory(p.join(docsDir.path, 'Expendly'));
    } else {
      final docsDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      targetDir = Directory(p.join(docsDir.path, 'Expendly'));
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }
}
