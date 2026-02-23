abstract interface class RelaysListRepo {
  Set<String> getRelaysList();
  Future<void> saveRelaysList(Set<String> relays);
  Set<String> getSuggestedRelays();
  Stream<Set<String>> get relaysListStream;
}
