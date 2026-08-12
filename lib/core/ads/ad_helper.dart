import 'dart:io';

import 'package:expendly/core/config/app_config.dart';

class AdHelper {
  static const _prodAdUnitId = 'ca-app-pub-6085838191865376/8343302097';

  static String get bannerAdUnitId {
    if (AppConfig.instance.isProd) return _prodAdUnitId;

    // Test Ad Unit IDs provided by Google
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (AppConfig.instance.isProd) return _prodAdUnitId;

    // Test Ad Unit IDs provided by Google
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
