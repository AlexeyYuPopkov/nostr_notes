import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_ffi;
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/core/tools/disposable.dart';
import 'package:nostr_notes/ffigen/ffigen_crypto_module.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';
import 'package:nostr_notes/services/nip44/derive_keys.dart';
import 'package:nostr_notes/services/nip44/nip44.dart';

part 'spec256k1_isolate_part.dart';

final _useFfi =
    AppConfig.kIsTest ||
    io.Platform.isMacOS ||
    io.Platform.isIOS ||
    io.Platform.isAndroid;

final class IsWasmAvailable {
  const IsWasmAvailable();
  bool get isAvailable => false;
}

final class CryptoServiceImplMobile implements CryptoService {
  final Spec256k1Isolate _spec256k1Isolate;
  final DeriveKeys _deriveKeys;
  final _mobileNip44 = const Nip44();

  late final lib = ffi.DynamicLibrary.open(libName);

  String get libName {
    if (io.Platform.isAndroid) {
      return 'crypto_module.so';
    } else if (io.Platform.isMacOS) {
      return 'crypto_module.framework/crypto_module';
    } else if (io.Platform.isIOS) {
      return 'crypto_module.framework/crypto_module';
    } else {
      assert(false, 'Unsupported platform');
      return '';
    }
  }

  late final _nativeLib = NativeLibrary(lib);

  CryptoServiceImplMobile._({
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
    if (_useFfi) {
      try {
        final result = _spec256k1Ffi(
          senderPrivateKey: senderPrivateKey,
          recipientPublicKey: recipientPublicKey,
        );

        return result;
      } catch (e) {
        log(
          'spec256k1Async FFI failed, falling back to isolate',
          name: 'CryptoService',
          error: e,
        );
      }
    }

    // return _deriveKeys.spec256k1FromBytes(
    //   privateKeyBytes: senderPrivateKey,
    //   publicKeyBytes: recipientPublicKey,
    // );

    final result = await _spec256k1Isolate.compute(
      senderPrivateKey: senderPrivateKey,
      recipientPublicKey: recipientPublicKey,
    );

    return result;
  }

  Uint8List _spec256k1Ffi({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) {
    final privKeyPtr = ffi_ffi.calloc<ffi.UnsignedChar>(
      senderPrivateKey.length,
    );
    final pubkeyToUse = Uint8List.fromList([2, ...recipientPublicKey]);
    final pubKeyPtr = ffi_ffi.calloc<ffi.UnsignedChar>(pubkeyToUse.length);
    final resultPtrPtr = ffi_ffi.calloc<ffi.Pointer<ffi.UnsignedChar>>(1);

    resultPtrPtr.value = ffi.nullptr;

    try {
      for (var i = 0; i < senderPrivateKey.length; i++) {
        privKeyPtr[i] = senderPrivateKey[i];
      }
      for (var i = 0; i < pubkeyToUse.length; i++) {
        pubKeyPtr[i] = pubkeyToUse[i];
      }

      final resultLen = _nativeLib.deriveSharedKey(
        privKeyPtr,
        pubKeyPtr,
        resultPtrPtr,
      );

      if (resultLen <= 0) {
        throw Exception('deriveSharedKey failed with code: $resultLen');
      }

      final resultPtr = resultPtrPtr.value;
      if (resultPtr == ffi.nullptr) {
        throw Exception('Result pointer is null');
      }

      final result = Uint8List(resultLen);
      for (var i = 0; i < resultLen; i++) {
        result[i] = resultPtr[i];
      }

      return result.sublist(0, 32).asUnmodifiableView();
    } finally {
      ffi_ffi.calloc.free(privKeyPtr);
      ffi_ffi.calloc.free(pubKeyPtr);
      ffi_ffi.calloc.free(resultPtrPtr);
    }
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
