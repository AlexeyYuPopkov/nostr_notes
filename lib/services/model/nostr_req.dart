import 'dart:convert';

import 'package:nostr_notes/services/model/base_nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';

class NostrReq extends BaseNostrEvent {
  final List<NostrFilter> filters;

  const NostrReq({
    required this.filters,
  });

  String serialized(String subscriptionId) {
    final result = jsonEncode([
      EventType.request.type,
      subscriptionId,
      ...filters.map((e) => e.toJson())
    ]);

    return result;
  }

  @override
  EventType get eventType => EventType.request;
}
