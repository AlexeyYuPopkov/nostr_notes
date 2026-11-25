import 'package:chat/auth/chat/domain/models/chat_exception.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/domain/usecase/direct_messages_sync_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/watch_call_notices_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:rxdart/rxdart.dart';

import 'direct_message_tags.dart';
import 'direct_messages_reader.dart';

final class WatchCallNoticesUsecaseImpl implements WatchCallNoticesUsecase {
  final SessionUsecase _sessionUsecase;
  final DirectMessagesReader _reader;
  final DirectMessagesSyncUsecase _sync;

  const WatchCallNoticesUsecaseImpl({
    required this._sessionUsecase,
    required this._reader,
    required this._sync,
  });

  @override
  Stream<ChatCallNotice> execute({
    required String peerPubkey,
    required String callId,
  }) {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      return Stream.error(const ChatNoSessionException());
    }

    final notices = _reader
        .watch(
          keys: keys,
          queries: [DirectMessageTags.receivedBy(keys.publicKey)],
        )
        .expand(
          (messages) => [
            for (final message in messages)
              if (message.authorPubkey == peerPubkey)
                if (message.body case final ChatCallNotice notice
                    when notice.callId == callId)
                  notice,
          ],
        )
        .distinct();

    return Rx.merge([notices, _sync.execute()]);
  }
}
