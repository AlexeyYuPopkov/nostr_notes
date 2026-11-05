import 'package:equatable/equatable.dart';

final class ChatMessage extends Equatable {
  final String text;

  const ChatMessage({required this.text});

  @override
  List<Object?> get props => [text];
}
