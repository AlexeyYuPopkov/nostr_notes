import 'package:chat/auth/chat/domain/models/chat.dart';
import 'package:chat/auth/chat/domain/repo/chats_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chats_list_provider.g.dart';

@riverpod
Future<List<Chat>> chatsList(Ref ref) {
  return GetIt.I.get<ChatsRepo>().getChats();
}
