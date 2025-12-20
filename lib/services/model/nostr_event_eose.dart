import 'dart:convert';

import 'package:nostr_notes/services/model/base_nostr_event.dart';

final class NostrEventEose extends BaseNostrEvent {
  final String relay;
  final String subscriptionId;
  const NostrEventEose({required this.relay, required this.subscriptionId});

  @override
  EventType get eventType => EventType.eose;

  String serialized(String subscriptionId) {
    return jsonEncode([EventType.request.type, subscriptionId, relay]);
  }
}
