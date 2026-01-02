import 'dart:convert';
import 'package:nostr_notes/services/model/base_nostr_event.dart';

final class NostrEventClose extends BaseNostrEvent {
  const NostrEventClose({required this.relay, required this.subscriptionId});
  final String relay;
  final String subscriptionId;

  @override
  EventType get eventType => EventType.eose;

  String serialized() {
    return jsonEncode([EventType.close.type, subscriptionId, relay]);
  }
}
