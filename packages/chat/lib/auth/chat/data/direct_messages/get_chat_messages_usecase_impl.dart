import 'package:chat/auth/chat/domain/models/chat_exception.dart';
import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/usecase/direct_messages_sync_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_chat_messages_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import 'direct_message_tags.dart';
import 'direct_messages_reader.dart';

final class GetChatMessagesUsecaseImpl implements GetChatMessagesUsecase {
  final SessionUsecase _sessionUsecase;
  final DirectMessagesReader _reader;
  final DirectMessagesSyncUsecase _sync;

  const GetChatMessagesUsecaseImpl({
    required this._sessionUsecase,
    required this._reader,
    required this._sync,
  });

  @override
  Stream<List<ChatMessage>> execute({required String peerPubkey}) {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      return Stream.error(const ChatNoSessionException());
    }
    final messages = _reader
        .watch(
          keys: keys,
          queries: [
            DirectMessageTags.sentBy(keys.publicKey, to: peerPubkey),
            if (peerPubkey != keys.publicKey)
              DirectMessageTags.sentBy(peerPubkey, to: keys.publicKey),
          ],
        )
        .map(
          (messages) =>
              messages.sorted((a, b) => a.publishedAt.compareTo(b.publishedAt)),
        )
        .distinct(const ListEquality<ChatMessage>().equals);

    return Rx.merge([messages, _sync.execute()]);
  }
}
