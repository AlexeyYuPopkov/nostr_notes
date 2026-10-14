import 'package:nostr_notes/app/env.dart';

abstract interface class AppEnv {
  String get devLightningAddress;
  String get devNostrPubkey;
  String get kofiUrl;
}

final class DefaultAppEnv implements AppEnv {
  const DefaultAppEnv();

  @override
  String get devLightningAddress => Env.devLightningAddress;

  @override
  String get devNostrPubkey => Env.devNostrPubkey;

  @override
  String get kofiUrl => Env.kofiUrl;
}
