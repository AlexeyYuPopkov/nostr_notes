abstract interface class RelaysListRepo {
  Set<String> getRelaysList();
  Future<void> saveRelaysList(List<String> relays);
  Set<String> getSuggestedRelays();
}
