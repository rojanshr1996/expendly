import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'app_config.dart';

/// Factory class to provide flavor-specific [FirebaseOptions] for project 'expendly-b1247'.
class FirebaseOptionsFactory {
  const FirebaseOptionsFactory._();

  static const String _gcmSenderId = '748636232967';
  static const String _projectId = 'expendly-b1247';
  static const String _storageBucket = 'expendly-b1247.firebasestorage.app';

  static FirebaseOptions get currentOptions {
    final flavor = AppConfig.instance.flavor;
    return forFlavor(flavor);
  }

  static FirebaseOptions forFlavor(AppFlavor flavor) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _getAndroidOptions(flavor);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _getIosOptions(flavor);
      default:
        throw UnsupportedError(
          'FirebaseOptionsFactory is not configured for platform: $defaultTargetPlatform',
        );
    }
  }

  // --- Android Flavor Configurations ---
  static FirebaseOptions _getAndroidOptions(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDJRDmvM-ypCJ7GoByiqJ6ad6EgFU6Z-YA',
          appId: '1:748636232967:android:87bd73587100d5a126b9a2',
          messagingSenderId: _gcmSenderId,
          projectId: _projectId,
          storageBucket: _storageBucket,
        );
      case AppFlavor.qa:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDJRDmvM-ypCJ7GoByiqJ6ad6EgFU6Z-YA',
          appId: '1:748636232967:android:d5c5362c2afc683726b9a2',
          messagingSenderId: _gcmSenderId,
          projectId: _projectId,
          storageBucket: _storageBucket,
        );
      case AppFlavor.prod:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDJRDmvM-ypCJ7GoByiqJ6ad6EgFU6Z-YA',
          appId: '1:748636232967:android:b869f641ba48869026b9a2',
          messagingSenderId: _gcmSenderId,
          projectId: _projectId,
          storageBucket: _storageBucket,
        );
    }
  }

  // --- iOS Flavor Configurations ---
  static FirebaseOptions _getIosOptions(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return const FirebaseOptions(
          apiKey: 'AIzaSyD_LyjALjsQmfBhy4AXRMG5wFTgEpnZMC4',
          appId: '1:748636232967:ios:bf30850969ca6e1826b9a2',
          messagingSenderId: _gcmSenderId,
          projectId: _projectId,
          iosBundleId: 'com.expendly.app.dev',
          storageBucket: _storageBucket,
        );
      case AppFlavor.qa:
        return const FirebaseOptions(
          apiKey: 'AIzaSyD_LyjALjsQmfBhy4AXRMG5wFTgEpnZMC4',
          appId: '1:748636232967:ios:e1663044563a60cf26b9a2',
          messagingSenderId: _gcmSenderId,
          projectId: _projectId,
          iosBundleId: 'com.expendly.app.qa',
          storageBucket: _storageBucket,
        );
      case AppFlavor.prod:
        return const FirebaseOptions(
          apiKey: 'AIzaSyD_LyjALjsQmfBhy4AXRMG5wFTgEpnZMC4',
          appId: '1:748636232967:ios:644f13ac882d3c2d26b9a2',
          messagingSenderId: _gcmSenderId,
          projectId: _projectId,
          iosBundleId: 'com.expendly.app',
          storageBucket: _storageBucket,
        );
    }
  }
}
