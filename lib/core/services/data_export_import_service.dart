import 'dart:io';

import 'package:drift/drift.dart';
import 'package:expendly/core/services/storage/backup_storage_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/analytics/domain/entities/analytics_report.dart';
import '../../features/budgets/presentation/cubit/budget_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../database/app_database.dart';
import '../database/enums/database_enums.dart';
import '../di/injection.dart';
import '../events/transaction_events.dart';
import '../models/backup_result.dart';
import '../utils/app_logger.dart';
import 'pdf_report_service.dart';
import 'preference_service.dart';

/// Backup file name — single file, always overwritten.
const String kBackupFileName = 'expendly_backup.csv';

/// Section tags used in the multi-section backup CSV.
const String _sMeta = 'META';
const String _sCategories = 'CATEGORIES';
const String _sSubcategories = 'SUBCATEGORIES';
const String _sTags = 'TAGS';
const String _sBudgets = 'BUDGETS';
const String _sRecurring = 'RECURRING_TRANSACTIONS';
const String _sTransactions = 'TRANSACTIONS';
const String _sTransactionTags = 'TRANSACTION_TAGS';
const String _sUserProfiles = 'USER_PROFILES';

/// Multi-section CSV data import and export service.
///
/// Features:
///  - [exportAnalyticsReportToCsv] — export financial reports to Downloads/Expendly
///  - [exportAnalyticsReportToPdf] — export visual PDF financial reports with charts & insights
///  - [exportBackupCsv]            — full app backup using BackupStorageProvider
///  - [importBackupCsv]            — restore from a [kBackupFileName] file
///  - [findBackupFile]             — locate the current backup file
@lazySingleton
class DataExportImportService {
  final AppDatabase _db;
  final PreferenceService _preferenceService;
  final BackupStorageProvider _storageProvider;

  DataExportImportService(
    this._db,
    this._preferenceService, [
    BackupStorageProvider? storageProvider,
  ]) : _storageProvider =
            storageProvider ?? BackupStorageProviderFactory.create();

  // ── Analytics PDF ─────────────────────────────────────────────────────────

  /// Exports a detailed Financial Analytics Report in PDF format with visual charts
  /// and explanatory narratives into Downloads/Expendly.
  Future<String> exportAnalyticsReportToPdf({
    required AnalyticsReport report,
    String periodName = 'Monthly',
    bool openAfterExport = true,
  }) async {
    try {
      final currency = _preferenceService.currencySymbol;
      final categoriesList = await _db.select(_db.categories).get();
      final transactionsList = await _db.select(_db.transactions).get();
      final categoryMap = {for (var c in categoriesList) c.id: c.name};

      final formattedTransactions = transactionsList.map((t) {
        return {
          'id': t.id,
          'date': t.timestamp.toIso8601String().replaceAll('T', ' '),
          'type': t.type.name,
          'category': categoryMap[t.categoryId] ?? 'Uncategorized',
          'amount': t.amount / 100.0,
          'paymentMethod': t.paymentMethod?.name ?? '',
          'note': t.note ?? '',
        };
      }).toList();

      final pdfService = PdfReportService();
      final filePath = await pdfService.generateAnalyticsReportPdf(
        report: report,
        currencySymbol: currency,
        transactions: formattedTransactions,
        periodName: report.periodName,
      );

      if (openAfterExport) {
        await OpenFile.open(filePath, type: 'application/pdf');
      }

      return filePath;
    } catch (e, stack) {
      AppLogger.e(
          'DataExportImportService: Analytics PDF Export failed', e, stack);
      rethrow;
    }
  }

  // ── Analytics CSV ─────────────────────────────────────────────────────────

  /// Exports a detailed Financial Analytics Report into Downloads/Expendly.
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
      buffer.writeln(
          'Generated Date,${DateTime.now().toIso8601String().substring(0, 19)}');
      buffer.writeln('Period,${report.periodName}');
      buffer.writeln('Currency,$currency');
      buffer.writeln('===============================================');
      buffer.writeln('');

      buffer.writeln('--- FINANCIAL SUMMARY ---');
      buffer.writeln('Metric,Amount');
      buffer.writeln('Total Income,${report.totalIncome.toStringAsFixed(2)}');
      buffer
          .writeln('Total Expenses,${report.totalExpense.toStringAsFixed(2)}');
      buffer.writeln('Net Savings,${report.netSavings.toStringAsFixed(2)}');
      buffer.writeln(
          'Savings Rate,${report.savingsRatePercentage.toStringAsFixed(1)}%');
      buffer.writeln(
          'Average Daily Spend,${report.avgDailySpend.toStringAsFixed(2)}');
      buffer.writeln(
          'Budget Health,${report.budgetHealthPercentage.toStringAsFixed(0)}% (${report.budgetHealthStatus})');
      buffer.writeln('');

