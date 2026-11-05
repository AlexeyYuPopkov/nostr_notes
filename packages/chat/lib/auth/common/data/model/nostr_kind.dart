abstract final class NostrKind {
  static const int user = 0;

  /// One-to-one chat message: addressable by `d` so it can be edited,
  /// NIP-44 encrypted, addressed to the peer by a `p` tag.
  static const int directMessage = 31014;
}
