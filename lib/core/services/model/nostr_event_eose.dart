import 'package:nostr_notes/core/services/model/base_nostr_event.dart';

final class NostrEventEose extends BaseNostrEvent {
  static const String type = 'EOSE';
  final String relay;
  final String subscriptionId;
  const NostrEventEose({required this.relay, required this.subscriptionId});

  @override
  EventType get eventType => EventType.eose;

  @override
  String toString() {
    return '["$type", "$subscriptionId", "$relay"]';
  }
}
