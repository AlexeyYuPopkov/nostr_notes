/// Live fetch of the vault's login-item events (and their deletion requests)
/// from the current relay set into the local event store; the store's
/// replaceable-event handling keeps the newest version per item.
///
/// Returns a stream of raw event batches as they arrive from relays — each
/// list element is a `NostrEvent` (kept as `dynamic` to match the
/// `NotesRepository.eventsStream`/`FetchNotesUsecase` convention used for
/// this same "raw relay events, already upserted into the store" shape).
/// Callers that want decrypted items should read from the local store (via
/// `WatchLoginItemsUsecase`), not from this stream directly.
abstract interface class SyncLoginItemsUsecase {
  Stream<List<dynamic>> execute();
}
