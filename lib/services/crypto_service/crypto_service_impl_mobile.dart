import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:nostr_notes/core/tools/disposable.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';
import 'package:nostr_notes/services/nip44/derive_keys.dart';
import 'package:nostr_notes/services/nip44/nip44.dart';

part 'spec256k1_isolate_part.dart';

final class IsWasmAvailable {
  const IsWasmAvailable();
  bool get isAvailable => false;
}

final class CryptoServiceImplMobile implements CryptoService {
  final Spec256k1Isolate _spec256k1Isolate;
  final DeriveKeys _deriveKeys;
  final _mobileNip44 = const Nip44();

  const CryptoServiceImplMobile._({
    required Spec256k1Isolate spec256k1Isolate,
    DeriveKeys deriveKeys = const DeriveKeys(),
  }) : _spec256k1Isolate = spec256k1Isolate,
       _deriveKeys = deriveKeys;

  factory CryptoServiceImplMobile({
    Spec256k1Isolate? spec256k1Isolate,
    DeriveKeys deriveKeys = const DeriveKeys(),
  }) {
    return CryptoServiceImplMobile._(
      spec256k1Isolate: spec256k1Isolate ?? Spec256k1Isolate(),
      deriveKeys: const DeriveKeys(),
    );
  }

  @override
  FutureOr<void> init() {}

  @override
  Future<Uint8List> deriveKeysAsync({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Future<Uint8List> Function(Uint8List)? extraDerivation,
  }) async {
    final key = await spec256k1Async(
      senderPrivateKey: HexToBytes.hexToBytes(senderPrivateKey),
      recipientPublicKey: HexToBytes.hexToBytes(recipientPublicKey),
    );

    if (extraDerivation == null) {
      return key;
    }

    final resut = extraDerivation(key);

    return resut;
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
  Future<Uint8List> spec256k1Async({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) async {
    // return _deriveKeys.spec256k1FromBytes(
    //   privateKeyBytes: senderPrivateKey,
    //   publicKeyBytes: recipientPublicKey,
    // );

    return _spec256k1Isolate.compute(
      senderPrivateKey: senderPrivateKey,
      recipientPublicKey: recipientPublicKey,
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

  @override
  Future<void> dispose() {
    return _spec256k1Isolate.dispose();
  }
}

final class CryptoServiceImplWeb implements CryptoService {
  CryptoServiceImplWeb();

  @override
  Future<void> init() async {}

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

  @override
  Future<Uint8List> spec256k1Async({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() {
    return Future.value();
  }

  @override
  Future<Uint8List> deriveKeysAsync({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Future<Uint8List> Function(Uint8List)? extraDerivation,
  }) => throw UnimplementedError();
}
