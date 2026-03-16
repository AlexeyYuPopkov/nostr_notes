import 'dart:async';

import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/nip44_exception.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_note_usecase.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_data.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_event.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_state.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';
import 'package:rxdart/rxdart.dart';

final class NotePreviewBloc extends Bloc<NotePreviewEvent, NotePreviewState> {
  static const debounceDuration = Duration(milliseconds: 200);
  final PathParams pathParams;
  NotePreviewData get data => state.data;
  late final FetchNotesUsecase _fetchNotesUsecase = DiStorage.shared.resolve();

  late final GetNoteUsecase _getNoteUsecase = DiStorage.shared.resolve();
  StreamSubscription? _getNoteSubscription;
  StreamSubscription? _fetchNoteSubscription;

  NotePreviewBloc({required this.pathParams})
    : super(NotePreviewState.loading(data: NotePreviewData.initial())) {
    _setupHandlers();

    add(const NotePreviewEvent.initial());
  }

  @override
  Future<void> close() {
    _getNoteSubscription?.cancel();
    _getNoteSubscription = null;
    _fetchNoteSubscription?.cancel();
    _fetchNoteSubscription = null;
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<ErrorEvent>(
      _onErrorEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceDuration).switchMap(mapper),
    );
    on<NoteUpdatedEvent>(
      _onNoteUpdatedEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceDuration).switchMap(mapper),
    );

    on<RefreshEvent>(
      _onRefreshEvent,
      transformer: (events, mapper) =>
          events.debounceTime(debounceDuration).switchMap(mapper),
    );
  }

  void _setupSubscriptions() {
    _fetchNoteSubscription?.cancel();
    _fetchNoteSubscription = null;

    _fetchNoteSubscription = _fetchNotesUsecase
        .execute(FetchNotesUsecaseParams.noteWithId(id: pathParams.id))
        .listen((_) {}, onError: (e) => add(NotePreviewEvent.error(error: e)));

    _getNoteSubscription?.cancel();
    _getNoteSubscription = null;
    _getNoteSubscription = _getNoteUsecase.watch(pathParams.id).listen((note) {
      add(NotePreviewEvent.noteUpdated(note));
    }, onError: (e) => add(NotePreviewEvent.error(error: e)));
  }

  void _onInitialEvent(InitialEvent event, Emitter<NotePreviewState> emit) {
    _setupSubscriptions();
  }

  void _onErrorEvent(ErrorEvent event, Emitter<NotePreviewState> emit) {
    final error = event.error;

    if (error is Nip44Exception) {
      emit(NotePreviewState.cannotDecrypt(data: data));
    } else {
      emit(NotePreviewState.error(data: data, error: event.error));
    }
  }

  void _onNoteUpdatedEvent(
    NoteUpdatedEvent event,
    Emitter<NotePreviewState> emit,
  ) {
    final note = event.note;
    emit(NotePreviewState.common(data: data.copyWith(note: OptionalBox(note))));
  }

  void _onRefreshEvent(RefreshEvent event, Emitter<NotePreviewState> emit) {
    _setupSubscriptions();
  }
}
