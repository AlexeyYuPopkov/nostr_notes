import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nostr_notes/app/app_config.dart';

import 'ads_service.dart';

final class AdsServiceIos implements AdsService {
  InterstitialAd? _ad;
  bool _isLoading = false;

  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _load();
  }

  @override
  Future<void> showInterstitial() async {
    final ad = _ad;
    if (ad == null) {
      log('Interstitial not ready', name: 'AdsService');
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Failed to show interstitial: $error', name: 'AdsService');
        ad.dispose();
        _ad = null;
        _load();
      },
    );
    await ad.show();
  }

  void _load() {
    if (_isLoading) return;
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AppConfig.admobInterstitialIdIos,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          log('Interstitial loaded', name: 'AdsService');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          log('Failed to load interstitial: $error', name: 'AdsService');
        },
      ),
    );
  }
}
