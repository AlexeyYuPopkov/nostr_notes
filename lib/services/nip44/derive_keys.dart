import 'package:elliptic/ecdh.dart';
import 'package:elliptic/elliptic.dart';
import 'package:flutter/foundation.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';
import 'package:nostr_notes/services/nip44/nip_44_utils.dart';

final class DeriveKeys with HexToBytes {
  const DeriveKeys();

  Uint8List execute({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Uint8List Function(Uint8List)? extraDerivation,
  }) {
    final key = spec256k1(senderPrivateKey, recipientPublicKey);

    if (extraDerivation == null) {
      return key;
    }

    final resut = extraDerivation(key);

    return resut;
  }

  Uint8List spec256k1FromBytes({
    required Uint8List privateKeyBytes,
    required Uint8List publicKeyBytes,
  }) {
    return _spec256k1FromBytes(
      privateKeyBytes: privateKeyBytes,
      publicKeyBytes: publicKeyBytes,
    );
  }

  static Uint8List spec256k1(String privateKeyHex, String publicKeyHex) {
    final ec = getS256();
    final privateKey = PrivateKey.fromHex(ec, privateKeyHex);
    final publicKey = PublicKey.fromHex(ec, checkPublicKey(publicKeyHex));
    final sec = computeSecret(privateKey, publicKey);
    return Uint8List.fromList(sec);
  }

  static Uint8List _spec256k1FromBytes({
    required Uint8List privateKeyBytes,
    required Uint8List publicKeyBytes,
  }) {
    final ec = getS256();
    final privateKey = PrivateKey.fromBytes(ec, privateKeyBytes);
    final publicKey = PublicKey.fromHex(
      ec,
      checkPublicKey(HexToBytes.bytesToHex(publicKeyBytes)),
    );
    final sec = computeSecret(privateKey, publicKey);
    return Uint8List.fromList(sec);
  }

  // static Uint8List deriveConversationKey(Uint8List sharedSecret) {
  //   final salt = utf8.encode('nip44-v2');

  //   final conversationKey = hkdfExtract(
  //     ikm: sharedSecret,
  //     salt: Uint8List.fromList(salt),
  //   );

  //   return conversationKey;
  // }
}