      if (report.topCategoryName != null) {
        buffer.writeln('--- HIGHLIGHT INSIGHTS ---');
        buffer.writeln('Top Expense Category,"${report.topCategoryName}"');
        buffer.writeln(
            'Top Category Share,${report.topCategoryPercentage?.toStringAsFixed(1)}%');
        buffer.writeln('');
      }

      buffer.writeln('--- CATEGORY BREAKDOWN ---');
      buffer.writeln('Category,Amount,Percentage Share');
      for (final cat in report.categoryBreakdowns) {
        final catEscaped = cat.categoryName.replaceAll('"', '""');
        buffer.writeln(
            '"$catEscaped",${cat.amount.toStringAsFixed(2)},${cat.percentage.toStringAsFixed(1)}%');
      }
      buffer.writeln('');

      final categoriesList = await _db.select(_db.categories).get();
      final transactionsList = await _db.select(_db.transactions).get();
      final categoryMap = {for (var c in categoriesList) c.id: c.name};

      buffer.writeln('--- ITEMIZATION LIST ---');
      buffer.writeln('ID,Date,Type,Category,Amount,Payment Method,Note');
      for (final t in transactionsList) {
        final catName = categoryMap[t.categoryId] ?? 'Uncategorized';
        final amountFormatted = (t.amount / 100.0).toStringAsFixed(2);
        final dateStr =
            t.timestamp.toIso8601String().replaceAll('T', ' ').substring(0, 19);
        final typeStr = t.type.name.toUpperCase();
        final pmStr = t.paymentMethod?.name.toUpperCase() ?? '';
        final noteEscaped = (t.note ?? '').replaceAll('"', '""');
        buffer.writeln(
            '${t.id},"$dateStr","$typeStr","$catName",$amountFormatted,"$pmStr","$noteEscaped"');
      }

      final exportDir = await _getExportDirectory();
      final fileName =
          'expendly_financial_report_${report.periodName.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = p.join(exportDir.path, fileName);
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      AppLogger.i(
          'DataExportImportService: Financial Report exported to $filePath');

      if (openAfterExport) {
        await OpenFile.open(filePath, type: 'text/csv');
      }

