/// A conversation between two pubkeys, the same whichever side wrote.
extension type const RoomId._(String value) {
  factory RoomId.of(String pubkey, String otherPubkey) {
    final pair = [pubkey, otherPubkey]..sort();
    return RoomId._(pair.join(':'));
  }
}
