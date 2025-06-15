import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/create_note_usecase.dart';
import 'package:nostr_notes/auth/note/bloc/note_screen_state.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'note_screen_data.dart';
import 'note_screen_event.dart';

final class NoteScreenBloc extends Bloc<NoteScreenEvent, NoteScreenState> {
  NoteScreenData get data => state.data;
  late final CreateNoteUsecase _createNoteUsecase = DiStorage.shared.resolve();

  NoteScreenBloc()
      : super(
          NoteScreenState.common(
            data: NoteScreenData.initial(initialText: ''),
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
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<NoteScreenState> emit,
  ) async {
    try {
      emit(NoteScreenState.loading(data: data));

      await Future.delayed(const Duration(seconds: 2));

      emit(
        NoteScreenState.common(data: data),
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

      emit(NoteScreenState.loading(data: data));

      await _createNoteUsecase.execute(
        content: data.text,
      );

      final newData = data.copyWith(text: data.text);
      emit(NoteScreenState.common(data: newData));
    } catch (e) {
      emit(NoteScreenState.error(e: e, data: data));
    }
  }
}
