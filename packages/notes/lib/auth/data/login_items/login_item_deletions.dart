import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr_notes/core/event_kind.dart';

/// d-tags of login items covered by a NIP-09 deletion request from the vault
/// identity. Shared by the watch/get usecases so a deletion synced from
/// another device hides the item even while its events are still stored.
final class LoginItemDeletions {
  static Future<Set<String>> deletedDTags({
    required RawEventStore eventStore,
    required String vaultPubkey,
  }) async {
    final deletions = await eventStore.queryEvents(
      RawEventQuery(kinds: const [NostrKind.deletion], authors: [vaultPubkey]),
    );

    return deletions
        .map(ATag.getAllFromEvent)
        .expand((aTags) => aTags)
        .where((aTag) => aTag.kind == NostrKind.loginItem)
        .map((aTag) => aTag.dTag)
        .toSet();
  }
}
