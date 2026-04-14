import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nostr_notes/common/domain/repository/biometric_repository.dart';

final class BiometricDatasourceImpl implements BiometricRepository {
  final auth = LocalAuthentication();
  bool? _canAuthenticate;

  FutureOr<bool> canAuthenticate() async {
    if (kIsWeb) {
      return true;
    }

    if (Platform.isMacOS) {
      return true;
    }

    if (_canAuthenticate != null) {
      return _canAuthenticate!;
    }

    final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();

    /// To check whether there is local authentication available on this device or
    /// not, call canCheckBiometrics (if you need biometrics support) and/or
    /// isDeviceSupported() (if you just need some device-level authentication).
    /// Source: https://pub.dev/packages/local_auth
    final result = canAuthenticateWithBiometrics || isDeviceSupported;
    _canAuthenticate = result;
    return result;
  }

  @override
  Future<bool> execute(BiometricRepositoryRequest parameters) async {
    if (kIsWeb) {
      return true;
    }
    if (Platform.isMacOS) {
      return true;
    }
    try {
      final shouldAuthenticate = await canAuthenticate();

      if (shouldAuthenticate) {
        return auth.authenticate(
          localizedReason: parameters.localizedReason,
          biometricOnly: true,
        );
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
