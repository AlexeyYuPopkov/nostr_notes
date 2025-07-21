import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:wasm_ffi/ffi.dart' as wasm;
import 'package:wasm_ffi/ffi_utils.dart' as wasm_utils;

import 'aes_cbc_repo.dart';

final class AesCbcImplWeb implements AesCbcRepo {
  static AesCbcImplWeb? _instance;

  late final wasm.DynamicLibrary _lib;
  late final double Function(double) someFunc;

  late final _freeMemoryWasm = _lib
      .lookup<
          wasm.NativeFunction<
              wasm.Void Function(wasm.Pointer<wasm.Uint8>)>>('freeMemory')
      .asFunction<void Function(wasm.Pointer<wasm.Uint8>)>();

  late final int Function(
    wasm.Pointer<wasm.Uint8>,
    wasm.Pointer<wasm.Uint8>,
    wasm.Pointer<wasm.Uint8>,
    wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
    int,
  ) _decryptAes256CbcWasm;

  late final int Function(
    wasm.Pointer<wasm.Uint8>,
    wasm.Pointer<wasm.Uint8>,
    wasm.Pointer<wasm.Uint8>,
    wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
  ) _encryptAes256CbcWasm;

  bool _isInit = false;

  // late final Pointer<Uint8> Function(int) _malloc;
  // late final void Function(Pointer<Uint8>) _free;

  AesCbcImplWeb._();

  factory AesCbcImplWeb() {
    return _instance ??= AesCbcImplWeb._();
  }

  Future<void> init() async {
    if (_isInit) {
      log('WASM library already initialized', name: 'Wasm');
      return;
    }

    try {
      _lib = await wasm.DynamicLibrary.open('assets/wasm/aes_module.wasm');

      someFunc = createSomeFunc(_lib);

      _decryptAes256CbcWasm = _lib
          .lookup<
              wasm.NativeFunction<
                  int Function(
                    wasm.Pointer<wasm.Uint8>,
                    wasm.Pointer<wasm.Uint8>,
                    wasm.Pointer<wasm.Uint8>,
                    wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
                    int,
                  )>>('decryptAes256Cbc')
          .asFunction<
              int Function(
                wasm.Pointer<wasm.Uint8>,
                wasm.Pointer<wasm.Uint8>,
                wasm.Pointer<wasm.Uint8>,
                wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
                int,
              )>();

      _encryptAes256CbcWasm = _lib
          .lookup<
              wasm.NativeFunction<
                  int Function(
                    wasm.Pointer<wasm.Uint8>,
                    wasm.Pointer<wasm.Uint8>,
                    wasm.Pointer<wasm.Uint8>,
                    wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
                  )>>('decryptAes256Cbc')
          .asFunction<
              int Function(
                wasm.Pointer<wasm.Uint8>,
                wasm.Pointer<wasm.Uint8>,
                wasm.Pointer<wasm.Uint8>,
                wasm.Pointer<wasm.Pointer<wasm.Uint8>>,
              )>();

      log('WASM library loaded successfully', name: 'Wasm');
      _isInit = true;
    } catch (e) {
      log('Failed to load WASM library: $e', name: 'Wasm');
      rethrow;
    }
  }

  double Function(double) createSomeFunc(wasm.DynamicLibrary lib) {
    return lib
        .lookup<wasm.NativeFunction<double Function(double)>>('someFunction')
        .asFunction<double Function(double)>();
  }

  @override
  double someFunction(double params) => someFunc(params);

  @override
  Uint8List decryptAes256Cbc({
    required Uint8List ciphertext,
    required Uint8List key,
    required Uint8List iv,
  }) {
    return wasm_utils.using(
      (arena) {
        // 1. Копируем входные данные в память WASM
        final ptrCipher = arena.allocate<wasm.Uint8>(ciphertext.length);

        log(
          'cipher.ptr = ${ptrCipher.address}, len = ${ciphertext.length}',
          name: 'Wasm',
        );

        ptrCipher.asTypedList(ciphertext.length).setAll(0, ciphertext);

        final ptrKey = arena.allocate<wasm.Uint8>(key.length);
        ptrKey.asTypedList(key.length).setAll(0, key);

        final ptrIv = arena.allocate<wasm.Uint8>(iv.length);
        ptrIv.asTypedList(iv.length).setAll(0, iv);

        // 2. Выделяем указатель на выходной буфер: unsigned char** result
        final ptrResultPtr = arena.allocate<wasm.Pointer<wasm.Uint8>>(1);

        // 3. Вызов C-функции: int decryptAes256Cbc(..., resultPtr)
        final resultLen = _decryptAes256CbcWasm(
          ptrCipher,
          ptrKey,
          ptrIv,
          ptrResultPtr,
          ciphertext.length,
        );

        // 4. Получаем реальный указатель на буфер из resultPtr
        final resultPtr = ptrResultPtr.value;

        // 5. Создаём копию результата и освобождаем память
        final result = resultPtr.asTypedList(resultLen);
        _freeMemoryWasm(resultPtr); // 🔥 Освобождение на стороне WASM

        // log(
        //   'resultString: ${utf8.decode(result)}',
        //   name: 'Wasm',
        // );

        return Uint8List.fromList(result); // копия, безопасная в Dart
      },
      _lib.allocator,
    );
  }

  @override
  Uint8List encryptAes256Cbc({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List iv,
  }) {
    return wasm_utils.using(
      (arena) {
        // 1. Копируем входные данные в память WASM
        final ptrPlaintext = arena.allocate<wasm.Uint8>(plaintext.length);
        ptrPlaintext.asTypedList(plaintext.length).setAll(0, plaintext);

        final ptrKey = arena.allocate<wasm.Uint8>(key.length);
        ptrKey.asTypedList(key.length).setAll(0, key);

        final ptrIv = arena.allocate<wasm.Uint8>(iv.length);
        ptrIv.asTypedList(iv.length).setAll(0, iv);

        // 2. Выделяем указатель на выходной буфер: unsigned char** result
        final ptrResultPtr = arena.allocate<wasm.Pointer<wasm.Uint8>>(1);

        // 3. Вызов C-функции: int encryptAes256Cbc(..., resultPtr)
        final resultLen = _encryptAes256CbcWasm(
          ptrPlaintext,
          ptrKey,
          ptrIv,
          ptrResultPtr,
        );

        // 4. Получаем реальный указатель на буфер из resultPtr
        final resultPtr = ptrResultPtr.value;

        // 5. Создаём копию результата и освобождаем память
        final result = resultPtr.asTypedList(resultLen);
        _freeMemoryWasm(resultPtr); // 🔥 Освобождение на стороне WASM

        return Uint8List.fromList(result); // копия, безопасная в Dart
      },
      _lib.allocator,
    );
  }
}

final class AesCbcImplMobile implements AesCbcRepo {
  @override
  double someFunction(double params) {
    return params * 4;
  }

  @override
  Uint8List decryptAes256Cbc({
    required Uint8List ciphertext,
    required Uint8List key,
    required Uint8List iv,
  }) {
    throw UnimplementedError();
  }

  @override
  Uint8List encryptAes256Cbc({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List iv,
  }) {
    throw UnimplementedError();
  }
}
