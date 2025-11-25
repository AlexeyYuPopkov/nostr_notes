import 'dart:convert';

import 'package:elliptic/ecdh.dart';
import 'package:elliptic/elliptic.dart';
import 'package:flutter/foundation.dart';
import 'package:nostr_notes/services/nip44/nip_44_utils.dart';

final class DeriveKeys {
  const DeriveKeys();

  Uint8List execute({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Uint8List Function(Uint8List)? extraDerivation,
  }) {
    final sharedSecret = extraDerivation == null
        ? computeSharedSecret(senderPrivateKey, recipientPublicKey)
        : extraDerivation(
            computeSharedSecret(senderPrivateKey, recipientPublicKey),
          );

    return sharedSecret;
  }

  static Uint8List computeSharedSecret(
    String privateKeyHex,
    String publicKeyHex,
  ) {
    final ec = getS256();
    final privateKey = PrivateKey.fromHex(ec, privateKeyHex);
    final publicKey = PublicKey.fromHex(ec, checkPublicKey(publicKeyHex));
    final sec = computeSecret(privateKey, publicKey);
    return Uint8List.fromList(sec);
  }

  static Uint8List deriveConversationKey(Uint8List sharedSecret) {
    final salt = utf8.encode('nip44-v2');

    final conversationKey = hkdfExtract(
      ikm: sharedSecret,
      salt: Uint8List.fromList(salt),
    );

    return conversationKey;
  }
}
