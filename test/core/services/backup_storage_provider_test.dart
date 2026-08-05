import 'dart:io';

import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/services/storage/backup_storage_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );
  });

  group('BackupStorageProvider Tests', () {
    test('BackupStorageProviderFactory resolves valid provider for current OS', () {
      final provider = BackupStorageProviderFactory.create();
      expect(provider, isNotNull);
      expect(provider, isA<BackupStorageProvider>());
    });

    test('Desktop/iOS BackupStorageProvider writes and overwrites content successfully', () async {
      final provider = DesktopBackupStorageProvider();

      // Write initial
      final savedPath1 = await provider.writeBackup(
        filename: 'test_backup.csv',
        content: 'Header,Value\n1,Alpha',
      );

      expect(savedPath1, isNotEmpty);
      final file1 = File(savedPath1);
      expect(await file1.exists(), isTrue);
      expect(await file1.readAsString(), equals('Header,Value\n1,Alpha'));

      // Write updated
      final savedPath2 = await provider.writeBackup(
        filename: 'test_backup.csv',
        content: 'Header,Value\n2,Beta',
      );

      expect(savedPath2, equals(savedPath1));
      final file2 = File(savedPath2);
      expect(await file2.readAsString(), equals('Header,Value\n2,Beta'));

      // Cleanup
      if (await file2.exists()) {
        await file2.delete();
      }
    });
  });
}
