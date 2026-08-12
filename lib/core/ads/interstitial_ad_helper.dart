import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../di/injection.dart';
import '../services/remote_config_service.dart';
import 'ad_helper.dart';

/// Helper class for preloading and displaying Google Mobile Ads Interstitial Ads.
class InterstitialAdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  /// Preloads an Interstitial Ad into memory if not already loading/loaded.
  static void loadAd() {
    try {
      if (!getIt<RemoteConfigService>().isAdsEnabled) {
        return;
      }
    } catch (_) {}

    if (_isLoading || _interstitialAd != null) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log('InterstitialAd loaded successfully.', name: 'AdMob');
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          developer.log('InterstitialAd failed to load: ${error.message}',
              name: 'AdMob');
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Displays the loaded Interstitial Ad.
  /// Calls [onAdDismissed] when the ad is closed, fails to display, or was not ready.
  static void showAd({required VoidCallback onAdDismissed}) {
    try {
      if (!getIt<RemoteConfigService>().isAdsEnabled) {
        onAdDismissed();
        return;
      }
    } catch (_) {}

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          developer.log('InterstitialAd dismissed.', name: 'AdMob');
          ad.dispose();
          _interstitialAd = null;
          loadAd(); // Preload next ad
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          developer.log('InterstitialAd failed to show: ${err.message}',
              name: 'AdMob');
          ad.dispose();
          _interstitialAd = null;
          loadAd(); // Preload next ad
          onAdDismissed();
        },
      );
      _interstitialAd!.show();
    } else {
      developer.log('InterstitialAd was not ready yet when requested to show.',
          name: 'AdMob');
      loadAd(); // Try preloading for next attempt
      onAdDismissed();
    }
  }
}
