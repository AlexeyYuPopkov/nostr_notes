import 'package:nostr_notes/core/services/model/base_nostr_event.dart';

final class NostrEventOk extends BaseNostrEvent {
  final String relay;
  final bool isOk;
  final String subscriptionId;
  final String message;

  const NostrEventOk({
    required this.relay,
    required this.isOk,
    required this.subscriptionId,
    required this.message,
  });

  @override
  EventType get eventType => EventType.ok;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NostrEventOk &&
        other.relay == relay &&
        other.isOk == isOk &&
        other.subscriptionId == subscriptionId &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(
        relay,
        isOk,
        subscriptionId,
        message,
      );
}
