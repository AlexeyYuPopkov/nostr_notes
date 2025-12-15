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
import 'package:nostr_notes/auth/presentation/note_screen/bloc/note_bloc_data.dart';
import 'package:nostr_notes/auth/presentation/note_screen/bloc/note_bloc_event.dart';
import 'package:nostr_notes/auth/presentation/note_screen/bloc/note_bloc_state.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';
import 'package:rxdart/rxdart.dart';

final class NoteBloc extends Bloc<NoteBlocEvent, NoteBlocState> {
  final PathParams? pathParams;
  late final controller = QuillController.basic();
  late final GetNoteUsecase _getNoteUsecase = DiStorage.shared.resolve();
  late final CreateNoteUsecase _createNoteUsecase = DiStorage.shared.resolve();

  StreamSubscription? _controllerSubscription;

  NoteBlocData get data => state.data;

  NoteBloc({required this.pathParams})
      : super(
          NoteBlocState.common(
            data: NoteBlocData.initial(),
          ),
        ) {
    _setupHandlers();

    add(const NoteBlocEvent.initial());
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
    Emitter<NoteBlocState> emit,
  ) async {
    final noteId = pathParams?.id;
    if (noteId == null || noteId.isEmpty) {
      return;
    }
    try {
      final note = await _getNoteUsecase.execute(noteId);
      final str = note?.content ?? '';

      final mdDocument = md.Document(encodeHtml: false);
      final _ = mdDocument.parse(str);
      final mdToDelta = MarkdownToDelta(markdownDocument: mdDocument);

      controller.document = Document.fromDelta(
        mdToDelta.convert(str),
      );

      emit(
        NoteBlocState.common(
          data: data.copyWith(
            initialNote: OptionalBox(note),
          ),
        ),
      );

      _controllerSubscription = controller.changes
          .debounceTime(const Duration(milliseconds: 300))
          .listen((_) => add(const NoteBlocEvent.shouldCheckChanges()));
    } catch (e) {
      emit(NoteBlocState.error(e: e, data: data));
    }
  }

  void _onSaveEvent(
    SaveEvent event,
    Emitter<NoteBlocState> emit,
  ) async {
    try {
      final deltaToMd = DeltaToMarkdown();

      // controller.changes.listen((event) {});

      final md = deltaToMd.convert(controller.document.toDelta());

      log(md, name: 'NoteBloc');

      final trimmedText = md.trim();

      if (trimmedText.isEmpty) {
        final message = ErrorMessagesProvider
            .defaultProvider.noteScreenNoteContentCannotBeEmpty;
        throw AppError.common(message: message);
      }

      emit(NoteBlocState.loading(data: data));

      final result = await _createNoteUsecase.execute(
        content: trimmedText,
        dTag: data.initialNote.value?.dTag,
      );

      final newNote = result.targetNote;

      if (newNote is Note) {
        emit(
          NoteBlocState.didSave(
            data: data.copyWith(
              initialNote: OptionalBox(newNote),
            ),
          ),
        );

        add(const InitialEvent());
      } else {
        throw const AppError.undefined();
      }
    } catch (e) {
      emit(NoteBlocState.error(e: e, data: data));
    } finally {
      add(const NoteBlocEvent.shouldCheckChanges());
    }
  }

  void _onShouldCheckChanges(
    ShouldCheckChanges event,
    Emitter<NoteBlocState> emit,
  ) {
    final str = data.initialNote.value?.content ?? '';

    final deltaToMd = DeltaToMarkdown();

    final md = deltaToMd.convert(controller.document.toDelta());

    final hasChanged = md.trim() != str.trim();

    emit(NoteBlocState.common(data: data.copyWith(hasChanges: hasChanged)));
  }
}
