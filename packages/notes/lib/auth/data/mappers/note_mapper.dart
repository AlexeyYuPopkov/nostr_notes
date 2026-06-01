import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

final class NoteMapper {
  static List<Note> fromNostrEvents(Iterable<NostrEvent> events) {
    return events.map((e) => fromNostrEvent(e)).whereType<Note>().toList();
  }

  static Note? fromNostrEvent(NostrEvent event) {
    final dTag = event.getFirstTag(Tag.d) ?? '';

    if (dTag.isEmpty) {
      return null;
    }

    final summaryTag = event.getFirstTag(const SummaryTag()) ?? '';
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      event.createdAt * 1000,
    );
    final initAtTagValue = event.getFirstTagStr(Note.updatedAtTag);
    final int? initAtIntSeconds =
        initAtTagValue != null && initAtTagValue.isNotEmpty
        ? int.tryParse(initAtTagValue)
        : null;

    final DateTime? updatedAt = initAtIntSeconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(initAtIntSeconds * 1000);

    final labelsTagValue = event.getFirstTagStr(Note.labelsTag);

    return Note(
      eventId: event.id,
      dTag: dTag,
      content: event.content,
      summary: summaryTag,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      labels: labelsTagValue == null || labelsTagValue.isEmpty
          ? []
          : [EncryptedLabel(textValue: labelsTagValue)],
    );
  }
}
