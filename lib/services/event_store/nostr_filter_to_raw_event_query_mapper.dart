import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/tag/tag_value.dart';

final class NostrFilterToRawEventQueryMapper {
  static RawEventQuery toRawEventQuery(
    NostrFilter src, {
    bool clearLimit = false,
  }) {
    final additional = src.additional;
    final tags = [
      if (src.p != null && src.p!.isNotEmpty) TagFilter(TagValue.p, src.p!),
      if (src.t != null && src.t!.isNotEmpty) TagFilter(TagValue.t, src.t!),
      if (src.e != null && src.e!.isNotEmpty) TagFilter(TagValue.e, src.e!),
      if (src.a != null && src.a!.isNotEmpty) TagFilter(TagValue.a, src.a!),
      if (src.d != null && src.d!.isNotEmpty) TagFilter('d', src.d!),
      if (additional != null && additional.isNotEmpty)
        for (final entry in additional.entries)
          TagFilter(_additionalFilterTag(entry.key), entry.value),
    ];
    return RawEventQuery(
      ids: src.ids,
      kinds: src.kinds,
      limit: clearLimit ? null : src.limit,
      authors: src.authors,
      since: src.since != null
          ? DateTime.fromMillisecondsSinceEpoch(src.since! * 1000)
          : null,
      until: src.until != null
          ? DateTime.fromMillisecondsSinceEpoch(src.until! * 1000)
          : null,
      tagFilters: tags.isEmpty ? null : tags,
      search: src.search,
    );
  }

  static String _additionalFilterTag(String src) {
    if (src.startsWith('#')) {
      return src.substring(1);
    } else {
      return src;
    }
  }
}
