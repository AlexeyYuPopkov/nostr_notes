import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:rxdart/subjects.dart';
import 'dart:async';

final class BlurScreenUsecase {
  static const validDuration = Duration(seconds: 180);
  static const blurDelay = Duration(seconds: 15);
  final AuthUsecase _authUsecase;
  late final BehaviorSubject<BlurScreenState> _stateSubject =
      BehaviorSubject.seeded(BlurScreenState.unlocked);
  final Now _now;
  DateTime? _validTill;

  bool _isInBackground = false;
  Timer? _blurTimer;

  BlurScreenUsecase({required AuthUsecase authUsecase, Now now = const Now()})
    : _authUsecase = authUsecase,
      _now = now;

  Stream<BlurScreenState> get stateStream => _stateSubject.stream.distinct();
  BlurScreenState get currentState => _stateSubject.value;

  Future<void> onForeground() async {
    _isInBackground = false;
    _blurTimer?.cancel();
    _blurTimer = null;

    if (_validTill == null || _now.now().isAfter(_validTill!)) {
      _stateSubject.add(BlurScreenState.locked);
      await _authUsecase.restore();
    } else {
      _stateSubject.add(BlurScreenState.unlocked);
    }
  }

  void onBackground() {
    if (_stateSubject.value != BlurScreenState.unlocked) {
      return;
    }
    _isInBackground = true;
    _validTill = _now.now().add(validDuration);
    _blurTimer?.cancel();
    _blurTimer = Timer(blurDelay, () {
      if (_isInBackground &&
          !_stateSubject.isClosed &&
          _stateSubject.value != BlurScreenState.locked) {
        _stateSubject.add(BlurScreenState.blured);
      }
    });
  }

  Future<void> dispose() async {
    _blurTimer?.cancel();
    _blurTimer = null;
    await _stateSubject.close();
  }
}

enum BlurScreenState { blured, locked, unlocked }
