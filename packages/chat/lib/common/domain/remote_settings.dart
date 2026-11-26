/// Settings that can change without a new build; every value has a built-in
/// default, so the app works before the first fetch and offline.
///
/// Never holds secrets: anyone with the app can read these values.
abstract interface class RemoteSettings {
  Uri get signalingUri;

  List<String> get stunUrls;

  List<String> get turnUrls;

  /// Also how long an incoming call invite stays fresh.
  Duration get callAnswerTimeout;

  /// Restricts ICE to TURN relay candidates, for checking TURN.
  bool get callRelayOnly;

  /// Shown next to the user's pubkey to every signaling client.
  String get signalingClientName;

  /// Our Nostr relay, added to the relays suggested in the relay picker.
  Uri get chatRelay;
}
