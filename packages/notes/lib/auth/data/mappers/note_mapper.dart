import 'dart:convert';

import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/model/pin_kdf.dart';
import 'package:nostr_notes/core/event_kind.dart';

final class NoteMapper {
  static List<Note> fromNostrEvents(Iterable<NostrEvent> events) {
    return events.map((e) => fromNostrEvent(e)).whereType<Note>().toList();
  }

  static NostrEvent toNostrEvent(
    Note note, {
    String pubkey = '',
    String sig = '',
  }) {
    return NostrEvent(
      kind: EventKind.note.value,
      id: note.eventId,
      pubkey: pubkey,
      createdAt: note.createdAt.millisecondsSinceEpoch ~/ 1000,
      tags: [
        [Tag.client.value, Note.clientTagValue],
        [Tag.t.value, Note.clientTagValue],
        [Tag.d.value, note.dTag],
        if (pubkey.isNotEmpty) [Tag.p.value, pubkey],
        [const SummaryTag().value, note.summary],
        if (note.updatedAt != note.createdAt)
          [
            Note.updatedAtTag,
            (note.updatedAt.millisecondsSinceEpoch ~/ 1000).toString(),
          ],
        if (note.kdf != PinKdf.legacySha256)
          [PinKdf.tagName, note.kdf.tagValue],
        if (note.labels.isNotEmpty)
          [
            Note.labelsTag,
            switch (note.labels.first) {
              EncryptedLabel() => note.labels.first.textValue,
              _ => BaseLabel.joinLabels(note.labels.whereType<Label>()),
            },
          ],
      ],
      content: note.content,
      sig: sig,
    );
  }

  static Note? fromJsonStr(String jsonStr) {
    final json = jsonDecode(jsonStr);
    final event = NostrEvent.fromJson(json[2] as Map<String, dynamic>);
    return NoteMapper.fromNostrEvent(event);
  }

  static Note? fromNostrEvent(NostrEvent event) {
    final dTag = event.getFirstTag(Tag.d) ?? '';

    if (dTag.isEmpty) {
      return null;
    }

    final summaryTag = event.getFirstTag(const SummaryTag()) ?? '';
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      event.createdAt * 1000,
      isUtc: true,
    );
    final initAtTagValue = event.getFirstTagStr(Note.updatedAtTag);
    final int? initAtIntSeconds =
        initAtTagValue != null && initAtTagValue.isNotEmpty
        ? int.tryParse(initAtTagValue)
        : null;

    final DateTime? updatedAt = initAtIntSeconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            initAtIntSeconds * 1000,
            isUtc: true,
          );

    final labelsTagValue = event.getFirstTagStr(Note.labelsTag);

    return Note(
      eventId: event.id,
      dTag: dTag,
      content: event.content,
      summary: summaryTag,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      labels: _parseLabels(labelsTagValue),
      kdf: PinKdf.fromTagValue(event.getFirstTagStr(PinKdf.tagName)),
    );
  }

  /// Returns [Label] objects when [raw] is a plain JSON array (export format),
  /// or a single [EncryptedLabel] when it is a NIP-44 blob.
  static List<BaseLabel> _parseLabels(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return BaseLabel.fromJoinedText(raw);
    } catch (_) {
      return [EncryptedLabel(textValue: raw)];
    }
  }
}
