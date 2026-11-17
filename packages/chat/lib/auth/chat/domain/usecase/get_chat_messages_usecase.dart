import 'package:chat/auth/chat/domain/models/chat_message.dart';

abstract interface class GetChatMessagesUsecase {
  /// The conversation with [peerPubkey] from the local store, oldest first.
  Stream<List<ChatMessage>> execute({required String peerPubkey});
}
