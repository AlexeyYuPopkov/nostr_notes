import 'package:nostr_notes/services/model/base_nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:uuid/uuid.dart';

class NostrReq extends BaseNostrEvent {
  final String subscriptionId;
  final List<NostrFilter> filters;

  const NostrReq._({
    required this.subscriptionId,
    required this.filters,
  });

  factory NostrReq.create({
    Uuid? uuid = const Uuid(),
    required List<NostrFilter> filters,
  }) {
    final subscriptionId = (uuid ?? const Uuid()).v1();
    return NostrReq._(
      subscriptionId: subscriptionId,
      filters: filters,
    );
  }

  String toJsonString() {
    final filtersStr = [
      '"${EventType.request.type}"',
      '"$subscriptionId"',
      ...filters.map((e) => e.toJson())
    ].join(',');

    return '[$filtersStr]';
  }

  @override
  EventType get eventType => EventType.request;

  // static NostrReq? fromRawData(data) {
  //   final content = jsonDecode(data) as List?;

  //   if (content == null) {
  //     return null;
  //   }

  //   final length = content.length;

  //   if (length < 1) {
  //     return null;
  //   }

  //   final type = content[0] as String?;
  //   final subscriptionId = content[1] as String?;

  //   if (type == null ||
  //       type.isEmpty ||
  //       subscriptionId == null ||
  //       subscriptionId.isEmpty) {
  //     return null;
  //   }

  //   if (type != EventType.request.type) {
  //     return null;
  //   }

  //   if (length < 3) {
  //     return null;
  //   }

  //   final payload = content[2] as Map<String, dynamic>?;

  //   if (payload == null || payload.isEmpty) {
  //     return null;
  //   }

  //   final filters = <NostrFilter>[];
  //   for (int i = 2; i < length; i++) {
  //     final filter = content[i] as Map<String, dynamic>?;

  //     if (filter == null || filter.isEmpty) {
  //       return null;
  //     }

  //     try {
  //       filters.add(NostrFilter.fromJson(filter));
  //     } catch (e) {
  //       continue;
  //     }
  //   }

  //   return NostrReq._(
  //     subscriptionId: subscriptionId,
  //     filters: filters,
  //   );
  // }
}
