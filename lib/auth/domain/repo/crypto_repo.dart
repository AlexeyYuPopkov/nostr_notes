import 'dart:async';

import 'crypto_algorithm_type.dart';

abstract interface class CryptoRepo {
  FutureOr<String> encryptMessage({
    required String text,
    required CryptoAlgorithmType algorithmType,
  });

  FutureOr<String> decryptMessage({
    required String text,
    required CryptoAlgorithmType algorithmType,
  });

  FutureOr<CryptoAlgorithmType> createCache({
    required CryptoAlgorithmType algorithmType,
  });
}
