import 'package:chat/auth/chat/domain/models/chat_room.dart';

abstract interface class GetChatRoomsUsecase {
  /// The current user's conversations from the local store, newest first.
  Stream<List<ChatRoom>> execute();
}
