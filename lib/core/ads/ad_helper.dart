import 'dart:io';

import 'package:expendly/core/config/app_config.dart';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Production Ad Unit IDs (Configured in Google AdMob Console)
  // Format: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
  static const _prodAndroidBannerId = 'ca-app-pub-6085838191865376/8343302097';
  static const _prodIosBannerId = 'ca-app-pub-6085838191865376/8343302097';

  static const _prodAndroidInterstitialId =
      'ca-app-pub-6085838191865376/8343302097';
  static const _prodIosInterstitialId =
      'ca-app-pub-6085838191865376/8343302097';

  // Google's Official Test Ad Unit IDs (Always serve test ads without publisher account issues)
  static const _testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const _testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  static const _testAndroidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testIosInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  static String get bannerAdUnitId {
    // In debug mode or non-prod flavors, always use Google's official test ad units
    if (kDebugMode || !AppConfig.instance.isProd) {
      if (Platform.isIOS) {
        return _testIosBannerId;
      }
      return _testAndroidBannerId;
    }

    if (Platform.isIOS) {
      return _prodIosBannerId;
    }
    return _prodAndroidBannerId;
  }

  static String get interstitialAdUnitId {
    // In debug mode or non-prod flavors, always use Google's official test ad units
    if (kDebugMode || !AppConfig.instance.isProd) {
      if (Platform.isIOS) {
        return _testIosInterstitialId;
      }
      return _testAndroidInterstitialId;
    }

    if (Platform.isIOS) {
      return _prodIosInterstitialId;
    }
    return _prodAndroidInterstitialId;
  }
}
