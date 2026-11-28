import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:webrtc_call/webrtc_call.dart';

abstract interface class SendCallInviteUsecase {
  /// Stores a [ChatCallInvite] to [peerPubkey] and queues it for relays;
  /// returns its call id before delivery.
  Future<String> execute({
    required String peerPubkey,
    required CallMedia media,
  });
}
