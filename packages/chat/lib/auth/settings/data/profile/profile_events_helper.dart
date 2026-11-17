import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';

mixin ProfileEventsHelper {
  RawEventQuery profileQuery(String pubkey) =>
      RawEventQuery(kinds: const [NostrKind.user], authors: [pubkey]);

  /// Kind 0 is replaceable: only the newest event counts.
  NostrEvent? newestProfileEvent(Iterable<NostrEvent> events) {
    if (events.isEmpty) {
      return null;
    }
    return events.reduce((a, b) => a.createdAt >= b.createdAt ? a : b);
  }
}
