final class UserKeys {
  final String publicKey;
  final String privateKey;

  const UserKeys({required this.publicKey, required this.privateKey});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserKeys &&
          runtimeType == other.runtimeType &&
          publicKey == other.publicKey &&
          privateKey == other.privateKey;

  @override
  int get hashCode => Object.hash(publicKey, privateKey);
}
