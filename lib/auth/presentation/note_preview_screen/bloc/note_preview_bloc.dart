import 'dart:async';

import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final GetNoteUsecase _getNoteUsecase = DiStorage.shared.resolve();
  StreamSubscription? _subscription;

  NotePreviewBloc({required this.pathParams})
    : super(NotePreviewState.loading(data: NotePreviewData.initial())) {
    _setupHandlers();

    add(const NotePreviewEvent.initial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _subscription = null;
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
  }

  void _setupSubscriptions() {
    _subscription?.cancel();
    _subscription = null;
    _subscription = _getNoteUsecase.watch(pathParams.id).listen((note) {
      add(NotePreviewEvent.noteUpdated(note));
    }, onError: (e) => add(NotePreviewEvent.error(error: e)));
  }

  void _onInitialEvent(InitialEvent event, Emitter<NotePreviewState> emit) {
    _setupSubscriptions();
  }

  void _onErrorEvent(ErrorEvent event, Emitter<NotePreviewState> emit) {
    emit(NotePreviewState.error(data: data, error: event.error));
  }

  void _onNoteUpdatedEvent(
    NoteUpdatedEvent event,
    Emitter<NotePreviewState> emit,
  ) {
    final note = event.note;
    emit(NotePreviewState.common(data: data.copyWith(note: OptionalBox(note))));
  }
}
