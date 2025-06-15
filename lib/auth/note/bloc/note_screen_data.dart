import 'package:equatable/equatable.dart';

final class NoteScreenData extends Equatable {
  final String initialText;
  final String text;

  const NoteScreenData._({required this.initialText, required this.text});

  factory NoteScreenData.initial({required String initialText}) {
    return NoteScreenData._(
      initialText: initialText,
      text: initialText,
    );
  }

  @override
  List<Object?> get props => [text];

  bool get isChanged => initialText != text;

  NoteScreenData copyWith({String? text}) {
    return NoteScreenData._(
      initialText: initialText,
      text: text ?? this.text,
    );
  }
}
