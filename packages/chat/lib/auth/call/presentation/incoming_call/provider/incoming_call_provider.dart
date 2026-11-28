import 'dart:async';

import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/domain/usecase/get_contact_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/send_call_notice_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/watch_call_notices_usecase.dart';
import 'package:common/domain/model/user.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'incoming_call_data.dart';

part 'incoming_call_provider.g.dart';

/// The ringing invite [callId] from [callerPubkey].
@riverpod
final class IncomingCallProvider extends _$IncomingCallProvider {
  final GetContactUsecase _getContact = GetIt.I.get();
  final WatchCallNoticesUsecase _watchNotices = GetIt.I.get();
  final SendCallNoticeUsecase _sendNotice = GetIt.I.get();

  @override
  IncomingCallData build(String callerPubkey, String callId) {
    final contact = _getContact
        .execute(callerPubkey)
        .listen(
          (caller) => state = state.copyWith(caller: caller),
          // Without a profile the caller is shown by the short npub.
          onError: (Object _) {},
        );
    final notices = _watchNotices
        .execute(peerPubkey: callerPubkey, callId: callId)
        .where((notice) => notice is ChatCallCancel)
        .listen(
          (_) => state = state.copyWith(isCancelled: true),
          onError: (Object _) {},
        );
    ref.onDispose(() {
      unawaited(contact.cancel());
      unawaited(notices.cancel());
    });
    return IncomingCallData(caller: User(pubkey: callerPubkey));
  }

  /// Tells the caller, so they stop waiting before the invite expires.
  Future<void> decline() => _sendNotice.execute(
    peerPubkey: callerPubkey,
    notice: ChatCallDecline(callId),
  );
}
