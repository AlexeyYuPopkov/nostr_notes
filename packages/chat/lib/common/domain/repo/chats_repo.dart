import 'package:chat/common/domain/models/chat.dart';
import 'package:chat/common/domain/models/chat_message.dart';

abstract interface class ChatsRepo {
  Future<List<Chat>> getChats();

  Future<List<ChatMessage>> getMessages({required String pubkey});

  Future<void> sendMessage({required String pubkey, required String text});
}
