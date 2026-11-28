import 'dart:async';

import 'package:chat/auth/call/domain/models/call_direction.dart';
import 'package:chat/auth/call/domain/usecase/open_call_connection_usecase.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/domain/usecase/get_contact_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/send_call_invite_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/send_call_notice_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/watch_call_notices_usecase.dart';
import 'package:common/domain/model/user.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:webrtc_call/webrtc_call.dart';

import 'call_data.dart';
import 'call_state.dart';

part 'call_provider.g.dart';

/// A call with [peerPubkey]; it ends when the provider is disposed.
///
/// An outgoing call also follows its invite: a decline from the peer ends
/// the call, and hanging up before the peer answered cancels the invite.
@riverpod
final class CallProvider extends _$CallProvider {
  final OpenCallConnectionUsecase _openConnection = GetIt.I.get();
  final GetContactUsecase _getContact = GetIt.I.get();
  final SendCallInviteUsecase _sendInvite = GetIt.I.get();
  final SendCallNoticeUsecase _sendNotice = GetIt.I.get();
  final WatchCallNoticesUsecase _watchNotices = GetIt.I.get();

  CallConnection? _connection;
  StreamSubscription<ChatCallNotice>? _notices;
  String? _callId;
  bool _wasAnswered = false;
  bool _wasDeclined = false;
  bool _wasCancelled = false;

  @override
  CallState build(String peerPubkey, CallMedia media, CallDirection direction) {
    final peer = _getContact
        .execute(peerPubkey)
        .listen(
          (peer) => state = state.withData(state.data.copyWith(peer: peer)),
          // Without a profile the call goes on under the short npub.
          onError: (Object _) {},
        );
    ref.onDispose(() {
      unawaited(peer.cancel());
      unawaited(_notices?.cancel());
      _cancelUnansweredInvite();
      unawaited(_connection?.close());
    });
    unawaited(_start());

    return CallStarting(
      data: CallData(
        peer: User(pubkey: peerPubkey),
        media: media,
      ),
    );
  }

  Future<void> _start() async {
    try {
      if (direction == CallDirection.outgoing) {
        await _sendOutgoingInvite();
      }
      final connection = await _openConnection.execute();
      if (!ref.mounted) {
        await connection.close();
        return;
      }
      _connection = connection;
      final session = connection.session;
      state = CallActive(data: state.data, session: session);
      session.phase.addListener(() => _onPhase(session));

      switch (direction) {
        case CallDirection.outgoing:
          final calling = session.call(
            peerPubkey,
            media: media,
            answerTimeout: connection.answerTimeout,
          );
          if (_wasDeclined) await session.declinedByPeer();
          await calling;
        case CallDirection.incoming:
          session.awaitCall(
            peerPubkey,
            media: media,
            offerTimeout: connection.answerTimeout,
          );
      }
    } catch (error) {
      if (!ref.mounted) return;
      state = CallStartError(data: state.data, error: error);
    }
  }

  /// The invite is what makes the peer join; it travels while we connect.
  Future<void> _sendOutgoingInvite() async {
    final callId = await _sendInvite.execute(
      peerPubkey: peerPubkey,
      media: media,
    );
    _callId = callId;
    _notices = _watchNotices
        .execute(peerPubkey: peerPubkey, callId: callId)
        .listen(_onNotice, onError: (Object _) {});
  }

  void _onNotice(ChatCallNotice notice) {
    if (notice is! ChatCallDecline || _wasAnswered) return;
    _wasDeclined = true;
    unawaited(_connection?.session.declinedByPeer());
  }

  void _onPhase(PeerConnectionSession session) {
    switch (session.phase.value) {
      case CallPhase.connecting ||
          CallPhase.connected ||
          CallPhase.reconnecting:
        _wasAnswered = true;
      case CallPhase.idle:
        _cancelUnansweredInvite();
      case CallPhase.calling:
        break;
    }
  }

  void _cancelUnansweredInvite() {
    final callId = _callId;
    if (callId == null || _wasAnswered || _wasDeclined || _wasCancelled) {
      return;
    }
    _wasCancelled = true;
    // Best effort: an invite nobody cancels still expires on its own.
    unawaited(
      _sendNotice
          .execute(peerPubkey: peerPubkey, notice: ChatCallCancel(callId))
          .then((_) {}, onError: (Object _) {}),
    );
  }
}
