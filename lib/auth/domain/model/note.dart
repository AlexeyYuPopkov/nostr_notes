import 'package:equatable/equatable.dart';

sealed class NoteBase extends Equatable {
  static const summaryLength = 100;
  String get dTag;
  String get content;
  String get summary;

  DateTime? get createdAt;
  const NoteBase();
}

final class Note extends NoteBase {
  @override
  final String dTag;
  @override
  final String content;
  @override
  final String summary;
  @override
  final DateTime createdAt;

  const Note({
    required this.dTag,
    required this.content,
    required this.summary,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [dTag, content, summary, createdAt];

  Note copyWith({
    String? content,
    String? summary,
  }) {
    return Note(
      dTag: dTag,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      createdAt: createdAt,
    );
  }
}

// final class NoteDetails extends NoteBase {
//   @override
//   final String dTag;
//   @override
//   final String content;
//   @override
//   final String summary;
//   @override
//   final DateTime createdAt;

//   const NoteDetails({
//     required this.dTag,
//     required this.content,
//     required this.summary,
//     required this.createdAt,
//   });

//   @override
//   List<Object?> get props => [content, createdAt];
// }

// final class DraftNote extends NoteBase {
//   @override
//   final String dTag = '';
//   @override
//   final String content;

//   @override
//   DateTime? get createdAt => null;

//   const DraftNote({required this.content});

//   @override
//   List<Object?> get props => [dTag, content];

//   @override
//   String get summary => content.length > NoteBase.summaryLength
//       ? content.substring(0, NoteBase.summaryLength)
//       : content;
// }
