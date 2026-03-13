import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';

import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

final class DeleteNoteUsecase {
  static const summaryLength = 100;
  final SessionUsecase _sessionUsecase;
  final NotesRepository _notesRepository;

  DeleteNoteUsecase({
    required SessionUsecase sessionUsecase,
    required NotesRepository notesRepository,
  }) : _sessionUsecase = sessionUsecase,
       _notesRepository = notesRepository;

  Future<Note> execute({
    required Note note,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  }) async {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      throw const NotAuthenticatedError();
    }

    final result = await _notesRepository.deleteNote(
      note: note,
      pubkey: keys.publicKey,
      privateKey: keys.privateKey,
      now: now,
      uuid: uuid,
      randomBytes: randomBytes,
    );

    return result;
  }
}
