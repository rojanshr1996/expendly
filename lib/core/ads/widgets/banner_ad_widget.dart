import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../di/injection.dart';
import '../../services/remote_config_service.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId;

  const BannerAdWidget({super.key, required this.adUnitId});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _sizeAnimation;
  late final Animation<Offset> _slideAnimation;
  StreamSubscription<bool>? _adsEnabledSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    try {
      final remoteConfig = getIt<RemoteConfigService>();
      _adsEnabledSubscription =
          remoteConfig.onAdsEnabledChanged.listen((enabled) {
        if (!mounted) return;
        if (!enabled) {
          if (_isLoaded) {
            _controller.reverse().then((_) {
              if (mounted) {
                setState(() {
                  _isLoaded = false;
                });
              }
            });
          }
        } else if (!_isLoaded && _bannerAd == null) {
          _loadAd();
        }
      });
      if (remoteConfig.isAdsEnabled) {
        _loadAd();
      }
    } catch (_) {
      _loadAd();
    }
  }

  void _loadAd() {
    try {
      if (!getIt<RemoteConfigService>().isAdsEnabled) {
        return;
      }
    } catch (_) {}

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          developer.log('BannerAd loaded.', name: 'AdMob');
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
            _controller.forward();
          }
        },
        onAdFailedToLoad: (ad, err) {
          developer.log('BannerAd failed to load: ${err.message}',
              name: 'AdMob');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _adsEnabledSubscription?.cancel();
    _controller.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (!getIt<RemoteConfigService>().isAdsEnabled) {
        return const SizedBox.shrink();
      }
    } catch (_) {}

    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      alignment: Alignment.center,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        ),
      ),
    );
  }
}
