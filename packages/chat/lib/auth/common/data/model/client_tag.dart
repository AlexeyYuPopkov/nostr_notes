import 'package:chat/app/app_config.dart';
import 'package:nostr/model/tag/tag_value.dart';

/// Our relay rejects every event without it (doc/webrtc-backend.md, §6.2).
abstract final class ClientTag {
  static List<String> get tag => [TagValue.client, AppConfig.clientTagValue];

  /// [tags] with any other client's tag swapped for ours.
  static List<List<String>> withOurs(List<List<String>> tags) => [
    for (final tag in tags)
      if (tag.firstOrNull != TagValue.client) List.of(tag),
    tag,
  ];
}
