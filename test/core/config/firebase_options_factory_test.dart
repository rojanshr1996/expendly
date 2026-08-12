import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/config/firebase_options_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseOptionsFactory Tests', () {
    test('returns dev options for AppFlavor.dev', () {
      AppConfig.initialize(
        const AppConfig(
          flavor: AppFlavor.dev,
          appName: 'Expendly Dev',
        ),
      );

      final options = FirebaseOptionsFactory.forFlavor(AppFlavor.dev);
      expect(options.projectId, equals('expendly-b1247'));
      expect(options.storageBucket, equals('expendly-b1247.firebasestorage.app'));
    });

    test('returns qa options for AppFlavor.qa', () {
      final options = FirebaseOptionsFactory.forFlavor(AppFlavor.qa);
      expect(options.projectId, equals('expendly-b1247'));
      expect(options.storageBucket, equals('expendly-b1247.firebasestorage.app'));
    });

    test('returns prod options for AppFlavor.prod', () {
      final options = FirebaseOptionsFactory.forFlavor(AppFlavor.prod);
      expect(options.projectId, equals('expendly-b1247'));
      expect(options.storageBucket, equals('expendly-b1247.firebasestorage.app'));
    });
  });
}
