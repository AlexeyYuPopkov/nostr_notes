import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:rxdart/subjects.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
// import 'package:rxdart/transformers.dart';

// final class BlurScreenUsecase {
//   static const validDuration = Duration(seconds: 180);
//   static const blurDelay = Duration(seconds: 1);
//   final AuthUsecase _authUsecase;
//   late final BehaviorSubject<BlurScreenState> _stateSubject =
//       BehaviorSubject.seeded(BlurScreenState.unlocked);
//   final Now _now;
//   DateTime? _validTill;
//   DateTime? _backgroundEnterTime;

//   bool _isInBackground = false;
//   Timer? _blurTimer;
//   bool _isDisposed = false;

//   BlurScreenUsecase({required AuthUsecase authUsecase, Now now = const Now()})
//     : _authUsecase = authUsecase,
//       _now = now;

//   Stream<BlurScreenState> get stateStream => _stateSubject.stream.distinct();
//   BlurScreenState get currentState => _stateSubject.value;

//   Future<void> onForeground() async {
//     if (_isDisposed) {
//       return;
//     }

//     _isInBackground = false;
//     _cancelTimer();

//     // Проверяем валидность
//     final now = _now.now();
//     final isValid = _validTill != null && !now.isAfter(_validTill!);

//     if (!isValid) {
//       _stateSubject.add(BlurScreenState.locked);
//       await _authUsecase.restore();
//     } else {
//       _stateSubject.add(BlurScreenState.unlocked);
//     }

//     // Сбрасываем _validTill для следующего цикла
//     if (!isValid) {
//       _validTill = null;
//     }
//   }

//   void onBackground() {
//     debugPrint('onBackground called at ${_now.now()}');
//     debugPrint('Current state: ${_stateSubject.value}');

//     if (_isDisposed) {
//       return;
//     }

//     // Не запускаем таймер, если уже заблокировано
//     if (_stateSubject.value != BlurScreenState.unlocked) {
//       debugPrint('State is not unlocked, skipping');
//       return;
//     }

//     _isInBackground = true;
//     _backgroundEnterTime = _now.now();
//     _validTill = _now.now().add(validDuration);
//     debugPrint('Valid till: $_validTill');

//     _cancelTimer();

//     // Используем WidgetsBinding для более надежной работы на всех платформах
//     _blurTimer = Timer(blurDelay, () {
//       debugPrint('Timer fired at ${_now.now()}');
//       debugPrint('isInBackground: $_isInBackground, isDisposed: $_isDisposed');

//       // Проверяем актуальность состояния
//       if (_isDisposed) {
//         return;
//       }

//       if (_isInBackground && _stateSubject.value == BlurScreenState.unlocked) {
//         debugPrint('Setting state to blured');
//         _stateSubject.add(BlurScreenState.blured);
//       }
//     });
//   }

//   void _cancelTimer() {
//     _blurTimer?.cancel();
//     _blurTimer = null;
//   }

//   Future<void> dispose() async {
//     _isDisposed = true;
//     _cancelTimer();
//     await _stateSubject.close();
//   }
// }

final class BlurScreenUsecase {
  static const validDuration = Duration(seconds: 180);
  final AuthUsecase _authUsecase;
  late final BehaviorSubject<BlurScreenState> _stateSubject =
      BehaviorSubject.seeded(BlurScreenState.unlocked);
  final Now _now;
  DateTime? _backgroundEnterTime;

  bool _isInBackground = false;
  // Timer? _blurTimer;
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
