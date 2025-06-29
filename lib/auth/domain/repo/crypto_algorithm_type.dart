import 'dart:typed_data';

sealed class CryptoAlgorithmType {
  const CryptoAlgorithmType._();

  const factory CryptoAlgorithmType.nip04({
    required String privateKey,
    required String peerPubkey,
  }) = Nip04CryptoAlgorithmType;

  const factory CryptoAlgorithmType.nip44({
    required String privateKey,
    required String peerPubkey,
    Uint8List? conversationKey,
    String? additionalPassword,
  }) = Nip44CryptoAlgorithmType;

  const factory CryptoAlgorithmType.aes({
    required String password,
    Map<String, Uint8List>? cashedKeys,
  }) = AesCryptoAlgorithmType;
}

final class Nip04CryptoAlgorithmType extends CryptoAlgorithmType {
  final String privateKey;
  final String peerPubkey;

  const Nip04CryptoAlgorithmType({
    required this.privateKey,
    required this.peerPubkey,
  }) : super._();
}

final class Nip44CryptoAlgorithmType extends CryptoAlgorithmType {
  final String privateKey;
  final String peerPubkey;
  final Uint8List? conversationKey;
  final String? additionalPassword;

  const Nip44CryptoAlgorithmType({
    required this.privateKey,
    required this.peerPubkey,
    this.conversationKey,
    this.additionalPassword,
  }) : super._();

  Nip44CryptoAlgorithmType copyWith({
    Uint8List? conversationKey,
  }) {
    return Nip44CryptoAlgorithmType(
      privateKey: privateKey,
      peerPubkey: peerPubkey,
      conversationKey: conversationKey ?? this.conversationKey,
    );
  }
}

final class AesCryptoAlgorithmType extends CryptoAlgorithmType {
  final String password;
  final Map<String, Uint8List>? cashedKeys;
  const AesCryptoAlgorithmType({
    required this.password,
    this.cashedKeys,
  }) : super._();
}
