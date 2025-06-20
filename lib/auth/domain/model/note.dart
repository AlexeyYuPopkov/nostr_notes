import 'package:equatable/equatable.dart';

sealed class NoteBase extends Equatable {
  String get content;

  const NoteBase();
}

final class Note extends NoteBase {
  @override
  final String content;

  const Note(this.content);

  @override
  List<Object?> get props => [content];
}

final class DraftNote extends NoteBase {
  @override
  final String content;

  const DraftNote(this.content);

  @override
  List<Object?> get props => [content];
}
