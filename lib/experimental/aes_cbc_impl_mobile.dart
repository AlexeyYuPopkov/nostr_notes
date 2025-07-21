import 'dart:typed_data';

import 'aes_cbc_repo.dart';

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

final class AesCbcImplWeb implements AesCbcRepo {
  AesCbcImplWeb();

  Future<void> init() async {}

  @override
  double someFunction(double params) =>
      throw UnimplementedError('Mobile implementation not available');

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
