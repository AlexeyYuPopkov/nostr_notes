import 'dart:async';
import 'dart:developer';

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
  bool _isVerifying = false;
  bool _reauthRequired = false;

  void setDeniedAtIfNeeded() {
    _deniedAt ??= DateTime.now();
  }

  void resetDenyTime() => _deniedAt = null;

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
        // Ignore the inactive/active blips the biometric prompt itself causes.
        .where((_) => !_isVerifying)
        .distinct()
        .switchMap(
          (isActive) => _skipNextVerification
              ? Stream.value(isActive)
              : TimerStream(isActive, debounceGuard),
        )
        .asyncExpand(
          (isActive) =>
              _evaluate(isActive: isActive, biometryRequest: biometryRequest),
        )
        .doOnData((e) {
          log(
            'Result verification status ${e.toString()}',
            name: 'VerificationUsecase',
          );
        })
        .distinct();
  }

  Stream<Verification> _evaluate({
    required bool isActive,
    required BiometricRepositoryRequest biometryRequest,
  }) async* {
    _isActive = isActive;

    // In the locked/unauthorized zone the dedicated lock screen governs — never
    // blur, and clear any pending re-auth (the user re-enters via PIN).
    if (!_authUsecase.currentSession.isUnlocked) {
      _reauthRequired = false;
      resetDenyTime();
      yield const Verification.allow();
      return;
    }

    if (!isActive) {
      setDeniedAtIfNeeded();
      // Controlled background (e.g. ad) — skip blur entirely.
      if (_skipNextVerification) {
        yield const Verification.allow();
        return;
      }
      yield const Verification.deny();
      return;
    }

    final skip = _skipNextVerification;
    _skipNextVerification = false;

    final denyTime = _deniedAt;
    final needsReauth =
        _reauthRequired ||
        (denyTime != null && _isOutdated(denyTime: denyTime));

    if (skip || !needsReauth) {
      // Returned within the grace window (or controlled background) — allow.
      resetDenyTime();
      yield const Verification.allow();
      return;
    }

    // Biometry is required and stays latched until it actually succeeds, so a
    // quick background/return cannot slip past it via the grace window.
    _reauthRequired = true;
    yield const Verification.processing();
    final status = await _passBiometry(biometricRequest: biometryRequest);

    // While the prompt was up, lifecycle blips were filtered, so re-check state.
    if (!_authUsecase.currentSession.isUnlocked) {
      // Biometry failed → session re-locked → lock screen governs, no blur.
      yield const Verification.allow();
    } else if (status == const Verification.allow() && _isActive) {
      yield const Verification.allow();
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
    _isVerifying = true;
    try {
      final isAuthorized = await biometricRepository.execute(biometricRequest);

      if (isAuthorized) {
        _reauthRequired = false;
        resetDenyTime();
        return const Verification.allow();
      }
      // Failed/cancelled — re-lock the session. Keep the re-auth latch and
      // denyTime so a subsequent quick background/return still requires auth.
      await _authUsecase.restore();
      return const Verification.deny();
    } catch (e) {
      await _authUsecase.restore();
      return const Verification.deny();
    } finally {
      _isVerifying = false;
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
