import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';

final class NoteMapper {
  static Note? fromNostrEvent(NostrEvent event) {
    final dTag = event.getFirstTag(Tag.d) ?? '';

    if (dTag.isEmpty) {
      return null;
    }

    final summaryTag = event.getFirstTag(const SummaryTag()) ?? '';

    return Note(
      dTag: dTag,
      content: event.content,
      summary: summaryTag,
      createdAt: DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000),
    );
  }
}
