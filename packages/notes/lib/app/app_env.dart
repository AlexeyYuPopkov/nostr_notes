import 'package:nostr_notes/app/env.dart';

abstract interface class AppEnv {
  String get devLightningAddress;
  String get devNostrPubkey;
  String get kofiUrl;
  String get admobAppIdIos;
  String get admobInterstitialIdIos;
  String get admobInterstitialIdAndroid;
}

final class DefaultAppEnv implements AppEnv {
  const DefaultAppEnv();

  @override
  String get devLightningAddress => Env.devLightningAddress;

  @override
  String get devNostrPubkey => Env.devNostrPubkey;

  @override
  String get kofiUrl => Env.kofiUrl;

  @override
  String get admobAppIdIos => Env.admobAppIdIos;

  @override
  String get admobInterstitialIdIos => Env.admobInterstitialIdIos;

  @override
  String get admobInterstitialIdAndroid => Env.admobInterstitialIdAndroid;
}
