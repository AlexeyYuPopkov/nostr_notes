import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nostr_notes/core/tools/disposable.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service_impl_mobile.dart'
    if (dart.library.js_interop) 'package:nostr_notes/services/crypto_service/crypto_service_impl_web.dart';

abstract interface class CryptoService implements Disposable {
  Future<Uint8List> deriveKeysAsync({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Future<Uint8List> Function(Uint8List)? extraDerivation,
  });

  Uint8List spec256k1({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  });

  Future<Uint8List> spec256k1Async({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  });

  Future<String> encryptNip44({
    required String plaintext,
    required Uint8List conversationKey,
  });

  Future<String> decryptNip44({
    required String payload,
    required Uint8List conversationKey,
  });

  FutureOr<void> init();

  factory CryptoService.create([Uint8List? randomBytes]) {
    if (kIsWeb) {
      return CryptoServiceImplWeb(randomBytes: randomBytes);
    } else {
      return CryptoServiceImplMobile(randomBytes: randomBytes);
    }
  }
}
