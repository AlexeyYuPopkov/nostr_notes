import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nostr/model/tag/tag_value.dart';

final class AppConfig {
  static const kKofiUrl = 'https://ko-fi.com/alekseiipopkov';

  /// Developer's lightning address for in-app donations (LUD-16).
  static const kDevLightningAddress = 'visualgemini28@walletofsatoshi.com';
  // static const kDevLightningAddress = 'dioramaexperienced776464@getalby.com';

  /// Developer's nostr hex pubkey — used to create NIP-57 zap events.
  static const kDevNostrPubkey =
      'cf2e0ca7070a28e7c24041160689f37bedd654a86a86bb172881b00621f250e3';

  static const kUsesInMemoryStorage = bool.fromEnvironment(
    'IN_MEMORY_STORAGE',
    defaultValue: false,
  );

  static final kIsTest = kIsWeb
      ? false
      : Platform.environment.containsKey('FLUTTER_TEST') &&
            !const bool.fromEnvironment('INTEGRATION_TEST');

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
