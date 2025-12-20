import 'dart:async';
import 'dart:typed_data';

import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/nip44/derive_keys.dart';
import 'package:nostr_notes/services/nip44/nip44.dart';

final class IsWasmAvailable {
  const IsWasmAvailable();
  bool get isAvailable => false;
}

final class CryptoServiceImplMobile implements CryptoService {
  final DeriveKeys _deriveKeys;
  final _mobileNip44 = const Nip44();

  const CryptoServiceImplMobile([DeriveKeys deriveKeys = const DeriveKeys()])
    : _deriveKeys = deriveKeys;

  @override
  FutureOr<void> init() {}

  @override
  Uint8List deriveKeys({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Uint8List Function(Uint8List)? extraDerivation,
  }) {
    return _deriveKeys.execute(
      senderPrivateKey: senderPrivateKey,
      recipientPublicKey: recipientPublicKey,
      extraDerivation: extraDerivation,
    );
  }

  @override
  Uint8List spec256k1({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) {
    return _deriveKeys.spec256k1FromBytes(
      privateKeyBytes: senderPrivateKey,
      publicKeyBytes: recipientPublicKey,
    );
  }

  @override
  Future<String> decryptNip44({
    required String payload,
    required Uint8List conversationKey,
  }) {
    return _mobileNip44.decryptMessage(
      payload: payload,
      conversationKey: conversationKey,
    );
  }

  @override
  Future<String> encryptNip44({
    required String plaintext,
    required Uint8List conversationKey,
    Uint8List? customNonce,
  }) {
    return _mobileNip44.encryptMessage(
      plaintext: plaintext,
      customNonce: customNonce,
      conversationKey: conversationKey,
    );
  }
}

final class CryptoServiceImplWeb implements CryptoService {
  CryptoServiceImplWeb();

  @override
  Future<void> init() async {}

  @override
  Uint8List deriveKeys({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Uint8List Function(Uint8List p1)? extraDerivation,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> decryptNip44({
    required String payload,
    required Uint8List conversationKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> encryptNip44({
    required String plaintext,
    required Uint8List conversationKey,
    Uint8List? customNonce,
  }) {
    throw UnimplementedError();
  }

  @override
  Uint8List spec256k1({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) => throw UnimplementedError();
}
