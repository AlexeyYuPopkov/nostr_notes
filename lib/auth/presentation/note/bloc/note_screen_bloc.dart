import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_note_usecase.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note/bloc/note_screen_state.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';
import 'package:rxdart/rxdart.dart';

import 'note_screen_data.dart';
import 'note_screen_event.dart';

final class NoteScreenBloc extends Bloc<NoteScreenEvent, NoteScreenState> {
  final PathParams? pathParams;
  NoteScreenData get data => state.data;
  late final GetNoteUsecase _getNoteUsecase = DiStorage.shared.resolve();
  late final CreateNoteUsecase _createNoteUsecase = DiStorage.shared.resolve();

  NoteScreenBloc({required this.pathParams})
      : super(
          NoteScreenState.common(
            data: NoteScreenData.initial(),
          ),
        ) {
    _setupHandlers();

    add(const NoteScreenEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);

    on<DidChangeTextEvent>(
      _onDidChangeTextEvent,
      transformer: (events, mapper) =>
          events.debounceTime(Durations.short3).switchMap(mapper),
    );
    on<SaveNoteEvent>(_onSaveNoteEvent);
    on<ChangeEditModeEvent>(_onChangeEditModeEvent);
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<NoteScreenState> emit,
  ) async {
    final noteId = pathParams?.id;
    if (noteId == null || noteId.isEmpty) {
      return;
    }
    try {
      emit(NoteScreenState.initialLoading(data: data));

      final note = await _getNoteUsecase.execute(noteId);

      emit(
        NoteScreenState.common(
          data: data.copyWith(
            initialNote: OptionalBox(note),
            text: note?.content ?? '',
          ),
        ),
      );
    } catch (e) {
      emit(NoteScreenState.error(e: e, data: data));
    }
  }

  void _onDidChangeTextEvent(
    DidChangeTextEvent event,
    Emitter<NoteScreenState> emit,
  ) {
    final newData = data.copyWith(text: event.text);
    emit(NoteScreenState.common(data: newData));
  }

  void _onSaveNoteEvent(
    SaveNoteEvent event,
    Emitter<NoteScreenState> emit,
  ) async {
    try {
      final trimmedText = data.text.trim();

      if (trimmedText.isEmpty) {
        final message = ErrorMessagesProvider
            .defaultProvider.noteScreenNoteContentCannotBeEmpty;
        throw AppError.common(message: message);
      }

      emit(NoteScreenState.initialLoading(data: data));

      final result = await _createNoteUsecase.execute(
        content: trimmedText,
        dTag: data.initialNote.value?.dTag,
      );

      final targetNote = result.targetNote;

      if (targetNote is Note) {
        final newData = data.copyWith(text: data.text);
        emit(
          NoteScreenState.didSave(
            data: newData.copyWith(
              initialNote: OptionalBox(targetNote),
              editMode: false,
            ),
          ),
        );

        add(const InitialEvent());
      } else {
        throw const AppError.undefined();
      }
    } catch (e) {
      emit(
        NoteScreenState.error(
          e: e,
          data: data.copyWith(
            editMode: false,
          ),
        ),
      );
    }
  }

  void _onChangeEditModeEvent(
    ChangeEditModeEvent event,
    Emitter<NoteScreenState> emit,
  ) {
    emit(
      NoteScreenState.common(
        data: data.copyWith(editMode: event.editMode),
      ),
    );
  }
}
