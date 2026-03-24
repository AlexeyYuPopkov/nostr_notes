import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_acc_usecase.dart';
import 'package:rxdart/rxdart.dart';

import 'del_acc_data.dart';
import 'del_acc_event.dart';
import 'del_acc_state.dart';

final class DelAccBloc extends Bloc<DelAccEvent, DelAccState> {
  DelAccData get data => state.data;
  late final _deleteAccUsecase = DeleteAccUsecase(
    sessionUsecase: DiStorage.shared.resolve(),
    notesRepository: DiStorage.shared.resolve(),
    relaysListRepo: DiStorage.shared.resolve(),
    authUsecase: DiStorage.shared.resolve(),
  );
  StreamSubscription? _deleteAccSub;

  DelAccBloc() : super(DelAccState.common(data: DelAccData.initial())) {
    _setupHandlers();
  }

  @override
  Future<void> close() {
    _deleteAccSub?.cancel();
    return super.close();
  }

  void _setupHandlers() {
    on<DelEvent>(_onDelEvent);
    on<DidUpdateStatusEvent>(
      _onDidUpdateStatusEvent,
      transformer: (events, mapper) =>
          events.debounceTime(Durations.short1).switchMap(mapper),
    );
  }

  void _onDelEvent(DelEvent event, Emitter<DelAccState> emit) async {
    emit(DelAccState.common(data: data.copyWith(status: .preparing)));
    try {
      _deleteAccSub?.cancel();
      _deleteAccSub = _deleteAccUsecase.execute(Durations.extralong3).listen((
        event,
      ) {
        add(DelAccEvent.didUpdateStatus(event));
      });
    } catch (e) {
      emit(DelAccState.error(e: e, data: data));
    }
  }

  void _onDidUpdateStatusEvent(
    DidUpdateStatusEvent event,
    Emitter<DelAccState> emit,
  ) {
    if (event.status == .logout) {
      emit(DelAccState.common(data: data.copyWith(status: event.status)));
      return;
    }
    emit(DelAccState.executing(data: data.copyWith(status: event.status)));
  }
}
