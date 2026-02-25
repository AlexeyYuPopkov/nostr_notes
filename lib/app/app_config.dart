import 'package:nostr_notes/services/model/tag/tag_value.dart';

final class AppConfig {
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
