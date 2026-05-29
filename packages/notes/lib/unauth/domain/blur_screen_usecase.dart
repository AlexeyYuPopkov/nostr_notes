import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:rxdart/subjects.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;

final class BlurScreenUsecase {
  static const validDuration = Duration(seconds: 180);
  final AuthUsecase _authUsecase;
  late final BehaviorSubject<BlurScreenState> _stateSubject =
      BehaviorSubject.seeded(BlurScreenState.unlocked);
  final Now _now;
  DateTime? _backgroundEnterTime;

  bool _isInBackground = false;

  bool _isDisposed = false;

  BlurScreenUsecase({required AuthUsecase authUsecase, Now now = const Now()})
    : _authUsecase = authUsecase,
      _now = now;

  Stream<BlurScreenState> get stateStream =>
      _stateSubject.stream.distinct().asyncMap((e) {
        switch (e) {
          case BlurScreenState.blured:
            return Future.delayed(const Duration(seconds: 1), () => e);
          case BlurScreenState.locked:
            return e;
          case BlurScreenState.unlocked:
            return e;
        }
      });

  BlurScreenState get currentState => _stateSubject.value;

  Future<void> onForeground() async {
    final isValid =
        _backgroundEnterTime != null &&
        _now.now().difference(_backgroundEnterTime!) < validDuration;

    if (!isValid) {
      _stateSubject.add(BlurScreenState.locked);
      await _authUsecase.restore();
    } else {
      _stateSubject.add(BlurScreenState.unlocked);
    }
  }

  void onBackground() {
    debugPrint('onBackground called at ${_now.now()}');
    debugPrint('Current state: ${_stateSubject.value}');

    if (_stateSubject.value != BlurScreenState.unlocked) {
      debugPrint('State is not unlocked, skipping');
      return;
    }

    _isInBackground = true;
    _backgroundEnterTime = _now.now();
    if (_isInBackground && _stateSubject.value == BlurScreenState.unlocked) {
      debugPrint('Setting state to blured');
      _stateSubject.add(BlurScreenState.blured);
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    await _stateSubject.close();
  }
}

enum BlurScreenState { blured, locked, unlocked }
