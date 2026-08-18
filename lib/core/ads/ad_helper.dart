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
      if (Platform.isAndroid) {
        return _testAndroidBannerId;
      } else if (Platform.isIOS) {
        return _testIosBannerId;
      } else {
        throw UnsupportedError('Unsupported platform for AdMob');
      }
    }

    if (Platform.isAndroid) {
      return _prodAndroidBannerId;
    } else if (Platform.isIOS) {
      return _prodIosBannerId;
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }

  static String get interstitialAdUnitId {
    // In debug mode or non-prod flavors, always use Google's official test ad units
    if (kDebugMode || !AppConfig.instance.isProd) {
      if (Platform.isAndroid) {
        return _testAndroidInterstitialId;
      } else if (Platform.isIOS) {
        return _testIosInterstitialId;
      } else {
        throw UnsupportedError('Unsupported platform for AdMob');
      }
    }

    if (Platform.isAndroid) {
      return _prodAndroidInterstitialId;
    } else if (Platform.isIOS) {
      return _prodIosInterstitialId;
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }
}
