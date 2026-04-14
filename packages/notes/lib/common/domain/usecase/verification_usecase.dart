import 'dart:async';

import 'package:nostr_notes/common/domain/repository/app_lifecycle_listener_repository.dart';
import 'package:nostr_notes/common/domain/repository/biometric_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/core/tools/disposable.dart';
import 'package:rxdart/rxdart.dart';

final class VerificationUsecase implements Disposable {
  static const defaultMaxInactiveDuration = Duration(seconds: 5);
  final Duration maxInactiveDuration;
  final BiometricRepository biometricRepository;
  final AppLifecycleListenerRepository appLifecycleListenerRepository;
  final AuthUsecase _authUsecase;

  late final _userInitiated = PublishSubject<Verification>();

  DateTime? _deniedAt;

  void setDeniedAtIfNeeded() {
    _deniedAt ??= DateTime.now();
  }

  void resetDenyTime() => _deniedAt = null;

  VerificationUsecase({
    required this.biometricRepository,
    required this.appLifecycleListenerRepository,
    required AuthUsecase authUsecase,
    this.maxInactiveDuration = defaultMaxInactiveDuration,
  }) : _authUsecase = authUsecase;

  Stream<Verification> createStream({
    required BiometricRepositoryRequest biometryRequest,
  }) {
    return Rx.merge([
      appLifecycleListenerRepository.isActiveStream
          .distinct()
          .map((isActive) {
            final isUnlocked = _authUsecase.currentSession.isUnlocked;

            if (isUnlocked) {
              return isActive
                  ? const Verification.allow()
                  : const Verification.deny();
            } else {
              return const Verification.allow();
            }
          })
          .distinct((a, b) => a.runtimeType == b.runtimeType),
      _userInitiated,
    ]).asyncMap((e) async {
      if (e is Deny) {
        setDeniedAtIfNeeded();
      }

      return await _performAuthorizationIfNeeded(
        currentStatus: e,
        biometryRequest: biometryRequest,
      );
    });
  }

  Future<Verification> _performAuthorizationIfNeeded({
    required Verification currentStatus,
    required BiometricRepositoryRequest biometryRequest,
  }) async {
    final denyTime = _deniedAt;

    if (currentStatus is Allow && denyTime != null) {
      if (await _isOutdated(denyTime: denyTime)) {
        _passBiometry(biometricRequest: biometryRequest);
        return const Verification.processing();
      } else {
        return currentStatus;
      }
    } else {
      return currentStatus;
    }
  }

  FutureOr<bool> _isOutdated({required DateTime denyTime}) async {
    return denyTime.add(maxInactiveDuration).isBefore(DateTime.now());
  }

  void _passBiometry({
    required BiometricRepositoryRequest biometricRequest,
  }) async {
    try {
      final isAuthorized = await biometricRepository.execute(biometricRequest);

      if (isAuthorized) {
        _userInitiated.sink.add(const Verification.allow());
      } else {
        _userInitiated.sink.add(const Verification.deny());
        await _authUsecase.restore();
      }
    } catch (e) {
      await _authUsecase.restore();
      _userInitiated.sink.add(const Verification.allow());
    } finally {
      resetDenyTime();
    }
  }

  @override
  Future<void> dispose() async {
    appLifecycleListenerRepository.dispose();
    _userInitiated.close();
  }
}

// Verification
sealed class Verification {
  const Verification();

  const factory Verification.allow() = Allow;

  const factory Verification.deny() = Deny;

  const factory Verification.processing() = Processing;
}

final class Allow extends Verification {
  const Allow();
}

final class Deny extends Verification {
  const Deny();
}

final class Processing extends Verification {
  const Processing();
}
