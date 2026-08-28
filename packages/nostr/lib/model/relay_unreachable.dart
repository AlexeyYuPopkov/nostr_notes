/// Raised when a relay cannot be written to at all — its channel is gone and
/// reconnecting did not bring it back. Reported like any other relay error so
/// a failed send is visible immediately, rather than only once the socket
/// itself gets around to reporting its death.
final class RelayUnreachable implements Exception {
  final String relayUrl;

  const RelayUnreachable(this.relayUrl);

  @override
  String toString() => 'RelayUnreachable: $relayUrl';
}
