import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:nostr_notes/common/domain/repository/app_lifecycle_listener_repository.dart';
import 'package:nostr_notes/common/domain/repository/biometric_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/core/tools/disposable.dart';

final class VerificationUsecase implements Disposable {
  static const defaultMaxInactiveDuration = Duration(seconds: 5);
  final Duration maxInactiveDuration;
  final BiometricRepository biometricRepository;
  final AppLifecycleListenerRepository appLifecycleListenerRepository;
  final AuthUsecase _authUsecase;

  DateTime? _deniedAt;
  bool _isActive = true;

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
    return appLifecycleListenerRepository.isActiveStream.distinct().asyncExpand(
      (isActive) {
        _isActive = isActive;
        if (!isActive) {
          setDeniedAtIfNeeded();
        }

        final isLocked = !_authUsecase.currentSession.isUnlocked;

        if (isLocked) {
          return Stream.value(const Verification.allow());
        }

        return _performAuthorizationIfNeeded(
          isActive: isActive,
          biometryRequest: biometryRequest,
        ).map((value) {
          final isLocked = !_authUsecase.currentSession.isUnlocked;
          return _isActive
              ? value
              : isLocked
              ? const Verification.allow()
              : const Verification.deny();
        });
      },
    ).distinct();
  }

  Stream<Verification> _performAuthorizationIfNeeded({
    required bool isActive,
    required BiometricRepositoryRequest biometryRequest,
  }) async* {
    final denyTime = _deniedAt;

    if (isActive && denyTime != null) {
      if (_isOutdated(denyTime: denyTime)) {
        yield const Verification.processing();
        final status = await _passBiometry(biometricRequest: biometryRequest);
        yield status;
      } else {
        resetDenyTime();
        yield Verification.allow();
      }
    } else {
      yield Verification.deny();
    }
  }

  bool _isOutdated({required DateTime denyTime}) {
    return denyTime.add(maxInactiveDuration).isBefore(DateTime.now());
  }

  Future<Verification> _passBiometry({
    required BiometricRepositoryRequest biometricRequest,
  }) async {
    try {
      final isAuthorized = await biometricRepository.execute(biometricRequest);

      if (isAuthorized) {
        resetDenyTime();
        return const Verification.allow();
      } else {
        await _authUsecase.restore();
        resetDenyTime();
        return const Verification.deny();
      }
    } catch (e) {
      await _authUsecase.restore();
      return const Verification.deny();
    }
  }

  @override
  Future<void> dispose() async {
    await appLifecycleListenerRepository.dispose();
  }
}

// Verification
sealed class Verification extends Equatable {
  const Verification();

  const factory Verification.allow() = Allow;

  const factory Verification.deny() = Deny;

  const factory Verification.processing() = Processing;
}

final class Allow extends Verification {
  const Allow();

  @override
  List<Object?> get props => [];
}

final class Deny extends Verification {
  const Deny();
  @override
  List<Object?> get props => [];
}

final class Processing extends Verification {
  const Processing();
  @override
  List<Object?> get props => [];
}
