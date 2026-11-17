import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:common/domain/model/user.dart';
import 'package:equatable/equatable.dart';

final class ChatData extends Equatable {
  final String myPubkey;
  final User peer;
  final List<ChatMessage> messages;

  /// The message the composer replaces instead of sending a new one.
  final ChatMessage? editing;

  const ChatData._({
    required this.myPubkey,
    required this.peer,
    required this.messages,
    this.editing,
  });

  factory ChatData.initial({
    required String myPubkey,
    required String peerPubkey,
  }) => ChatData._(
    myPubkey: myPubkey,
    peer: User(pubkey: peerPubkey),
    messages: const [],
  );

  bool isMine(ChatMessage message) => message.authorPubkey == myPubkey;

  ChatData copyWith({User? peer, List<ChatMessage>? messages}) {
    return ChatData._(
      myPubkey: myPubkey,
      peer: peer ?? this.peer,
      messages: messages ?? this.messages,
      editing: editing,
    );
  }

  ChatData withEditing(ChatMessage? editing) {
    return ChatData._(
      myPubkey: myPubkey,
      peer: peer,
      messages: messages,
      editing: editing,
    );
  }

  @override
  List<Object?> get props => [myPubkey, peer, messages, editing];
}
