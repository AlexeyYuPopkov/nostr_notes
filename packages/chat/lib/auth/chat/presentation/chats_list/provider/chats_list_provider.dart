import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:chat/auth/chat/domain/usecase/get_chat_rooms_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chats_list_provider.g.dart';

@riverpod
Stream<List<ChatRoom>> chatsList(Ref ref) {
  return GetIt.I.get<GetChatRoomsUsecase>().execute();
}
