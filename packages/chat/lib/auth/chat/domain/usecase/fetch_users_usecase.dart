abstract interface class FetchUsersUsecase {
  /// Keeps a live relay subscription to kind 0 of [pubkeys] while listened to
  /// and stores every profile it receives; read them back through
  /// `GetUserUseCase`. Emits after each stored batch.
  Stream<void> execute({required Set<String> pubkeys});
}
