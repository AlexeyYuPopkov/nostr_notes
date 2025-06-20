import 'package:nostr_notes/services/model/tag/tag_value.dart';

final class AppConfig {
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
