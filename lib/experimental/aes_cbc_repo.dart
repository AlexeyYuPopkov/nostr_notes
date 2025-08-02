import 'dart:async';
import 'package:flutter/foundation.dart';
import 'aes_cbc_impl_mobile.dart'
    if (dart.library.js_interop) 'aes_cbc_impl_web.dart';

abstract interface class AesCbcRepo {
  double someFunction(double params);

  Uint8List encryptAes256Cbc({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List iv,
  });

  Uint8List decryptAes256Cbc({
    required Uint8List ciphertext,
    required Uint8List key,
    required Uint8List iv,
  });

  FutureOr<void> init();

  factory AesCbcRepo.create() {
    if (kIsWeb) {
      return AesCbcImplWeb();
    } else {
      return AesCbcImplMobile();
    }
  }
}
