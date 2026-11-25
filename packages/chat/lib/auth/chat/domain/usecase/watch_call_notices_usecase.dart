import 'package:chat/auth/chat/domain/models/chat_message_body.dart';

abstract interface class WatchCallNoticesUsecase {
  /// Notices from [peerPubkey] about the call [callId], as they reach the
  /// store, including ones already there. Keeps the relay sync running while
  /// listened to.
  Stream<ChatCallNotice> execute({
    required String peerPubkey,
    required String callId,
  });
}
