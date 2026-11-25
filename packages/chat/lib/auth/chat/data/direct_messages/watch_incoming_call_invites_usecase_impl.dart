import 'package:chat/auth/chat/domain/models/chat_exception.dart';
import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/domain/usecase/direct_messages_sync_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/watch_incoming_call_invites_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webrtc_call/webrtc_call.dart';

import 'direct_message_tags.dart';
import 'direct_messages_reader.dart';

/// Registered once per session: the invites it has shown stay shown even when
/// the listener resubscribes.
final class WatchIncomingCallInvitesUsecaseImpl
    implements WatchIncomingCallInvitesUsecase {
  /// The caller gives up after this long, so an older invite cannot be joined.
  static const lifetime = PeerConnectionSession.defaultAnswerTimeout;

  final SessionUsecase _sessionUsecase;
  final DirectMessagesReader _reader;
  final DirectMessagesSyncUsecase _sync;
  final DateTime Function() _now;
  final _shownCallIds = <String>{};

  WatchIncomingCallInvitesUsecaseImpl({
    required this._sessionUsecase,
    required this._reader,
    required this._sync,
    this._now = DateTime.now,
  });

  @override
  Stream<ChatMessage> execute() {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      return Stream.error(const ChatNoSessionException());
    }
    final myPubkey = keys.publicKey;

    final invites = _reader
        .watch(keys: keys, queries: [DirectMessageTags.receivedBy(myPubkey)])
        .expand(_uncancelled)
        .where(
          (message) => message.authorPubkey != myPubkey && _isFresh(message),
        )
        .where(_showsFirstTime);

    return Rx.merge([invites, _sync.execute()]);
  }

  /// Drops invites whose caller already hung up, so opening the app after a
  /// short call does not ring for it.
  static Iterable<ChatMessage> _uncancelled(List<ChatMessage> messages) {
    final cancelledCallIds = {
      for (final message in messages)
        if (message.body case ChatCallCancel(:final callId)) callId,
    };
    return messages.where(
      (message) => switch (message.body) {
        ChatCallInvite(:final callId) => !cancelledCallIds.contains(callId),
        _ => true,
      },
    );
  }

  bool _isFresh(ChatMessage message) =>
      message.body is ChatCallInvite &&
      _now().difference(message.publishedAt) <= lifetime;

  bool _showsFirstTime(ChatMessage message) => switch (message.body) {
    ChatCallInvite(:final callId) => _shownCallIds.add(callId),
    ChatText() || ChatCallNotice() => false,
  };
}
