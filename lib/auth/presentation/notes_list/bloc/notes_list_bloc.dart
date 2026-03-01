import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_pending_usecase.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/pending_vm.dart';

import 'notes_list_data.dart';
import 'notes_list_event.dart';
import 'notes_list_state.dart';

final class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  NotesListData get data => state.data;

  late final FetchNotesUsecase _fetchNotesUsecase = DiStorage.shared.resolve();
  late final GetNotesUsecase _getNotesUsecase = DiStorage.shared.resolve();
  late final pendingVm = PendingVm(
    getPendingUsecase: DiStorage.shared.resolve<GetPendingUsecase>(),
  );

  StreamSubscription? _fetchNotesSubscription;
  StreamSubscription? _getNotesSubscription;
  StreamSubscription? _errorSubscription;
  NotesListBloc()
    : super(NotesListState.common(data: NotesListData.initial())) {
    _setupHandlers();

    add(const NotesListEvent.initial());
  }

  @override
  Future<void> close() {
    _fetchNotesSubscription?.cancel();
    _fetchNotesSubscription = null;
    _getNotesSubscription?.cancel();
    _getNotesSubscription = null;
    _errorSubscription?.cancel();
    _errorSubscription = null;
    pendingVm.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<GetNotesEvent>(_onGetNotesEvent);
    on<ErrorEvent>(_onErrorEvent);
  }

  void _setupSubscription() {
    _fetchNotesSubscription?.cancel();
    _fetchNotesSubscription = null;
    _fetchNotesSubscription = _fetchNotesUsecase.execute().listen(
      (_) {},
      onError: (error) {
        add(NotesListEvent.error(error: error));
      },
    );

    _getNotesSubscription?.cancel();
    _getNotesSubscription = null;
    _getNotesSubscription = _getNotesUsecase.execute().listen(
      (items) {
        add(NotesListEvent.getNotes(notes: items));
      },
      onError: (error) {
        add(NotesListEvent.error(error: error));
      },
    );

    _errorSubscription?.cancel();
    _errorSubscription = null;
    _errorSubscription = _fetchNotesUsecase.relayErrors.listen((error) {
      add(NotesListEvent.error(error: error));
    });

    pendingVm.subscribe();
  }

  void _onInitialEvent(InitialEvent event, Emitter<NotesListState> emit) async {
    emit(NotesListState.loading(data: data));

    _setupSubscription();

    emit(NotesListState.common(data: data));
  }

  void _onGetNotesEvent(
    GetNotesEvent event,
    Emitter<NotesListState> emit,
  ) async {
    try {
      emit(NotesListState.common(data: data.copyWith(notes: event.notes)));
    } catch (e) {
      emit(NotesListState.error(e: e, data: data));
    }
  }

  void _onErrorEvent(ErrorEvent event, Emitter<NotesListState> emit) {
    emit(NotesListState.error(data: data, e: event.error));
  }
}
