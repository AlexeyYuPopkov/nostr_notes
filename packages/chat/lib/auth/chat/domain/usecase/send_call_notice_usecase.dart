import 'package:chat/auth/chat/domain/models/chat_message_body.dart';

abstract interface class SendCallNoticeUsecase {
  /// Stores [notice] to [peerPubkey] and queues it for relays; returns before
  /// delivery.
  Future<void> execute({
    required String peerPubkey,
    required ChatCallNotice notice,
  });
}
