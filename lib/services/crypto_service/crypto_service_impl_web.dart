import 'dart:async';
import 'dart:developer';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/nip44/nip44.dart';
import 'package:wasm_ffi/ffi.dart' as wasm;
import 'package:wasm_ffi/ffi_utils.dart' as wasm_utils;

@JS('WebAssembly')
external JSObject? get webAssembly;

final class IsWasmAvailable {
  const IsWasmAvailable();
  bool get isAvailable => true; // webAssembly != null;
}

final class CryptoServiceImplWeb implements CryptoService {
  static CryptoServiceImplWeb? _instance;
  static bool _isInit = false;

  final _mobileNip44 = const Nip44();

  late final wasm.DynamicLibrary _lib;

  late final int Function(
    wasm.Pointer<wasm.Uint8>,
    wasm.Pointer<wasm.Uint8>,
    wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
  ) _deriveSharedKeyWasm;

  CryptoServiceImplWeb._();

  factory CryptoServiceImplWeb() {
    return _instance ??= CryptoServiceImplWeb._();
  }

  @override
  Future<void> init() async {
    if (_isInit) {
      log('WASM library already initialized', name: 'WASM');
      return;
    }

    _isInit = true;

    try {
      log('WASM library already try init', name: 'WASM');

      _lib = await wasm.DynamicLibrary.open(
        'assets/assets/wasm/crypto_module.wasm',
      );

      _deriveSharedKeyWasm = _lib
          .lookup<
              wasm.NativeFunction<
                  int Function(
                    wasm.Pointer<wasm.Uint8>,
                    wasm.Pointer<wasm.Uint8>,
                    wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
                  )>>('deriveSharedKey')
          .asFunction<
              int Function(
                wasm.Pointer<wasm.Uint8>,
                wasm.Pointer<wasm.Uint8>,
                wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
              )>();

      log('WASM library loaded successfully', name: 'Wasm');
    } catch (e) {
      log('Failed to load WASM library: $e', name: 'Wasm');
      rethrow;
    }
  }

  @override
  Uint8List deriveKeys({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Uint8List Function(Uint8List p1)? extraDerivation,
  }) {
    // return _mobileNip44.deriveKeys(
    //     senderPrivateKey: senderPrivateKey,
    //     recipientPublicKey: recipientPublicKey);

    // final r2 = _deriveKeys(
    //   senderPrivateKey: senderPrivateKey,
    //   recipientPublicKey: recipientPublicKey,
    // );

    // return r2.sublist(0, 32);
    return extraDerivation == null
        ? _deriveKeys(
            senderPrivateKey: senderPrivateKey,
            recipientPublicKey: recipientPublicKey,
          )
        : extraDerivation(
            _deriveKeys(
              senderPrivateKey: senderPrivateKey,
              recipientPublicKey: recipientPublicKey,
            ),
          );
  }

  Uint8List _deriveKeys({
    required String senderPrivateKey,
    required String recipientPublicKey,
  }) {
    return wasm_utils.using((arena) {
      final privateKey = senderPrivateKey.hexToBytes();
      final privateKeyLength = privateKey.length;
      final ptrPrivKey = arena.allocate<wasm.Uint8>(privateKeyLength);
      ptrPrivKey.asTypedList(privateKeyLength).setAll(0, privateKey);

      final publicKey = ('02$recipientPublicKey').hexToBytes();
      final publicKeyLength = publicKey.length;
      final ptrPubKey = arena.allocate<wasm.Uint8>(publicKeyLength);
      ptrPubKey.asTypedList(publicKeyLength).setAll(0, publicKey);

      // RU: Выделяем указатель на выходной буфер: unsigned char** result
      // EN: Allocate pointer for output buffer: unsigned char** result
      final ptrResultPtr = arena.allocate<wasm.Pointer<wasm.Uint8>>(1);

      // RU: Вызов C-функции: int nip04encrypt(..., resultPtr)
      // EN: Call C function: int nip04encrypt(..., resultPtr)
      final resultLen = _deriveSharedKeyWasm(
        ptrPrivKey,
        ptrPubKey,
        ptrResultPtr,
      );

      // RU: Получаем реальный указатель на буфер из resultPtr
      // EN: Get the actual pointer to the buffer from resultPtr
      final resultPtr = ptrResultPtr.value;

      // RU: Создаём копию результата и освобождаем память
      // EN: Create a copy of the result and free memory
      final result = resultPtr.asTypedList(resultLen);

      return result;
    }, _lib.allocator);
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

final class CryptoServiceImplMobile implements CryptoService {
  const CryptoServiceImplMobile();
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
}

extension on String {
  Uint8List hexToBytes() {
    final theLength = length;
    final result = Uint8List(theLength ~/ 2);
    for (int i = 0; i < theLength; i += 2) {
      result[i ~/ 2] = int.parse(substring(i, i + 2), radix: 16);
    }
    return result;
  }
}
