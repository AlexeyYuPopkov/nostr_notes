import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:nostr_notes/common/domain/repository/app_lifecycle_listener_repository.dart';
import 'package:common/tools/disposable.dart';
import 'package:rxdart/rxdart.dart';

final class AppLifecycleListenerDatasource
    implements AppLifecycleListenerRepository, Disposable {
  final _isActiveStream = PublishSubject<bool>();

  late final AppLifecycleListener appLifecycleListener;

  AppLifecycleListenerDatasource() {
    appLifecycleListener = AppLifecycleListener(onStateChange: _onStateChanged);
  }

  void _onStateChanged(AppLifecycleState state) {
    _isActiveStream.sink.add(state.isActive);
    log(
      'App lifecycle state changed: $state, isActive: ${state.isActive}',
      name: 'AppLifecycleListenerDatasource',
    );
  }

  @override
  Stream<bool> get isActiveStream => _isActiveStream;

  @override
  Future<void> dispose() async {
    appLifecycleListener.dispose();
    await _isActiveStream.close();
  }
}

extension on AppLifecycleState {
  bool get isActive {
    switch (this) {
      case AppLifecycleState.resumed:
        return true;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return false;
    }
  }
}
