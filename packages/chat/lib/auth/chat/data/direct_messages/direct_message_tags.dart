import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag_value.dart';

/// Tags of a [NostrKind.directMessage] event and the store queries over them.
abstract final class DirectMessageTags {
  /// NIP-23 convention: the first publication time, kept across edits while
  /// `created_at` moves forward.
  static const publishedAt = 'published_at';

  static List<List<String>> build({
    required String id,
    required String peerPubkey,
    required int publishedAtSeconds,
  }) {
    return [
      [TagValue.d, id],
      [TagValue.p, peerPubkey],
      [publishedAt, publishedAtSeconds.toString()],
    ];
  }

  static String? peerOf(NostrEvent event) => event.getFirstTagStr(TagValue.p);

  /// Builds the message from an already decrypted [text]; null when the event
  /// misses the tags a direct message must have.
  static ChatMessage? toMessage(NostrEvent event, String text) {
    final id = event.getDTag();
    final peer = peerOf(event);
    if (id == null || id.isEmpty || peer == null || peer.isEmpty) {
      return null;
    }

    final publishedSeconds =
        int.tryParse(event.getFirstTagStr(publishedAt) ?? '') ??
        event.createdAt;

    return ChatMessage(
      id: id,
      eventId: event.id,
      authorPubkey: event.pubkey,
      peerPubkey: peer,
      text: text,
      publishedAt: _fromSeconds(publishedSeconds),
      editedAt: event.createdAt > publishedSeconds
          ? _fromSeconds(event.createdAt)
          : null,
    );
  }

  static RawEventQuery sentBy(String pubkey, {String? to}) {
    return RawEventQuery(
      kinds: const [NostrKind.directMessage],
      authors: [pubkey],
      tagFilters: [
        if (to != null) TagFilter(TagValue.p, [to]),
      ],
    );
  }

  static RawEventQuery receivedBy(String pubkey) {
    return RawEventQuery(
      kinds: const [NostrKind.directMessage],
      tagFilters: [
        TagFilter(TagValue.p, [pubkey]),
      ],
    );
  }

  static RawEventQuery byId({required String author, required String id}) {
    return RawEventQuery(
      kinds: const [NostrKind.directMessage],
      authors: [author],
      tagFilters: [
        TagFilter(TagValue.d, [id]),
      ],
    );
  }

  static DateTime _fromSeconds(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(
        seconds * Duration.millisecondsPerSecond,
      );
}
