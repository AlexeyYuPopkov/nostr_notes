import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service_impl_mobile.dart'
    if (dart.library.js_interop) 'package:nostr_notes/services/crypto_service/crypto_service_impl_web.dart';

abstract interface class CryptoService {
  Uint8List deriveKeys({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Uint8List Function(Uint8List)? extraDerivation,
  });

  Uint8List spec256k1({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  });

  Future<String> encryptNip44({
    required String plaintext,
    required Uint8List conversationKey,
    Uint8List? customNonce,
  });

  Future<String> decryptNip44({
    required String payload,
    required Uint8List conversationKey,
  });

  FutureOr<void> init();

  factory CryptoService.create() {
    // return CryptoServiceImplWeb();
    // return CryptoServiceImplMobile();
    if (kIsWeb && const IsWasmAvailable().isAvailable) {
      return CryptoServiceImplWeb();
    } else {
      return const CryptoServiceImplMobile();
    }
  }
}

/// Parameters for NIP-04 decryption with raw byte arrays
// final class Nip04RawParams {
//   final Uint8List peerPubkey;
//   final Uint8List privateKey;
//   final Uint8List iv;
//   final Uint8List encryptedContent;

//   const Nip04RawParams({
//     required this.peerPubkey,
//     required this.privateKey,
//     required this.iv,
//     required this.encryptedContent,
//   });

//   factory Nip04RawParams.fromEncoded({
//     required String encryptedContent,
//     required String peerPubkey,
//     required String privateKey,
//   }) {
//     final ivIndex = encryptedContent.indexOf('?iv=');
//     if (ivIndex <= 0) {
//       throw Exception(
//         'Invalid encrypted content for dm, could not get ivIndex: $encryptedContent',
//       );
//     }
//     final iv = encryptedContent.substring(
//       ivIndex + '?iv='.length,
//       encryptedContent.length,
//     );

//     final encString = encryptedContent.substring(0, ivIndex);

//     return Nip04RawParams(
//       peerPubkey: ('02$peerPubkey').hexToBytes(),
//       privateKey: privateKey.hexToBytes(),
//       iv: base64.decode(iv),
//       encryptedContent: base64.decode(encString),
//     );
//   }
// }

// extension on String {
//   Uint8List hexToBytes() {
//     final theLength = length;
//     final result = Uint8List(theLength ~/ 2);
//     for (int i = 0; i < theLength; i += 2) {
//       result[i ~/ 2] = int.parse(substring(i, i + 2), radix: 16);
//     }
//     return result;
//   }
// }
