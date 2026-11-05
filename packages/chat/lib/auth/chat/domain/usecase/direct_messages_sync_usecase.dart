abstract interface class DirectMessagesSyncUsecase {
  /// While listened to, keeps a relay subscription that fills the store with
  /// the current user's direct messages; the first listener also starts
  /// delivering queued ones. Listeners share one subscription.
  Stream<Never> execute();
}
