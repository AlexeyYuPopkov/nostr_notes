import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:nostr_notes/auth/domain/usecase/get_pending_usecase.dart';
import 'package:rxdart/rxdart.dart';

final class PendingVm extends ValueNotifier<Set<String>> {
  static const debounceTime = Duration(milliseconds: 500);
  final GetPendingUsecase _getPendingUsecase;
  StreamSubscription? _subscription;

  PendingVm({required GetPendingUsecase getPendingUsecase})
    : _getPendingUsecase = getPendingUsecase,
      super({});

  bool isPending(String eventId) => value.contains(eventId);

  void subscribe() {
    _subscription?.cancel();
    _subscription = _getPendingUsecase
        .execute()
        .doOnData(
          (value) =>
              log('PendingVm (doOnData) new value: $value', name: 'PendingVm'),
        )
        .debounceTime(debounceTime)
        .listen((pending) {
          log('PendingVm (listen) new value: $value', name: 'PendingVm');
          value = pending;
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
