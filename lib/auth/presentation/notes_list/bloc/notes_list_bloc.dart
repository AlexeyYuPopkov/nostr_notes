import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_notes_usecase.dart';

import 'notes_list_data.dart';
import 'notes_list_event.dart';
import 'notes_list_state.dart';

final class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  NotesListData get data => state.data;

  late final FetchNotesUsecase _fetchNotesUsecase = DiStorage.shared.resolve();
  late final GetNotesUsecase _getNotesUsecase = DiStorage.shared.resolve();
  StreamSubscription? _notesSubscription;

  NotesListBloc()
    : super(NotesListState.common(data: NotesListData.initial())) {
    _setupHandlers();

    add(const NotesListEvent.initial());
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    _notesSubscription = null;
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);

    on<GetNotesEvent>(_onGetNotesEvent);
    on<ErrorEvent>(_onErrorEvent);
  }

  void _setupSubscription() {
    _notesSubscription?.cancel();
    _notesSubscription = null;
    _notesSubscription = _fetchNotesUsecase.execute().listen(
      (items) {
        add(const NotesListEvent.getNotes());
      },
      onError: (error) {
        add(NotesListEvent.error(error: error));
      },
    );
  }

  void _onInitialEvent(InitialEvent event, Emitter<NotesListState> emit) {
    emit(NotesListState.loading(data: data));
    _setupSubscription();
  }

  void _onGetNotesEvent(
    GetNotesEvent event,
    Emitter<NotesListState> emit,
  ) async {
    try {
      final result = await _getNotesUsecase.execute();

      emit(NotesListState.common(data: data.copyWith(notes: result)));
    } catch (e) {
      emit(NotesListState.error(e: e, data: data));
    }
  }

  void _onErrorEvent(ErrorEvent event, Emitter<NotesListState> emit) {
    emit(NotesListState.error(data: data, e: event.error));
  }
}
