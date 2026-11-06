abstract interface class SearchContactsFetchUsecase {
  /// Asks relays for profiles (kind 0) matching [query] and stores what they
  /// return; read the result through `SearchContactsGetUsecase`. Completes
  /// once relays have answered or timed out, immediately for a blank query.
  Future<void> execute(String query);
}
