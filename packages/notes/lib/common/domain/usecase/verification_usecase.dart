import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:nostr_notes/common/domain/repository/app_lifecycle_listener_repository.dart';
import 'package:nostr_notes/common/domain/repository/biometric_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:common/tools/disposable.dart';
import 'package:rxdart/rxdart.dart';

final class VerificationUsecase implements Disposable {
  static const defaultDebounceGuard = Duration(milliseconds: 200);
  static const defaultMaxInactiveDuration = Duration(seconds: 35);
  final Duration debounceGuard;
  final Duration maxInactiveDuration;
  final BiometricRepository biometricRepository;
  final AppLifecycleListenerRepository appLifecycleListenerRepository;
  final AuthUsecase _authUsecase;

  DateTime? _deniedAt;
  bool _isActive = true;
  bool _skipNextVerification = false;

  void setDeniedAtIfNeeded() {
    _deniedAt ??= DateTime.now();
  }

  void resetDenyTime() => _deniedAt = null;

  /// Call before triggering a controlled background (e.g. fullscreen ad).
  /// The next biometry check will be skipped and the user will be allowed back
  /// without being sent to the PIN screen.
  void skipNextVerification() {
    _skipNextVerification = true;
  }

  VerificationUsecase({
    required this.biometricRepository,
    required this.appLifecycleListenerRepository,
    required AuthUsecase authUsecase,
    this.maxInactiveDuration = defaultMaxInactiveDuration,
    this.debounceGuard = defaultDebounceGuard,
  }) : _authUsecase = authUsecase;

  Stream<Verification> createStream({
    required BiometricRepositoryRequest biometryRequest,
  }) {
    return appLifecycleListenerRepository.isActiveStream
        .distinct()
        .switchMap(
          (isActive) => _skipNextVerification
              ? Stream.value(isActive)
              : TimerStream(isActive, debounceGuard),
        )
        .asyncExpand((isActive) {
          _isActive = isActive;
          if (!isActive) {
            setDeniedAtIfNeeded();
            // Controlled background (e.g. ad) — skip blur entirely.
            // Return directly to bypass the .map(_isActive check) below.
            if (_skipNextVerification) {
              return Stream.value(const Verification.allow());
            }
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
            // In unauthorized zone blur must never be shown.
            if (isLocked) {
              return const Verification.allow();
            }
            // Preserve explicit Deny from biometry failure — the lock overlay
            // must stay visible while the session is still authorized.
            if (value == const Verification.deny()) {
              return const Verification.deny();
            }
            return _isActive ? value : const Verification.deny();
          });
        })
        .distinct();
  }

  Stream<Verification> _performAuthorizationIfNeeded({
    required bool isActive,
    required BiometricRepositoryRequest biometryRequest,
  }) async* {
    final denyTime = _deniedAt;

    if (isActive && denyTime != null) {
      final skip = _skipNextVerification;
      _skipNextVerification = false;
      if (skip || !_isOutdated(denyTime: denyTime)) {
        resetDenyTime();
        yield const Verification.allow();
      } else {
        yield const Verification.processing();
        final status = await _passBiometry(biometricRequest: biometryRequest);
        yield status;
      }
    } else {
      yield const Verification.deny();
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
  Future<void> dispose() async {}
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
