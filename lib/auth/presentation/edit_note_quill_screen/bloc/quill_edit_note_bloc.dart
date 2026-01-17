import 'dart:async';
import 'dart:developer';
// ignore: depend_on_referenced_packages
import 'package:markdown/markdown.dart' as md;
import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/get_note_usecase.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';
import 'package:rxdart/rxdart.dart';

import 'quill_edit_note_data.dart';
import 'quill_edit_note_event.dart';
import 'quill_edit_note_state.dart';

final class QuillEditNoteBloc
    extends Bloc<QuillEditNoteEvent, QuillEditNoteState> {
  final PathParams? pathParams;
  late final controller = QuillController.basic();
  late final GetNoteUsecase _getNoteUsecase = DiStorage.shared.resolve();
  late final CreateNoteUsecase _createNoteUsecase = DiStorage.shared.resolve();

  StreamSubscription? _controllerSubscription;

  QuillEditNoteData get data => state.data;

  QuillEditNoteBloc({required this.pathParams})
    : super(QuillEditNoteState.common(data: QuillEditNoteData.initial())) {
    _setupHandlers();

    add(const QuillEditNoteEvent.initial());
  }

  @override
  Future<void> close() {
    _controllerSubscription?.cancel();
    _controllerSubscription = null;
    controller.dispose();
    return super.close();
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<SaveEvent>(_onSaveEvent);
    on<ShouldCheckChanges>(_onShouldCheckChanges);
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<QuillEditNoteState> emit,
  ) async {
    try {
      final noteId = pathParams?.id;
      if (noteId == null || noteId.isEmpty) {
        return;
      }

      final note = await _getNoteUsecase.execute(noteId);
      final str = note?.content ?? '';

      final mdDocument = md.Document(encodeHtml: false);
      final _ = mdDocument.parse(str);
      final mdToDelta = MarkdownToDelta(markdownDocument: mdDocument);

      controller.document = Document.fromDelta(mdToDelta.convert(str));

      emit(
        QuillEditNoteState.common(
          data: data.copyWith(initialNote: OptionalBox(note)),
        ),
      );
    } catch (e) {
      emit(QuillEditNoteState.error(e: e, data: data));
    } finally {
      _controllerSubscription = controller.changes
          .debounceTime(const Duration(milliseconds: 300))
          .listen((_) {
            add(const QuillEditNoteEvent.shouldCheckChanges());
          });
    }
  }

  void _onSaveEvent(SaveEvent event, Emitter<QuillEditNoteState> emit) async {
    try {
      final deltaToMd = DeltaToMarkdown();

      // controller.changes.listen((event) {});

      final md = deltaToMd.convert(controller.document.toDelta());

      log(md, name: 'NoteBloc');

      final trimmedText = md.trim();

      if (trimmedText.isEmpty) {
        final message = ErrorMessagesProvider
            .defaultProvider
            .noteScreenNoteContentCannotBeEmpty;
        throw AppError.common(message: message);
      }

      emit(QuillEditNoteState.loading(data: data));

      final result = await _createNoteUsecase.execute(
        content: trimmedText,
        dTag: data.initialNote.value?.dTag,
      );

      final newNote = result.note;

      if (newNote is Note) {
        emit(
          QuillEditNoteState.didSave(
            data: data.copyWith(initialNote: OptionalBox(newNote)),
          ),
        );

        add(const InitialEvent());
      } else {
        throw const AppError.undefined();
      }
    } catch (e) {
      emit(QuillEditNoteState.error(e: e, data: data));
    } finally {
      add(const QuillEditNoteEvent.shouldCheckChanges());
    }
  }

  void _onShouldCheckChanges(
    ShouldCheckChanges event,
    Emitter<QuillEditNoteState> emit,
  ) {
    final str = data.initialNote.value?.content ?? '';

    final deltaToMd = DeltaToMarkdown();

    final md = deltaToMd.convert(controller.document.toDelta());

    final hasChanged = md.trim() != str.trim();

    emit(
      QuillEditNoteState.common(data: data.copyWith(hasChanges: hasChanged)),
    );
  }
}
