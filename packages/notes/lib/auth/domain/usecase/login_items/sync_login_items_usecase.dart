/// One-shot fetch of the vault's login-item events (and their deletion
/// requests) from the current relay set into the local event store; the
/// store's replaceable-event handling keeps the newest version per item.
///
/// Returns the number of events received.
abstract interface class SyncLoginItemsUsecase {
  Future<int> execute();
}
