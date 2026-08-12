import 'dart:io';

import 'package:injectable/injectable.dart';

import '../database/app_database.dart';
import '../models/backup_result.dart';
import '../utils/app_logger.dart';
import 'data_export_import_service.dart';
import 'notification_service.dart';
import 'preference_service.dart';

/// Time-based CSV backup scheduler.
///
/// Backs up all app data to [kBackupFileName] every [backupInterval].
/// Lifecycle:
///   - [start]        — called from [_ExpendlyAppState.initState]
///   - [checkIfDue]   — called on app resume
///   - [performBackup] — can also be triggered manually from Settings
///   - [stop]         — no-op (no timers), kept for symmetry
@lazySingleton
class BackupService {
  final AppDatabase _db;
  final DataExportImportService _exportService;
  final PreferenceService _preferenceService;
  final NotificationService _notificationService;

  BackupService(
    this._db,
    this._exportService,
    this._preferenceService,
    this._notificationService,
  );

  static const Duration backupInterval = Duration(days: 1);
  static const int _notificationId = 888;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Called once on app start. Triggers an initial or due backup if needed.
  void start() {
    _checkInitialBackup();
  }

  /// Called when the app returns to the foreground. Triggers backup if due.
  void checkIfDue() {
    _scheduleBackupIfDue();
  }

  /// No-op. Kept for lifecycle symmetry with the old AutoBackupService.
  void stop() {}

  // ── Core Logic ────────────────────────────────────────────────────────────

  /// Auto-backup requirements:
  ///   1. Onboarding/signup flow must be completed.
  ///   2. At least one transaction must exist in the database.
  Future<bool> _shouldRunAutoBackup() async {
    if (!_preferenceService.isOnboardingCompleted) {
      AppLogger.d(
          'BackupService: Onboarding/signup not completed — skipping auto backup.');
      return false;
    }

    final hasTransactions = await _db.hasAnyTransactions();
    if (!hasTransactions) {
      AppLogger.d(
          'BackupService: No transactions in database — skipping auto backup.');
      return false;
    }

    return true;
  }

  Future<void> _checkInitialBackup() async {
    try {
      if (!await _shouldRunAutoBackup()) return;

      final backupFile = await _exportService.findBackupFile();
      if (backupFile == null) {
        // No backup file exists at all — create the first one immediately.
        AppLogger.i('BackupService: No backup found. Creating initial backup.');
        await performBackup();
        return;
      }

      // Backup file exists — apply the normal 24-hour interval check.
      await _scheduleBackupIfDue();
    } catch (e) {
      AppLogger.e('BackupService: _checkInitialBackup error', e);
    }
  }

  Future<void> _scheduleBackupIfDue() async {
    try {
      if (!await _shouldRunAutoBackup()) return;

      final lastStr = _preferenceService.lastSnapshotAt;
      if (lastStr == null) {
        await performBackup();
        return;
      }
      final last = DateTime.tryParse(lastStr);
      final currentTxCount = await _db.getTransactionCount();
      final lastTxCount = _preferenceService.lastSnapshotCount;

      final isTimeDue =
          last == null || DateTime.now().difference(last) >= backupInterval;
      final isDataChanged = currentTxCount != lastTxCount;

      if (isTimeDue || isDataChanged) {
        AppLogger.i(
            'BackupService: Auto backup triggered (time due: $isTimeDue, data changed: $isDataChanged)');
        await performBackup();
      } else {
        AppLogger.d(
            'BackupService: Backup not yet due. Last: $lastStr (Count: $currentTxCount)');
      }
    } catch (e) {
      AppLogger.e('BackupService: _scheduleBackupIfDue error', e);
    }
  }

  /// Performs the backup. Can be called directly (e.g. from Settings "Backup Now").
  ///
  /// Returns [CsvBackupResult] so callers can surface success/failure in the UI.
  Future<CsvBackupResult> performBackup() async {
    try {
      AppLogger.i('BackupService: Starting CSV backup…');
      _showInProgressNotification();

      final result = await _exportService.exportBackupCsv();

      if (result.isSuccess) {
        await _preferenceService
            .setLastSnapshotAt(DateTime.now().toIso8601String());
        await _preferenceService.setLastSnapshotCount(result.transactionCount);
        await _preferenceService.setLastSnapshotError(null);
        _showSuccessNotification(result);
        AppLogger.i('BackupService: Backup complete → ${result.filePath}');
      } else {
        await _preferenceService.setLastSnapshotError(result.errorMessage);
        _showFailureNotification(result.errorMessage ?? 'Unknown error');
        AppLogger.w('BackupService: Backup failed — ${result.errorMessage}');
      }

      return result;
    } catch (e) {
      final msg = e.toString();
      AppLogger.e('BackupService: performBackup threw', e);
      await _preferenceService.setLastSnapshotError(msg);
      _showFailureNotification(msg);
      return CsvBackupResult.failure(msg);
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  void _showInProgressNotification() {
    try {
      _notificationService.showLocalNotification(
        id: _notificationId,
        title: 'Auto Backup',
        body: 'Backing up your data…',
        payload: '',
      );
    } catch (_) {}
  }

  void _showSuccessNotification(CsvBackupResult result) {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final path = result.filePath;
      final folderDisplay = (path != null && path.contains('Download'))
          ? 'Downloads → Expendly'
          : (path ?? 'Downloads → Expendly');
      _notificationService.showLocalNotification(
        id: _notificationId,
        title: 'Backup Complete',
        body:
            'Saved to $folderDisplay (${result.transactionCount} transactions)',
        payload: '',
      );
    } catch (_) {}
  }

  void _showFailureNotification(String error) {
    try {
      _notificationService.showLocalNotification(
        id: _notificationId,
        title: 'Backup Failed',
        body: 'Could not save backup. $error',
        payload: '',
      );
    } catch (_) {}
  }
}
