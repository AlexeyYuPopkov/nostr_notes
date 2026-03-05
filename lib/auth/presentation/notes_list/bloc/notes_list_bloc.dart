import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_pending_usecase.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/pending_vm.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:rxdart/transformers.dart';

import 'notes_list_data.dart';
import 'notes_list_event.dart';
import 'notes_list_state.dart';

final class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  static const errorStreamDebounce = Duration(milliseconds: 500);
  NotesListData get data => state.data;

  final BuildContext Function() contextProvider;

  late final FetchNotesUsecase _fetchNotesUsecase = DiStorage.shared.resolve();
  late final GetNotesUsecase _getNotesUsecase = DiStorage.shared.resolve();
  late final pendingVm = PendingVm(
    getPendingUsecase: DiStorage.shared.resolve<GetPendingUsecase>(),
  );

  StreamSubscription? _fetchNotesSubscription;
  StreamSubscription? _getNotesSubscription;
  StreamSubscription? _errorSubscription;
  NotesListBloc({required this.contextProvider})
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
    _fetchNotesSubscription = _fetchNotesUsecase.execute().listen(
      (_) {},
      onError: (error) {
        add(NotesListEvent.error(error: error));
      },
    );

    _getNotesSubscription?.cancel();
    _getNotesSubscription = _getNotesUsecase.execute().listen(
      (items) {
        add(NotesListEvent.getNotes(notes: items));
      },
      onError: (error) {
        add(NotesListEvent.error(error: error));
      },
    );

    _errorSubscription?.cancel();
    _errorSubscription = _fetchNotesUsecase.relayErrors
        .debounceTime(errorStreamDebounce)
        .listen((error) {
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
      final context = contextProvider();
      final sections = NotesListSection.groupNotesByDate(
        event.notes,
        context.l10n,
      );
      emit(NotesListState.common(data: data.copyWith(sections: sections)));
    } catch (e) {
      emit(NotesListState.error(e: e, data: data));
    }
  }

  void _onErrorEvent(ErrorEvent event, Emitter<NotesListState> emit) {
    emit(NotesListState.error(data: data, e: event.error));
  }
}
