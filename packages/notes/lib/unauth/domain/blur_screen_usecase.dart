// import 'dart:async';

// import 'package:flutter/foundation.dart' show debugPrint;
// import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
// import 'package:nostr_notes/core/tools/now.dart';
// import 'package:rxdart/rxdart.dart';

// final class BlurScreenUsecase {
//   static const _noblurDuration = Duration(seconds: 10);
//   static const validDuration = Duration(seconds: 180);

//   final AuthUsecase _authUsecase;
//   late final BehaviorSubject<BlurScreenState> _stateSubject =
//       BehaviorSubject.seeded(BlurScreenState.unlocked);
//   final Now _now;
//   DateTime? _backgroundEnterTime;

//   bool _suppressNextBlur = false;
//   bool _isDisposed = false;

//   BlurScreenUsecase({required AuthUsecase authUsecase, Now now = const Now()})
//     : _authUsecase = authUsecase,
//       _now = now;

//   /// Call before triggering an action that causes the app to briefly go to
//   /// background (e.g. showing a fullscreen ad). The next blur is skipped and
//   /// the screen stays unlocked.
//   void suppressNextBackground() {
//     _suppressNextBlur = true;
//   }

//   Stream<BlurScreenState> get stateStream =>
//       _stateSubject.stream.distinct().switchMap(_mapState);

//   Stream<BlurScreenState> _mapState(BlurScreenState e) {
//     if (e == BlurScreenState.blured) {
//       if (_suppressNextBlur) {
//         _suppressNextBlur = false;
//         return Stream.value(BlurScreenState.unlocked);
//       }
//       // switchMap cancels this future when onForeground() emits unlocked —
//       // so if the user returns in <_noblurDuration, blur is never shown.
//       return Stream.fromFuture(
//         Future.delayed(_noblurDuration, () => e),
//       );
//     }
//     return Stream.value(e);
//   }

//   BlurScreenState get currentState => _stateSubject.value;

//   Future<void> onForeground() async {
//     final isValid =
//         _backgroundEnterTime != null &&
//         _now.now().difference(_backgroundEnterTime!) < validDuration;

//     if (!isValid) {
//       _stateSubject.add(BlurScreenState.locked);
//       await _authUsecase.restore();
//     } else {
//       _stateSubject.add(BlurScreenState.unlocked);
//     }
//   }

//   void onBackground() {
//     debugPrint('onBackground called at ${_now.now()}');
//     debugPrint('Current state: ${_stateSubject.value}');

//     if (_stateSubject.value != BlurScreenState.unlocked) {
//       debugPrint('State is not unlocked, skipping');
//       return;
//     }

//     _backgroundEnterTime = _now.now();
//     debugPrint('Setting state to blured');
//     _stateSubject.add(BlurScreenState.blured);
//   }

//   Future<void> dispose() async {
//     if (_isDisposed) return;
//     _isDisposed = true;
//     await _stateSubject.close();
//   }
// }

// enum BlurScreenState { blured, locked, unlocked }
