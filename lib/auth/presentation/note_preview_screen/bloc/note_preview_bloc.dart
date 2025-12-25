import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/usecase/get_note_usecase.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_data.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_event.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_state.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class NotePreviewBloc extends Bloc<NotePreviewEvent, NotePreviewState> {
  final PathParams pathParams;
  NotePreviewData get data => state.data;
  late final GetNoteUsecase _getNoteUsecase = DiStorage.shared.resolve();

  NotePreviewBloc({required this.pathParams})
    : super(NotePreviewState.common(data: NotePreviewData.initial())) {
    _setupHandlers();

    add(const NotePreviewEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<NotePreviewState> emit,
  ) async {
    try {
      emit(NotePreviewState.loading(data: data));

      final note = await _getNoteUsecase.execute(pathParams.id);

      emit(
        NotePreviewState.common(data: data.copyWith(note: OptionalBox(note))),
      );
    } catch (e) {
      emit(NotePreviewState.error(e: e, data: data));
    }
  }
}
