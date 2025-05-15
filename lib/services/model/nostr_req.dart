import 'package:nostr_notes/services/model/nostr_filter.dart';

final class NostrReq {
  // final String id;
  final String subscriptionId;
  final List<NostrFilter> filters;

  const NostrReq({
    // required this.id,
    required this.subscriptionId,
    required this.filters,
  });

  String toJsonString() {
    final filtersStr = [
      '"REQ"',
      '"$subscriptionId"',
      ...filters.map((e) => e.toJson())
    ].join(',');

    return '[$filtersStr]';
  }
}