      return filePath;
    } catch (e, stack) {
      AppLogger.e(
          'DataExportImportService: Analytics CSV Export failed', e, stack);
      rethrow;
    }
  }

  // ── Transaction CSV (for Sheets / Excel) ─────────────────────────────────

  /// Exports transactions to a standard .csv file in the export directory,
  /// suitable for opening in Google Sheets, Excel, etc.
  Future<String> exportDataToCsv({bool openAfterExport = true}) async {
    try {
      final categoriesList = await _db.select(_db.categories).get();
      final transactionsList = await _db.select(_db.transactions).get();

      final categoryMap = {for (var c in categoriesList) c.id: c.name};

      final buffer = StringBuffer();
      buffer
          .writeln('ID,Date,Type,Category,Amount,Currency,Payment Method,Note');

      for (final t in transactionsList) {
        final catName = categoryMap[t.categoryId] ?? 'Uncategorized';
        final amountFormatted = (t.amount / 100.0).toStringAsFixed(2);
        final dateStr =
            t.timestamp.toIso8601String().replaceAll('T', ' ').substring(0, 19);
        final typeStr = t.type.name.toUpperCase();
        final pmStr = t.paymentMethod?.name.toUpperCase() ?? '';
        final noteEscaped = (t.note ?? '').replaceAll('"', '""');
        buffer.writeln(
            '${t.id},"$dateStr","$typeStr","$catName",$amountFormatted,"${t.currencyCode}","$pmStr","$noteEscaped"');
      }

      final exportDir = await _getExportDirectory();
      final fileName =
          'expendly_transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = p.join(exportDir.path, fileName);
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      AppLogger.i('DataExportImportService: CSV file exported to $filePath');

      if (openAfterExport) {
        final openResult = await OpenFile.open(filePath, type: 'text/csv');
        AppLogger.i(
            'DataExportImportService: OpenFile result: ${openResult.type} ${openResult.message}');
      }

      return filePath;
    } catch (e, stack) {
      AppLogger.e('DataExportImportService: CSV Export failed', e, stack);
      rethrow;
    }
  }

  // ── Full Backup CSV ───────────────────────────────────────────────────────

  /// Exports all restorable app data to [kBackupFileName] in the export
  /// directory, overwriting any previous backup.
  ///
  /// Data included: categories, subcategories, tags, budgets,
  /// recurring transactions, transactions, transaction-tags, user profiles.
  /// Excluded: attachments (device-specific paths), image paths on profiles.
  Future<CsvBackupResult> exportBackupCsv() async {
    try {
      await _db.checkpointForBackup();

      final categoriesList = await _db.select(_db.categories).get();
      final subcategoriesList = await _db.select(_db.subcategories).get();
      final tagsList = await _db.select(_db.tags).get();
      final budgetsList = await _db.select(_db.budgets).get();
      final recurringList = await _db.select(_db.recurringTransactions).get();
      final transactionsList = await _db.select(_db.transactions).get();
      final transactionTagsList = await _db.select(_db.transactionTags).get();
      final userProfilesList = await _db.select(_db.userProfiles).get();

      final content = _buildBackupCsvContent(
        categories: categoriesList,
        subcategories: subcategoriesList,
        tags: tagsList,
        budgets: budgetsList,
        recurring: recurringList,
        transactions: transactionsList,
        transactionTags: transactionTagsList,
        userProfiles: userProfilesList,
      );

      final filename = await getBackupFileName();
      final savedPath = await _storageProvider.writeBackup(
        filename: filename,
        content: content,
      );

      final sizeBytes = content.length;
      final totalRecordCount = categoriesList.length +
          subcategoriesList.length +
          tagsList.length +
          budgetsList.length +
          recurringList.length +
          transactionsList.length +
          transactionTagsList.length +
          userProfilesList.length;

      AppLogger.i('DataExportImportService: Backup saved to $savedPath '
          '(${transactionsList.length} transactions, $totalRecordCount total records)');

      return CsvBackupResult.success(
        filePath: savedPath,
        transactionCount: transactionsList.length,
        totalRecordCount: totalRecordCount,
        sizeBytes: sizeBytes,
      );
    } catch (e, stack) {
      AppLogger.e('DataExportImportService: Backup export failed', e, stack);
      return CsvBackupResult.failure(e.toString());
    }
  }

  /// Returns dynamic backup file name based on app version (e.g. `expendly_backup_1_0_0.csv`).
  Future<String> getBackupFileName() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final versionFormatted =
          info.version.replaceAll('.', '_').replaceAll('+', '_');
      return 'expendly_backup_$versionFormatted.csv';
    } catch (_) {
      return kBackupFileName;
    }
  }

  /// Returns the current backup [File] if it exists, else `null`.
  /// Scans candidate export locations and returns the file with the latest modification timestamp.
  Future<File?> findBackupFile() async {
    try {
      final candidateDirs = <Directory>[];

      try {
        final exportDir = await _getExportDirectory();
        candidateDirs.add(exportDir);
      } catch (_) {}

      if (Platform.isAndroid) {
        try {
          final external = await getExternalStorageDirectory();
          if (external != null)
            candidateDirs.add(Directory(p.join(external.path, 'Expendly')));
        } catch (_) {}
        try {
          final downloads = await getDownloadsDirectory();
          if (downloads != null)
            candidateDirs.add(Directory(p.join(downloads.path, 'Expendly')));
        } catch (_) {}
        candidateDirs.add(Directory('/storage/emulated/0/Download/Expendly'));
      }

      try {
        final docs = await getApplicationDocumentsDirectory();
        candidateDirs.add(Directory(p.join(docs.path, 'Expendly')));
      } catch (_) {}

      File? latestFile;
      DateTime? latestModTime;
      final checkedPaths = <String>{};

      for (final dir in candidateDirs) {
        if (checkedPaths.contains(dir.path)) continue;
        checkedPaths.add(dir.path);

        if (!await dir.exists()) continue;
        try {
          final entities = dir.listSync();
          for (final entity in entities) {
            if (entity is File) {
              final name = p.basename(entity.path);
              if (name.startsWith('expendly_backup') ||
                  name.startsWith('expense_backup')) {
                try {
                  final modTime = await entity.lastModified();
                  if (latestModTime == null || modTime.isAfter(latestModTime)) {
                    latestModTime = modTime;
                    latestFile = entity;
                  }
                } catch (_) {
                  latestFile ??= entity;
                }
              }
            }
          }
        } catch (_) {}
      }

      return latestFile;
    } catch (e) {
      AppLogger.d('DataExportImportService: findBackupFile error: $e');
      return null;
    }
  }

  /// Parses and imports a CSV backup file.
  ///
  /// Validates section headers before touching the database. Runs all
  /// inserts inside a single Drift transaction; any failure rolls back
  /// automatically and returns a [CsvImportResult.failure].
  Future<CsvImportResult> importBackupCsv(String filePath,
      {String? rawContent}) async {
    try {
      final String content;
      if (rawContent != null && rawContent.isNotEmpty) {
        content = rawContent;
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          return CsvImportResult.failure('Backup file not found: $filePath');
        }

        try {
          content = await file.readAsString();
        } catch (e) {
          if (e.toString().contains('Permission denied') ||
              e.toString().contains('errno = 13') ||
              e is FileSystemException) {
            AppLogger.w(
                'DataExportImportService: Permission denied reading $filePath: $e');
            return CsvImportResult.failure(
              'Permission denied: Android requires selecting the file via the file browser after reinstalling the app.',
            );
          }
          rethrow;
        }
      }

      final sections = _parseSectionedCsv(content);

      // ── Schema validation ──────────────────────────────────────────────
      final validationError = _validateSections(sections);
      if (validationError != null) {
        AppLogger.w(
            'DataExportImportService: Schema validation failed: $validationError');
        return CsvImportResult.failure(validationError);
      }

      // ── Parse rows ────────────────────────────────────────────────────
      final metaRows = sections[_sMeta] ?? [];
      final categoryRows = sections[_sCategories] ?? [];
      final subcategoryRows = sections[_sSubcategories] ?? [];
      final tagRows = sections[_sTags] ?? [];
      final budgetRows = sections[_sBudgets] ?? [];
      final recurringRows = sections[_sRecurring] ?? [];
      final transactionRows = sections[_sTransactions] ?? [];
      final txTagRows = sections[_sTransactionTags] ?? [];
      final profileRows = sections[_sUserProfiles] ?? [];

      // Read currency from meta (optional)
      String? currencyCode;
      String? currencySymbol;
      if (metaRows.length >= 2) {
        final metaHeader = metaRows[0];
        final metaData = metaRows[1];
        final codeIdx = metaHeader.indexOf('currencyCode');
        final symIdx = metaHeader.indexOf('currencySymbol');
        if (codeIdx >= 0 && codeIdx < metaData.length)
          currencyCode = metaData[codeIdx];
        if (symIdx >= 0 && symIdx < metaData.length)
          currencySymbol = metaData[symIdx];
      }

      int txImported = 0;
      int catImported = 0;
      int subImported = 0;
      int tagImported = 0;
      int budgetImported = 0;
      int recurImported = 0;
      int profileImported = 0;
      int txTagImported = 0;
      int skipped = 0;
      final errors = <String>[];

      await _db.transaction(() async {
        // FK-safe delete order (children before parents)
        await _db.delete(_db.transactionTags).go();
        await _db.delete(_db.attachments).go();
        await _db.delete(_db.transactions).go();
        await _db.delete(_db.recurringTransactions).go();
        await _db.delete(_db.budgets).go();
        await _db.delete(_db.subcategories).go();
        await _db.delete(_db.tags).go();
        await _db.delete(_db.categories).go();
        await _db.delete(_db.userProfiles).go();

        // 1. User Profiles
        if (profileRows.length >= 2) {
          final h = profileRows[0];
          for (final row in profileRows.skip(1)) {
            if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) {
              skipped++;
              continue;
            }
            try {
              final v = _rowMap(h, row);
              final intId = _parseInt(v['id']);
              await _db.into(_db.userProfiles).insert(
                    UserProfilesCompanion.insert(
                      id: intId != null ? Value(intId) : const Value.absent(),
                      name: v['name'] ?? 'User',
                      email: Value(
                          v['email']?.isEmpty == true ? null : v['email']),
                      phone: Value(
                          v['phone']?.isEmpty == true ? null : v['phone']),
                      bio: Value(v['bio']?.isEmpty == true ? null : v['bio']),
                      imagePath:
                          const Value(null), // excluded — device-specific
                      createdAt:
                          Value(_parseDate(v['createdAt']) ?? DateTime.now()),
                      updatedAt:
                          Value(_parseDate(v['updatedAt']) ?? DateTime.now()),
                    ),
                  );
              profileImported++;
            } catch (e) {
              errors.add('Profile row: $e');
              skipped++;
            }
          }
        }

        // 2. Categories
        if (categoryRows.length >= 2) {
          final h = categoryRows[0];
          for (final row in categoryRows.skip(1)) {
            if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) {
              skipped++;
              continue;
            }
            try {
              final v = _rowMap(h, row);
              final catType = TransactionType.values.firstWhere(
                (e) => e.name == v['type'],
                orElse: () => TransactionType.expense,
              );
              await _db.into(_db.categories).insert(
                    CategoriesCompanion.insert(
                      id: Value(_parseInt(v['id'])!),
                      name: v['name'] ?? '',
                      icon: v['icon'] ?? '',
                      color: v['color'] ?? '0xFF607D8B',
                      type: catType,
                      isDefault: Value(v['isDefault'] == 'true'),
                      sortOrder: Value(_parseInt(v['sortOrder']) ?? 0),
                    ),
                  );
              catImported++;
            } catch (e) {
              errors.add('Category row: $e');
              skipped++;
            }
          }
        }

        // 3. Subcategories
        if (subcategoryRows.length >= 2) {
          final h = subcategoryRows[0];
          for (final row in subcategoryRows.skip(1)) {
            if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) {
              skipped++;
              continue;
            }
            try {
              final v = _rowMap(h, row);
              await _db.into(_db.subcategories).insert(
                    SubcategoriesCompanion.insert(
                      id: Value(_parseInt(v['id'])!),
                      parentCategoryId: _parseInt(v['parentCategoryId'])!,
                      name: v['name'] ?? '',
                    ),
                  );
              subImported++;
            } catch (e) {
              errors.add('Subcategory row: $e');
              skipped++;
            }
          }
        }

        // 4. Tags
        if (tagRows.length >= 2) {
          final h = tagRows[0];
          for (final row in tagRows.skip(1)) {
            if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) {
              skipped++;
              continue;
            }
            try {
              final v = _rowMap(h, row);
              await _db.into(_db.tags).insert(
                    TagsCompanion.insert(
                      id: Value(_parseInt(v['id'])!),
                      name: v['name'] ?? '',
                    ),
                  );
              tagImported++;
            } catch (e) {
              errors.add('Tag row: $e');
              skipped++;
            }
          }
        }

        // 5. Budgets
        if (budgetRows.length >= 2) {
          final h = budgetRows[0];
          for (final row in budgetRows.skip(1)) {
            if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) {
              skipped++;
              continue;
            }
            try {
              final v = _rowMap(h, row);
              final period = BudgetPeriod.values.firstWhere(
                (e) => e.name == v['period'],
                orElse: () => BudgetPeriod.monthly,
              );
              await _db.into(_db.budgets).insert(
                    BudgetsCompanion.insert(
                      id: Value(_parseInt(v['id'])!),
                      categoryId: Value(_parseInt(v['categoryId'])),
                      targetAmount: _parseInt(v['targetAmount']) ?? 0,
                      period: period,
                      year: Value(_parseInt(v['year']) ?? DateTime.now().year),
                      month:
                          Value(_parseInt(v['month']) ?? DateTime.now().month),
                      currencyCode: Value(v['currencyCode'] ?? 'USD'),
                      notifyAtThreshold:
                          Value(v['notifyAtThreshold'] == 'true'),
                      thresholdPercentage:
                          Value(_parseInt(v['thresholdPercentage']) ?? 80),
                    ),
                  );
              budgetImported++;
            } catch (e) {
              errors.add('Budget row: $e');
              skipped++;
            }
          }
        }

        // 6. Recurring Transactions
        if (recurringRows.length >= 2) {
          final h = recurringRows[0];
          for (final row in recurringRows.skip(1)) {
            if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) {
              skipped++;
              continue;
            }
            try {
              final v = _rowMap(h, row);
              final txType = TransactionType.values.firstWhere(
                (e) => e.name == v['type'],
                orElse: () => TransactionType.expense,
              );
              final freq = RecurrenceFrequency.values.firstWhere(
                (e) => e.name == v['frequency'],
                orElse: () => RecurrenceFrequency.monthly,
              );
              await _db.into(_db.recurringTransactions).insert(
                    RecurringTransactionsCompanion.insert(
                      id: Value(_parseInt(v['id'])!),
                      type: txType,
                      amount: _parseInt(v['amount']) ?? 0,
                      categoryId: _parseInt(v['categoryId'])!,
                      subcategoryId: Value(_parseInt(v['subcategoryId'])),
                      note:
                          Value(v['note']?.isEmpty == true ? null : v['note']),
                      frequency: freq,
                      nextDueDate:
                          _parseDate(v['nextDueDate']) ?? DateTime.now(),
                      isAutoCreate: Value(v['isAutoCreate'] == 'true'),
                      isActive: Value(v['isActive'] == 'true'),
                      lastProcessedDate:
                          Value(_parseDate(v['lastProcessedDate'])),
                    ),
                  );
              recurImported++;
            } catch (e) {
              errors.add('RecurringTransaction row: $e');
              skipped++;
            }
          }
        }

        // 7. Transactions
        if (transactionRows.length >= 2) {
          final h = transactionRows[0];
          for (final row in transactionRows.skip(1)) {
            if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) {
              skipped++;
              continue;
            }
            try {
              final v = _rowMap(h, row);
              final txType = TransactionType.values.firstWhere(
                (e) => e.name == v['type'],
                orElse: () => TransactionType.expense,
              );
              PaymentMethod? pm;
              final pmStr = v['paymentMethod'];
              if (pmStr != null && pmStr.isNotEmpty) {
                try {
                  pm = PaymentMethod.values.firstWhere((e) => e.name == pmStr);
                } catch (_) {}
              }
              await _db.into(_db.transactions).insert(
                    TransactionsCompanion.insert(
                      id: Value(_parseInt(v['id'])!),
                      type: txType,
                      amount: _parseInt(v['amount']) ?? 0,
                      categoryId: _parseInt(v['categoryId'])!,
                      subcategoryId: Value(_parseInt(v['subcategoryId'])),
                      timestamp: _parseDate(v['timestamp']) ?? DateTime.now(),
                      note:
                          Value(v['note']?.isEmpty == true ? null : v['note']),
                      paymentMethod: Value(pm),
                      currencyCode: Value(v['currencyCode'] ?? 'USD'),
                      recurringTransactionId:
                          Value(_parseInt(v['recurringTransactionId'])),
                    ),
                  );
              txImported++;
            } catch (e) {
              errors.add('Transaction row: $e');
              skipped++;
            }
          }
        }

        // 8. Transaction Tags
        if (txTagRows.length >= 2) {
          final h = txTagRows[0];
          for (final row in txTagRows.skip(1)) {
            if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) {
              skipped++;
              continue;
            }
            try {
              final v = _rowMap(h, row);
              await _db.into(_db.transactionTags).insert(
                    TransactionTagsCompanion.insert(
                      transactionId: _parseInt(v['transactionId'])!,
                      tagId: _parseInt(v['tagId'])!,
                    ),
                  );
              txTagImported++;
            } catch (e) {
              errors.add('TransactionTag row: $e');
              skipped++;
            }
          }
        }
      });

      // Update currency preference if available
      if (currencyCode != null &&
          currencyCode.isNotEmpty &&
          currencySymbol != null &&
          currencySymbol.isNotEmpty) {
        await _preferenceService.setCurrency(
            code: currencyCode, symbol: currencySymbol);
      }

      // Notify app-wide listeners
      TransactionEvents.notifyUpdated();
      try {
        getIt<BudgetCubit>().loadBudgets();
      } catch (_) {}
      try {
        getIt<DashboardCubit>().loadDashboardData();
      } catch (_) {}
      try {
        getIt<ProfileCubit>().loadProfile();
      } catch (_) {}

      AppLogger.i('DataExportImportService: Import complete — '
          '$txImported transactions, $catImported categories, '
          '$budgetImported budgets, $skipped skipped, ${errors.length} errors');

      return CsvImportResult(
        transactionsImported: txImported,
        categoriesImported: catImported,
        subcategoriesImported: subImported,
        tagsImported: tagImported,
        budgetsImported: budgetImported,
        recurringImported: recurImported,
        profilesImported: profileImported,
        transactionTagsImported: txTagImported,
        skippedCount: skipped,
        errors: errors,
        isSuccess: true,
      );
    } catch (e, stack) {
      AppLogger.e('DataExportImportService: Import failed', e, stack);
      return CsvImportResult.failure(e.toString());
    }
  }

  // ── CSV Building ─────────────────────────────────────────────────────────

  String _buildBackupCsvContent({
    required List<CategoryData> categories,
    required List<SubcategoryData> subcategories,
    required List<TagData> tags,
    required List<BudgetData> budgets,
    required List<RecurringTransactionData> recurring,
    required List<TransactionData> transactions,
    required List<TransactionTagData> transactionTags,
    required List<UserProfileData> userProfiles,
  }) {
    final buf = StringBuffer();

    // META
    buf.writeln('[$_sMeta]');
    buf.writeln('version,exportedAt,currencyCode,currencySymbol');
    final now = DateTime.now().toUtc().toIso8601String();
    final code = _preferenceService.currencyCode;
    final symbol = _preferenceService.currencySymbol;
    buf.writeln('1,$now,${_csvVal(code)},${_csvVal(symbol)}');
    buf.writeln('');

    // CATEGORIES
    buf.writeln('[$_sCategories]');
    buf.writeln('id,name,icon,color,type,isDefault,sortOrder');
    for (final c in categories) {
      buf.writeln(
          '${c.id},${_csvVal(c.name)},${_csvVal(c.icon)},${_csvVal(c.color)},${c.type.name},${c.isDefault},${c.sortOrder}');
    }
    buf.writeln('');

    // SUBCATEGORIES
    buf.writeln('[$_sSubcategories]');
    buf.writeln('id,parentCategoryId,name');
    for (final s in subcategories) {
      buf.writeln('${s.id},${s.parentCategoryId},${_csvVal(s.name)}');
    }
    buf.writeln('');

    // TAGS
    buf.writeln('[$_sTags]');
    buf.writeln('id,name');
    for (final t in tags) {
      buf.writeln('${t.id},${_csvVal(t.name)}');
    }
    buf.writeln('');

    // BUDGETS
    buf.writeln('[$_sBudgets]');
    buf.writeln(
        'id,categoryId,targetAmount,period,year,month,currencyCode,notifyAtThreshold,thresholdPercentage');
    for (final b in budgets) {
      buf.writeln(
          '${b.id},${b.categoryId ?? ""},${b.targetAmount},${b.period.name},${b.year},${b.month},${_csvVal(b.currencyCode)},${b.notifyAtThreshold},${b.thresholdPercentage}');
    }
    buf.writeln('');

    // RECURRING TRANSACTIONS
    buf.writeln('[$_sRecurring]');
    buf.writeln(
        'id,type,amount,categoryId,subcategoryId,note,frequency,nextDueDate,isAutoCreate,isActive,lastProcessedDate');
    for (final rt in recurring) {
      buf.writeln(
        '${rt.id},${rt.type.name},${rt.amount},${rt.categoryId},${rt.subcategoryId ?? ""},${_csvVal(rt.note ?? "")},${rt.frequency.name},${rt.nextDueDate.toUtc().toIso8601String()},${rt.isAutoCreate},${rt.isActive},${rt.lastProcessedDate?.toUtc().toIso8601String() ?? ""}',
      );
    }
    buf.writeln('');

    // TRANSACTIONS
    buf.writeln('[$_sTransactions]');
    buf.writeln(
        'id,type,amount,categoryId,subcategoryId,timestamp,note,paymentMethod,currencyCode,recurringTransactionId');
    for (final t in transactions) {
      buf.writeln(
        '${t.id},${t.type.name},${t.amount},${t.categoryId},${t.subcategoryId ?? ""},${t.timestamp.toUtc().toIso8601String()},${_csvVal(t.note ?? "")},${t.paymentMethod?.name ?? ""},${_csvVal(t.currencyCode)},${t.recurringTransactionId ?? ""}',
      );
    }
    buf.writeln('');

    // TRANSACTION TAGS
    buf.writeln('[$_sTransactionTags]');
    buf.writeln('transactionId,tagId');
    for (final tt in transactionTags) {
      buf.writeln('${tt.transactionId},${tt.tagId}');
    }
    buf.writeln('');

    // USER PROFILES (imagePath excluded — device-specific)
    buf.writeln('[$_sUserProfiles]');
    buf.writeln('id,name,email,phone,bio,createdAt,updatedAt');
    for (final up in userProfiles) {
      buf.writeln(
        '${up.id},${_csvVal(up.name)},${_csvVal(up.email ?? "")},${_csvVal(up.phone ?? "")},${_csvVal(up.bio ?? "")},${up.createdAt.toUtc().toIso8601String()},${up.updatedAt.toUtc().toIso8601String()}',
      );
    }

    return buf.toString();
  }

  // ── CSV Parsing ───────────────────────────────────────────────────────────

  /// Parses a multi-section CSV into a map of section-name → list of rows,
  /// where each row is a list of field strings (header row is rows[0]).
  Map<String, List<List<String>>> _parseSectionedCsv(String content) {
    final result = <String, List<List<String>>>{};
    String? currentSection;

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty) continue;

      // Section header e.g. [TRANSACTIONS]
      if (line.startsWith('[') && line.endsWith(']')) {
        currentSection = line.substring(1, line.length - 1).trim();
        result[currentSection] = [];
        continue;
      }

      if (currentSection != null) {
        result[currentSection]!.add(_parseCsvLine(line));
      }
    }
    return result;
  }

  /// Validates that the required sections and their mandatory columns are
  /// present. Returns `null` if valid, or an error message string.
  String? _validateSections(Map<String, List<List<String>>> sections) {
    if (!sections.containsKey(_sMeta)) return 'Missing [META] section';
    if (!sections.containsKey(_sTransactions))
      return 'Missing [TRANSACTIONS] section';
    if (!sections.containsKey(_sCategories))
      return 'Missing [CATEGORIES] section';

    // Validate required columns per section
    final checks = <String, List<String>>{
      _sCategories: ['id', 'name', 'type'],
      _sTransactions: ['id', 'type', 'amount', 'categoryId', 'timestamp'],
      _sBudgets: ['id', 'targetAmount', 'period'],
    };

    for (final entry in checks.entries) {
      final rows = sections[entry.key];
      if (rows == null || rows.isEmpty) continue;
      final header = rows[0];
      for (final col in entry.value) {
        if (!header.contains(col)) {
          return '[${entry.key}] missing required column: $col';
        }
      }
    }
    return null;
  }

  // ── Directory & File Helpers ──────────────────────────────────────────────

  /// Resolves a writable export directory for the backup file.
  ///
  Future<Directory> _getExportDirectory() async {
    final candidatePaths = <String>[];

    if (Platform.isAndroid) {
      // Primary on Android: app-owned external storage (always writable, survives reinstall ownership).
      try {
        final external = await getExternalStorageDirectory();
        if (external != null)
          candidatePaths.add(p.join(external.path, 'Expendly'));
      } catch (_) {}
      // Secondary: public Downloads — only usable if any existing backup there is owned by this app.
      candidatePaths.add('/storage/emulated/0/Download/Expendly');
      try {
        final downloads = await getDownloadsDirectory();
        if (downloads != null)
          candidatePaths.add(p.join(downloads.path, 'Expendly'));
      } catch (_) {}
    } else if (Platform.isIOS) {
      // iOS: Documents directory (accessible via Files app).
      try {
        final docs = await getApplicationDocumentsDirectory();
        candidatePaths.add(p.join(docs.path, 'Expendly'));
      } catch (_) {}
    } else {
      // Desktop / other: Downloads folder.
      try {
        final downloads = await getDownloadsDirectory();
        if (downloads != null)
          candidatePaths.add(p.join(downloads.path, 'Expendly'));
      } catch (_) {}
    }

    // Universal fallback: app-internal documents directory.
    try {
      final docs = await getApplicationDocumentsDirectory();
      candidatePaths.add(p.join(docs.path, 'Expendly'));
    } catch (_) {}

    Object? lastError;
    final checkedPaths = <String>{};
    for (final path in candidatePaths) {
      if (checkedPaths.contains(path)) continue;
      checkedPaths.add(path);

      try {
        final dir = Directory(path);
        if (!await dir.exists()) await dir.create(recursive: true);

        // Test 1: Can we create new files? (passes even for pre-reinstall locked dirs)
        final testFile = File(p.join(path, '.write_test'));
        await testFile.writeAsString('ok', flush: true);
        await testFile.delete();

        // Test 2: If an existing backup file is present, verify we can actually overwrite it.
        // Pre-reinstall files are owned by a different UID — all write/rename/delete ops will
        // fail with errno=1 (Operation not permitted). Skip this directory in that case.
        final existingBackup = File(p.join(path, kBackupFileName));
        if (await existingBackup.exists()) {
          bool canOverwrite = false;
          try {
            // Attempt a direct write with FileMode.write (truncate). This is the most reliable
            // overwrite check — if the OS blocks it, we know the file is locked.
            await existingBackup.writeAsBytes(
              await existingBackup.readAsBytes(),
              mode: FileMode.write,
              flush: true,
            );
            canOverwrite = true;
          } catch (_) {}

          if (!canOverwrite) {
            AppLogger.w(
                'DataExportImportService: Skipping $path — existing backup is OS-locked (pre-reinstall file).');
            continue;
          }
        }

        AppLogger.d('DataExportImportService: Using export dir: $path');
        return dir;
      } catch (e) {
        lastError = e;
        AppLogger.w(
            'DataExportImportService: Export dir $path not writable: $e');
      }
    }
    throw FileSystemException(
        'No writable export directory available: $lastError');
  }

  /// Writes [payload] to [path] via the storage provider.
  Future<bool> writeExportFile(String path, String payload) async {
    try {
      final filename = p.basename(path);
      await _storageProvider.writeBackup(filename: filename, content: payload);
      final targetFile = File(path);
      if (!await targetFile.exists() ||
          await targetFile.readAsString() != payload) {
        if (!await targetFile.parent.exists()) {
          await targetFile.parent.create(recursive: true);
        }
        await targetFile.writeAsString(payload,
            mode: FileMode.write, flush: true);
      }
      return true;
    } catch (e) {
      AppLogger.w(
          'DataExportImportService: writeExportFile failed for $path: $e');
      return false;
    }
  }

  // ── Private CSV Utilities ─────────────────────────────────────────────────

  /// Wraps a value in double quotes if it contains commas, quotes, or newlines.
  String _csvVal(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Parses a single CSV line, handling quoted fields correctly.
  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buf.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          buf.write(ch);
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
        } else if (ch == ',') {
          fields.add(buf.toString());
          buf.clear();
        } else {
          buf.write(ch);
        }
      }
    }
    fields.add(buf.toString());
    return fields;
  }

  /// Creates a field→value map from parallel header and data lists.
  Map<String, String> _rowMap(List<String> headers, List<String> row) {
    final map = <String, String>{};
    for (int i = 0; i < headers.length; i++) {
      map[headers[i]] = i < row.length ? row[i] : '';
    }
    return map;
  }

  int? _parseInt(String? s) {
    if (s == null || s.isEmpty) return null;
    return int.tryParse(s);
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
