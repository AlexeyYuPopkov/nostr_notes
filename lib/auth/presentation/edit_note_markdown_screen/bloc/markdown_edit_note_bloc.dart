import 'dart:developer';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_note_usecase.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/markdown_highlight_controller.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

import 'markdown_edit_note_data.dart';
import 'markdown_edit_note_event.dart';
import 'markdown_edit_note_state.dart';

final class MarkdownEditNoteBloc
    extends Bloc<MarkdownEditNoteEvent, MarkdownEditNoteState> {
  final PathParams? pathParams;
  final Brightness brightness;
  late final MarkdownHighlightController textController;
  late final GetNoteUsecase _getNoteUsecase = DiStorage.shared.resolve();
  late final CreateNoteUsecase _createNoteUsecase = DiStorage.shared.resolve();

  MarkdownEditNoteData get data => state.data;

  MarkdownEditNoteBloc({required this.pathParams, required this.brightness})
    : super(
        MarkdownEditNoteState.common(data: MarkdownEditNoteData.initial()),
      ) {
    textController = MarkdownHighlightController(brightness: brightness);
    _setupHandlers();
    add(const MarkdownEditNoteEvent.initial());
  }

  @override
  Future<void> close() {
    textController.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<SaveEvent>(_onSaveEvent);
    on<TextChangedEvent>(_onTextChangedEvent);
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<MarkdownEditNoteState> emit,
  ) async {
    try {
      final noteId = pathParams?.id;
      if (noteId == null || noteId.isEmpty) {
        return;
      }

      final note = await _getNoteUsecase.execute(noteId);
      final content = note?.content ?? '';

      textController.text = content;

      emit(
        MarkdownEditNoteState.common(
          data: data.copyWith(
            initialNote: OptionalBox(note),
            currentText: content,
          ),
        ),
      );
    } catch (e) {
      emit(MarkdownEditNoteState.error(e: e, data: data));
    }
  }

  void _onSaveEvent(
    SaveEvent event,
    Emitter<MarkdownEditNoteState> emit,
  ) async {
    try {
      final trimmedText = textController.text.trim();

      log(trimmedText, name: 'MarkdownEditNoteBloc');

      if (trimmedText.isEmpty) {
        final message = ErrorMessagesProvider
            .defaultProvider
            .noteScreenNoteContentCannotBeEmpty;
        throw AppError.common(message: message);
      }

      emit(MarkdownEditNoteState.loading(data: data));

      final result = await _createNoteUsecase.execute(
        content: trimmedText,
        dTag: data.initialNote.value?.dTag,
      );

      emit(
        MarkdownEditNoteState.didSave(
          data: data.copyWith(
            initialNote: OptionalBox(result),
            currentText: result.content,
            hasChanges: false,
          ),
        ),
      );
    } catch (e) {
      emit(MarkdownEditNoteState.error(e: e, data: data));
    }
  }

  void _onTextChangedEvent(
    TextChangedEvent event,
    Emitter<MarkdownEditNoteState> emit,
  ) {
    final initialContent = data.initialNote.value?.content ?? '';
    final hasChanged = event.text.trim() != initialContent.trim();

    emit(
      MarkdownEditNoteState.common(
        data: data.copyWith(currentText: event.text, hasChanges: hasChanged),
      ),
    );
  }
}
