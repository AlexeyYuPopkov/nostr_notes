import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

final class NoteMapper {
  static Note? fromNostrEvent(NostrEvent event) {
    final dTag = event.getFirstTag(Tag.d) ?? '';

    if (dTag.isEmpty) {
      return null;
    }

    final summaryTag = event.getFirstTag(const SummaryTag()) ?? '';

    return Note(
      eventId: event.id,
      dTag: dTag,
      content: event.content,
      summary: summaryTag,
      createdAt: DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000),
    );
  }
}
