import 'package:chat/auth/chat/domain/models/chat_message.dart';

abstract interface class WatchIncomingCallInvitesUsecase {
  /// Call invites from peers that are still fresh enough to answer, each once
  /// per app run, as they reach the store. Keeps the relay sync running while
  /// listened to.
  Stream<ChatMessage> execute();

  /// How long after it was sent an invite can still be answered.
  Duration get inviteLifetime;
}
