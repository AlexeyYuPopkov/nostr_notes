import 'package:equatable/equatable.dart';

sealed class NoteBase extends Equatable {
  static const summaryLength = 100;
  String get eventId;
  String get dTag;
  String get content;
  String get summary;

  DateTime? get createdAt;
  const NoteBase();
}

final class Note extends NoteBase {
  @override
  final String eventId;
  @override
  final String dTag;
  @override
  final String content;
  @override
  final String summary;
  @override
  final DateTime createdAt;

  const Note({
    required this.eventId,
    required this.dTag,
    required this.content,
    required this.summary,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [eventId, dTag, content, summary, createdAt];

  Note copyWith({String? content, String? summary}) {
    return Note(
      eventId: eventId,
      dTag: dTag,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      createdAt: createdAt,
    );
  }
}
