import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr_notes/app/app_env.dart';

final class FeatureFlags {
  static const bool kEnableAccsTab = true;
}

final class AppConfig {
  static AppEnv _env = const DefaultAppEnv();

  static void configure(AppEnv env) => _env = env;

  static String get kKofiUrl => _env.kofiUrl;
  static const appStoreLink =
      'https://apps.apple.com/bg/app/private-notes-nostr/id6757975921';

  static const googlePlayLink =
      'https://play.google.com/store/apps/details?id=com.alekseii.yu.popkov.nostrNotes';

  /// `action=write-review` opens the App Store straight on the review sheet.
  /// Google Play has no such parameter — [googlePlayLink] is reused there and
  /// lands the user on the listing, where the rating control lives.
  static const appStoreReviewLink =
      'https://apps.apple.com/app/id6757975921?action=write-review';

  static const githubIssuesLink =
      'https://github.com/AlexeyYuPopkov/nostr_notes/issues';

  static final kIsTest = kIsWeb
      ? false
      : Platform.environment.containsKey('FLUTTER_TEST') &&
            !const bool.fromEnvironment('INTEGRATION_TEST');

  static final showAds = !kIsTest; //   !kDebugMode && !kIsTest;

  /// Developer's lightning address for in-app donations (LUD-16).
  static String get kDevLightningAddress => _env.devLightningAddress;

  /// Developer's nostr hex pubkey — used to create NIP-57 zap events.
  static String get kDevNostrPubkey => _env.devNostrPubkey;

  static String get admobAppIdIos => _env.admobAppIdIos;
  static String get admobInterstitialIdIos => _env.admobInterstitialIdIos;
  static String get admobInterstitialIdAndroid =>
      _env.admobInterstitialIdAndroid;
  static String get admobBannerIdIos => _env.admobBannerIdIos;
  static String get admobBannerIdAndroid => _env.admobBannerIdAndroid;

  static const kUsesInMemoryStorage = bool.fromEnvironment(
    'IN_MEMORY_STORAGE',
    defaultValue: false,
  );

  /// Адрес реле из переменной среды (если задана)
  static String? get relayUrl {
    const envRelay = String.fromEnvironment('RELAY_URL');
    if (envRelay.isNotEmpty) {
      return envRelay;
    }
    return null;
  }

  // echo -n "com.alekseii.yu.popkov.nostr_notes" | sha256sum | cut -c1-8
  static const String appId = '996e10ba';
  static String get clientTagValue => appId;

  static List<String> clientTagList() {
    return const [
      TagValue.client,
      appId,
      // '${NostrKind.handlerInformation}:${TriblyConfigs.appPubKey}:${TriblyConfigs.appHandlerIdentifier}',
      // TriblyConfigs.mainRelay,
    ];
  }
}
