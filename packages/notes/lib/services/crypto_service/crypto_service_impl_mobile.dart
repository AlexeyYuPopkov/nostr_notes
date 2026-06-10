import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:common/tools/app_worker/app_worker.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/crypto_service/spec256k1_isolate_part.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';
import 'package:nostr_notes/services/nip44/derive_keys.dart';
import 'package:nostr_notes/services/nip44/nip44.dart';

final class IsWasmAvailable {
  const IsWasmAvailable();
  bool get isAvailable => false;
}

final class CryptoServiceImplMobile implements CryptoService {
  final Spec256k1Isolate _spec256k1Isolate;
  final AppWorker _appWorker = AppWorker.instance;
  final DeriveKeys _deriveKeys;
  final Uint8List? _randomBytes;
  final _mobileNip44 = const Nip44();

  CryptoServiceImplMobile._({
    required Spec256k1Isolate spec256k1Isolate,
    DeriveKeys deriveKeys = const DeriveKeys(),
    Uint8List? randomBytes,
  }) : _spec256k1Isolate = spec256k1Isolate,
       _deriveKeys = deriveKeys,
       _randomBytes = randomBytes;

  factory CryptoServiceImplMobile({
    Spec256k1Isolate? spec256k1Isolate,
    DeriveKeys deriveKeys = const DeriveKeys(),
    Uint8List? randomBytes,
  }) {
    return CryptoServiceImplMobile._(
      spec256k1Isolate: spec256k1Isolate ?? Spec256k1Isolate(),
      deriveKeys: const DeriveKeys(),
      randomBytes: randomBytes,
    );
  }

  @override
  FutureOr<void> init() {
    return _spec256k1Isolate.init();
  }

  @override
  Future<Uint8List> deriveKeysAsync({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Future<Uint8List> Function(Uint8List)? extraDerivation,
  }) async {
    final stopwatch = Stopwatch()..start();
    final key = await spec256k1Async(
      senderPrivateKey: HexToBytes.hexToBytes(senderPrivateKey),
      recipientPublicKey: HexToBytes.hexToBytes(recipientPublicKey),
    );

    if (extraDerivation == null) {
      return key;
    }

    final resut = extraDerivation(key);

    stopwatch.stop();
    // print('deriveKeysAsync completed in ${stopwatch.elapsedMilliseconds} ms');
    log(
      'deriveKeysAsync completed in ${stopwatch.elapsedMilliseconds} ms',
      name: 'CryptoService',
    );

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
    Stopwatch stopwatch = Stopwatch()..start();

    final result = AppConfig.kIsTest
        ? _deriveKeys.spec256k1FromBytes(
            privateKeyBytes: senderPrivateKey,
            publicKeyBytes: recipientPublicKey,
          )
        : await _spec256k1Isolate.compute(
            senderPrivateKey: senderPrivateKey,
            recipientPublicKey: recipientPublicKey,
          );

    stopwatch.stop();
    log(
      'spec256k1Async completed in ${stopwatch.elapsedMilliseconds} ms',
      name: 'CryptoService',
    );

    return result;
  }

  @override
  Future<String> decryptNip44({
    required String payload,
    required Uint8List conversationKey,
  }) {
    if (AppConfig.kIsTest) {
      return _mobileNip44.decryptMessage(
        payload: payload,
        conversationKey: conversationKey,
      );
    } else {
      return _appWorker.compute(
        params: (payload, conversationKey),
        callback: _decryptNip44,
      );
    }
  }

  @override
  Future<String> encryptNip44({
    required String plaintext,
    required Uint8List conversationKey,
  }) {
    if (AppConfig.kIsTest) {
      return _mobileNip44.encryptMessage(
        plaintext: plaintext,
        customNonce: _randomBytes,
        conversationKey: conversationKey,
      );
    } else {
      return _appWorker.compute(
        params: (plaintext, _randomBytes, conversationKey),
        callback: _encryptMessage,
      );
    }
  }

  @override
  Future<void> dispose() {
    return _spec256k1Isolate.dispose();
  }

  static Future<String> _decryptNip44((String, Uint8List) params) {
    return const Nip44().decryptMessage(
      payload: params.$1,
      conversationKey: params.$2,
    );
  }

  static Future<String> _encryptMessage(
    (String, Uint8List?, Uint8List) params,
  ) {
    return const Nip44().encryptMessage(
      plaintext: params.$1,
      customNonce: params.$2,
      conversationKey: params.$3,
    );
  }
}

final class CryptoServiceImplWeb implements CryptoService {
  CryptoServiceImplWeb({Uint8List? randomBytes});

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
