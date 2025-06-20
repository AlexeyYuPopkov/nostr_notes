import 'package:equatable/equatable.dart';

sealed class NoteBase extends Equatable {
  String get content;

  const NoteBase();
}

final class Note extends NoteBase {
  @override
  final String content;
  final DateTime createdAt;

  const Note({
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [content, createdAt];
}

final class DraftNote extends NoteBase {
  @override
  final String content;

  const DraftNote(this.content);

  @override
  List<Object?> get props => [content];
}
