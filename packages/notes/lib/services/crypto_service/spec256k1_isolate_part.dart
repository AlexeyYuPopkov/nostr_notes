import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:common/tools/disposable.dart';
import 'package:ffi/ffi.dart' as ffi_ffi;
import 'package:nostr_notes/ffigen/ffigen_crypto_module.dart';
import 'package:nostr_notes/services/nip44/derive_keys.dart';

final class Spec256k1Isolate implements Disposable {
  SendPort? _sendPort;
  Isolate? _isolate;
  static StreamSubscription? _isolateSubscription;

  Future<void> init() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_entryPoint, receivePort.sendPort);
    _sendPort = await receivePort.first as SendPort;
  }

  Future<Uint8List> compute({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) async {
    if (_sendPort == null || _isolate == null) {
      await dispose();
      await init();
    }

    assert(_sendPort != null, 'Call init() first');
    final completer = Completer<Uint8List>();
    final responsePort = RawReceivePort((dynamic response) {});
    responsePort.handler = (dynamic response) {
      responsePort.close();
      completer.complete(response as Uint8List);
    };
    _sendPort!.send((
      senderPrivateKey,
      recipientPublicKey,
      responsePort.sendPort,
    ));
    return completer.future;
  }

  @override
  Future<void> dispose() async {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _isolateSubscription?.cancel();
    _isolateSubscription = null;
  }

  // static int i = 0;

  static void _entryPoint(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    NativeLibrary? nativeLib;
    try {
      final libPath = _libName();
      if (libPath != null) {
        nativeLib = NativeLibrary(ffi.DynamicLibrary.open(libPath));
        // log('NativeLibrary: ${i++}', name: 'Spec256k1Isolate');
      }
    } catch (_) {
      // FFI not available, will fall back to pure Dart
    }

    const deriveKeys = DeriveKeys();

    _isolateSubscription?.cancel();
    _isolateSubscription = null;

    _isolateSubscription = port.listen((dynamic message) {
      final (Uint8List privateKey, Uint8List publicKey, SendPort replyPort) =
          message as (Uint8List, Uint8List, SendPort);

      Uint8List result;
      if (nativeLib != null) {
        try {
          result = _spec256k1Ffi(nativeLib, privateKey, publicKey);
        } catch (_) {
          result = deriveKeys.spec256k1FromBytes(
            privateKeyBytes: privateKey,
            publicKeyBytes: publicKey,
          );
        }
      } else {
        result = deriveKeys.spec256k1FromBytes(
          privateKeyBytes: privateKey,
          publicKeyBytes: publicKey,
        );
      }
      replyPort.send(result);
    });
  }

  static String? _libName() {
    if (io.Platform.isAndroid) return 'crypto_module.so';
    if (io.Platform.isMacOS || io.Platform.isIOS) {
      return 'crypto_module.framework/crypto_module';
    }
    return null;
  }

  static Uint8List _spec256k1Ffi(
    NativeLibrary nativeLib,
    Uint8List senderPrivateKey,
    Uint8List recipientPublicKey,
  ) {
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

      final resultLen = nativeLib.deriveSharedKey(
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
}
