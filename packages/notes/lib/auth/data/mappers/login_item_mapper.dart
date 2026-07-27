import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr_notes/auth/domain/model/encrypted_login_item.dart';
import 'package:nostr_notes/core/event_kind.dart';

/// Maps [EncryptedLoginItem] from kind-31023 vault events and builds the
/// wire tags for publishing.
///
/// Wire tags are deliberately minimal: `d` only — no client tag, no summary,
/// no labels, no timestamps beyond the event's own `created_at`. The vault
/// pubkey is pseudonymous, and everything sensitive lives in the encrypted
/// `content` blob; extra plaintext tags would only add fingerprinting
/// surface.
final class LoginItemMapper {
  static List<EncryptedLoginItem> fromNostrEvents(Iterable<NostrEvent> events) {
    return events.map(fromNostrEvent).whereType<EncryptedLoginItem>().toList();
  }

  /// Tags for the signed wire event; the event itself is created (id + sig)
  /// by `NostrEventCreator` in the save usecase.
  static List<List<String>> toTags(EncryptedLoginItem item) {
    return [
      [Tag.d.value, item.dTag],
    ];
  }

  static EncryptedLoginItem? fromNostrEvent(NostrEvent event) {
    final dTag = event.getFirstTag(Tag.d) ?? '';

    if (event.kind != NostrKind.loginItem ||
        dTag.isEmpty ||
        event.content.isEmpty) {
      return null;
    }

    return EncryptedLoginItem(
      eventId: event.id,
      dTag: dTag,
      encryptedPayload: event.content,
      createdAt: event.createdAt.toDateTimeUtc(),
    );
  }
}

extension on int {
  DateTime toDateTimeUtc() =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000, isUtc: true);
}
