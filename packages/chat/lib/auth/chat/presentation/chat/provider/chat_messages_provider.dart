import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/repo/chats_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_messages_provider.g.dart';

@riverpod
final class ChatMessages extends _$ChatMessages {
  late final ChatsRepo _chatsRepo = GetIt.I.get();

  @override
  Future<List<ChatMessage>> build(String pubkey) {
    return _chatsRepo.getMessages(pubkey: pubkey);
  }

  Future<void> send(String text) async {
    await _chatsRepo.sendMessage(pubkey: pubkey, text: text);
    state = AsyncData(await _chatsRepo.getMessages(pubkey: pubkey));
  }
}
