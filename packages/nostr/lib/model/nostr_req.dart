import 'dart:convert';
import 'base_nostr_event.dart';
import 'nostr_filter.dart';

class NostrReq extends BaseNostrEvent {
  final List<NostrFilter> filters;

  const NostrReq({required this.filters});

  String serialized(String subscriptionId) {
    final result = jsonEncode([
      EventType.request.type,
      subscriptionId,
      ...filters.map((e) => e.toJson()),
    ]);

    return result;
  }

  @override
  EventType get eventType => EventType.request;
}
