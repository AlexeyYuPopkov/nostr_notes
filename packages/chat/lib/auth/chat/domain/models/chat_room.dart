import 'package:common/domain/model/user.dart';
import 'package:equatable/equatable.dart';

import 'chat_message.dart';

final class ChatRoom extends Equatable {
  /// The other participant; their kind 0 profile when it is known.
  final User peer;
  final ChatMessage lastMessage;

  const ChatRoom({required this.peer, required this.lastMessage});

  @override
  List<Object?> get props => [peer, lastMessage];
}
