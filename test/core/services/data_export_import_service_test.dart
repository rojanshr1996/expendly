import 'dart:io';

import 'package:drift/native.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/database/app_database.dart';
import 'package:expendly/core/services/data_export_import_service.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'encryption_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PreferenceService preferenceService;
  late DataExportImportService exportService;
  late Directory tempDir;

  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferenceService = PreferenceService(FakeSecureStorageService());
    await preferenceService.init();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    exportService = DataExportImportService(db, preferenceService);
    tempDir = await Directory.systemTemp.createTemp('expendly_backup_test_');
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DataExportImportService Tests', () {
    test('writeExportFile successfully creates and overwrites backup content', () async {
      final filePath = p.join(tempDir.path, kBackupFileName);

      // Initial write
      final write1 = await exportService.writeExportFile(filePath, 'Header,Col1\n1,Value1');
      expect(write1, isTrue);

      final file1 = File(filePath);
      expect(await file1.exists(), isTrue);
      expect(await file1.readAsString(), equals('Header,Col1\n1,Value1'));

      // Overwrite write with new payload
      final write2 = await exportService.writeExportFile(filePath, 'Header,Col1\n2,UpdatedValue');
      expect(write2, isTrue);

      final file2 = File(filePath);
      expect(await file2.exists(), isTrue);
      expect(await file2.readAsString(), equals('Header,Col1\n2,UpdatedValue'));
    });

    test('findBackupFile finds existing file in directory', () async {
      final file = await exportService.findBackupFile();
      expect(file, isA<File?>());
    });
  });
}
