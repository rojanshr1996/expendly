import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../utils/app_logger.dart';

/// Abstract storage provider interface for exporting backup files.
///
/// Encapsulates platform-specific storage mechanisms:
///   - Android: MediaStore ContentResolver via MethodChannel with fail-fast fallback strategy
///   - iOS: App Documents directory (accessible via Files app)
///   - Desktop/Other: User Downloads directory / App Documents fallback
abstract class BackupStorageProvider {
  /// Writes [content] to a backup file named [filename].
  ///
  /// Returns the absolute saved file path or URI on success.
  Future<String> writeBackup({
    required String filename,
    required String content,
  });
}

/// Android-specific backup storage provider using Android MediaStore APIs.
///
/// **Why MediaStore is required on Android 11+ (API 30+)**:
/// When an application is reinstalled, Android assigns a new Linux UID to the app.
/// Pre-existing backup files in public storage (e.g. `Downloads/Expendly/expendly_backup.csv`)
/// remain owned by the previous installation's UID. Direct POSIX operations (`dart:io` `File`)
/// throw `Operation not permitted (errno = 1)`.
///
/// **Fallback Chain**:
/// 1. Try MediaStore insert/update for [filename] (`expendly_backup.csv`).
/// 2. If MediaStore fails due to pre-reinstall UID lock, try MediaStore for `expendly_backup_latest.csv`.
/// 3. If MediaStore fails completely, fall back to app-private external storage (`Android/data/<pkg>/files/Expendly`).
/// 4. Final fallback to app internal documents directory.
@LazySingleton(
    as: BackupStorageProvider, env: [Environment.prod, Environment.dev])
class AndroidMediaStoreBackupStorageProvider implements BackupStorageProvider {
  static const MethodChannel _channel =
      MethodChannel('com.expendly.app/mediastore');

  @override
  Future<String> writeBackup({
    required String filename,
    required String content,
  }) async {
    if (!Platform.isAndroid) {
      return _writeDirectFile(filename, content);
    }

    // Step 1: Attempt MediaStore write for target filename (e.g. expendly_backup_1_0_0.csv)
    try {
      final path = await _writeViaMediaStore(filename, content);
      AppLogger.i(
          'AndroidMediaStoreProvider: Successfully wrote via MediaStore -> $path');
      return path;
    } catch (e) {
      AppLogger.w(
          'AndroidMediaStoreProvider: MediaStore write for $filename failed: $e. Trying alternate filename...');
    }

    // Step 2: Attempt MediaStore write for alternate filename (expendly_backup_latest.csv)
    // This creates a fresh file in Downloads/Expendly owned by current app UID, bypassing pre-reinstall locks.
    if (filename != 'expendly_backup_latest.csv') {
      try {
        final path =
            await _writeViaMediaStore('expendly_backup_latest.csv', content);
        AppLogger.i(
            'AndroidMediaStoreProvider: Successfully wrote alternate via MediaStore -> $path');
        return path;
      } catch (e) {
        AppLogger.w(
            'AndroidMediaStoreProvider: Alternate MediaStore write failed: $e');
      }
    }

    // Step 3: Fallback to app external storage directory
    try {
      final external = await getExternalStorageDirectory();
      if (external != null) {
        final dir = Directory(p.join(external.path, 'Expendly'));
        if (!await dir.exists()) await dir.create(recursive: true);
        final file = File(p.join(dir.path, filename));
        await file.writeAsString(content, mode: FileMode.write, flush: true);
        AppLogger.i(
            'AndroidMediaStoreProvider: External storage fallback succeeded -> ${file.path}');
        return file.path;
      }
    } catch (e) {
      AppLogger.w(
          'AndroidMediaStoreProvider: External storage fallback failed: $e');
    }

    // Step 4: Final fallback to internal documents directory
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'Expendly'));
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File(p.join(dir.path, filename));
      await file.writeAsString(content, mode: FileMode.write, flush: true);
      AppLogger.i(
          'AndroidMediaStoreProvider: Documents fallback succeeded -> ${file.path}');
      return file.path;
    } catch (e) {
      AppLogger.e(
          'AndroidMediaStoreProvider: All storage provider fallbacks failed',
          e);
      throw FileSystemException(
          'Failed to write backup file across all storage providers: $e');
    }
  }

  Future<String> _writeViaMediaStore(String filename, String content) async {
    final String? result = await _channel.invokeMethod<String>(
      'writeToDownloads',
      <String, dynamic>{
        'filename': filename,
        'content': content,
      },
    );
    if (result == null || result.isEmpty) {
      throw const FileSystemException('MediaStore returned empty path');
    }
    return result;
  }

  Future<String> _writeDirectFile(String filename, String content) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'Expendly'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final file = File(p.join(dir.path, filename));
    await file.writeAsString(content, mode: FileMode.write, flush: true);
    return file.path;
  }
}

/// iOS storage provider saving backups into the iOS App Documents directory.
class IOSBackupStorageProvider implements BackupStorageProvider {
  @override
  Future<String> writeBackup({
    required String filename,
    required String content,
  }) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'Expendly'));
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File(p.join(dir.path, filename));
      await file.writeAsString(content, mode: FileMode.write, flush: true);
      AppLogger.i('IOSBackupStorageProvider: Saved backup -> ${file.path}');
      return file.path;
    } catch (e) {
      AppLogger.e('IOSBackupStorageProvider: Failed to write backup', e);
      throw FileSystemException('iOS backup write failed: $e');
    }
  }
}

/// Desktop / Generic platform storage provider writing to Downloads or Documents.
class DesktopBackupStorageProvider implements BackupStorageProvider {
  @override
  Future<String> writeBackup({
    required String filename,
    required String content,
  }) async {
    try {
      Directory? targetDir;
      try {
        targetDir = await getDownloadsDirectory();
      } catch (_) {}
      try {
        targetDir ??= await getApplicationDocumentsDirectory();
      } catch (_) {}
      targetDir ??= Directory.systemTemp;

      final dir = Directory(p.join(targetDir.path, 'Expendly'));
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File(p.join(dir.path, filename));
      await file.writeAsString(content, mode: FileMode.write, flush: true);
      AppLogger.i('DesktopBackupStorageProvider: Saved backup -> ${file.path}');
      return file.path;
    } catch (e) {
      AppLogger.e('DesktopBackupStorageProvider: Failed to write backup', e);
      throw FileSystemException('Desktop backup write failed: $e');
    }
  }
}

/// Factory resolving the appropriate [BackupStorageProvider] based on the host OS.
class BackupStorageProviderFactory {
  static BackupStorageProvider create() {
    if (Platform.isAndroid) {
      return AndroidMediaStoreBackupStorageProvider();
    } else if (Platform.isIOS) {
      return IOSBackupStorageProvider();
    } else {
      return DesktopBackupStorageProvider();
    }
  }
}
