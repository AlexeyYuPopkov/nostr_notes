abstract interface class SendChatMessageUsecase {
  /// Stores the message and queues it for relays; returns before delivery.
  Future<void> execute({required String peerPubkey, required String text});
}
