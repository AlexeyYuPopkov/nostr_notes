import 'dart:async';

abstract interface class BiometricRepository {
  Future<bool> execute(BiometricRepositoryRequest parameters);
}

final class BiometricRepositoryRequest {
  final String localizedReason;

  const BiometricRepositoryRequest({required this.localizedReason});
}
