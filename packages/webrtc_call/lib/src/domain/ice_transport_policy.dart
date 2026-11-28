/// Which ICE candidates a call may use.
enum IceTransportPolicy {
  all,

  /// TURN only; used to check that calls go through the relay.
  relay,
}
