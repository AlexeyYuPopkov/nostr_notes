/// Raw per-relay signals from [NostrClient], forwarded as they happen —
/// no interpretation, no aggregation, no state kept on [NostrClient]'s
/// side. A delegate (e.g. `RelaysMonitor`) turns these into whatever
/// domain concept it needs (connection status, health, metrics...).
abstract interface class NostrClientDelegate {
  /// A relay's stream reported an error (socket closed, decode failure...).
  void onRelayError(String url, Object error, StackTrace? stackTrace);

  /// Any inbound message was received from a relay (event, EOSE, OK...) —
  /// evidence the relay is alive and responding.
  void onRelayActivity(String url);
}
