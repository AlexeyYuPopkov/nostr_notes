import 'package:equatable/equatable.dart';

import 'chat_message.dart';

final class ChatRoom extends Equatable {
  /// The other participant. Their profile is read separately, by pubkey.
  final String peerPubkey;
  final ChatMessage lastMessage;

  const ChatRoom({required this.peerPubkey, required this.lastMessage});

  @override
  List<Object?> get props => [peerPubkey, lastMessage];
}
