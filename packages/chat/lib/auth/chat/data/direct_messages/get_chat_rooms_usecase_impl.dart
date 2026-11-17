import 'package:chat/auth/chat/domain/models/chat_exception.dart';
import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:chat/auth/chat/domain/usecase/direct_messages_sync_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_chat_rooms_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import 'direct_message_tags.dart';
import 'direct_messages_reader.dart';

final class GetChatRoomsUsecaseImpl implements GetChatRoomsUsecase {
  final SessionUsecase _sessionUsecase;
  final DirectMessagesReader _reader;
  final DirectMessagesSyncUsecase _sync;

  const GetChatRoomsUsecaseImpl({
    required this._sessionUsecase,
    required this._reader,
    required this._sync,
  });

  @override
  Stream<List<ChatRoom>> execute() {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      return Stream.error(const ChatNoSessionException());
    }
    final myPubkey = keys.publicKey;

    final rooms = _reader
        .watch(
          keys: keys,
          queries: [
            DirectMessageTags.sentBy(myPubkey),
            DirectMessageTags.receivedBy(myPubkey),
          ],
        )
        .map((messages) => _rooms(_lastMessageByPeer(myPubkey, messages)))
        .distinct(const ListEquality<ChatRoom>().equals);

    return Rx.merge([rooms, _sync.execute()]);
  }

  static Map<String, ChatMessage> _lastMessageByPeer(
    String myPubkey,
    List<ChatMessage> messages,
  ) {
    final result = <String, ChatMessage>{};
    for (final message in messages) {
      final peer = message.counterpartOf(myPubkey);
      final current = result[peer];
      if (current == null || message.publishedAt.isAfter(current.publishedAt)) {
        result[peer] = message;
      }
    }
    return result;
  }

  static List<ChatRoom> _rooms(Map<String, ChatMessage> lastMessages) {
    return [
      for (final MapEntry(key: peer, value: message) in lastMessages.entries)
        ChatRoom(peerPubkey: peer, lastMessage: message),
    ].sorted(
      (a, b) => b.lastMessage.publishedAt.compareTo(a.lastMessage.publishedAt),
    );
  }
}
