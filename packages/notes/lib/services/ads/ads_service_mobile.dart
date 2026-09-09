import 'dart:developer';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nostr_notes/app/app_config.dart';

import 'ads_service.dart';

final class AdsServiceMobile implements AdsService {
  InterstitialAd? _ad;
  bool _isLoading = false;

  // AdMob issues a separate unit per platform; an iOS unit serves nothing on
  // Android. The app-level ids live in Info.plist and AndroidManifest.xml.
  String get _interstitialId => Platform.isIOS
      ? AppConfig.admobInterstitialIdIos
      : AppConfig.admobInterstitialIdAndroid;

  /// Hashed advertising ids, comma-separated, supplied at build time:
  /// `--dart-define=ADMOB_TEST_DEVICE_IDS=id1,id2`. Listed devices receive
  /// test creatives, which are the only ones safe to view or tap — viewing
  /// or clicking live ads on your own hardware is invalid traffic and risks
  /// the AdMob account. Ids are per device *and* per platform; simulators
  /// and emulators are recognised without being listed. Empty in store
  /// builds, which is why this is a build flag rather than an env value.
  static const _testDeviceIdsRaw = String.fromEnvironment(
    'ADMOB_TEST_DEVICE_IDS',
  );

  static List<String> get _testDeviceIds => _testDeviceIdsRaw
      .split(',')
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toList();

  @override
  Future<void> initialize() async {
    final testDeviceIds = _testDeviceIds;
    if (testDeviceIds.isNotEmpty) {
      // Before initialize(), so the load kicked off below is already tagged.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDeviceIds),
      );
      log(
        'Test ads enabled for ${testDeviceIds.length} device(s)',
        name: 'AdsService',
      );
    }
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
      adUnitId: _interstitialId,
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
