import 'package:collection/collection.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';

import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

class GetNotesUsecase {
  final NotesRepository _notesRepository;
  final SessionUsecase _sessionUsecase;

  GetNotesUsecase({
    required NotesRepository notesRepository,
    required SessionUsecase sessionUsecase,
  })  : _notesRepository = notesRepository,
        _sessionUsecase = sessionUsecase;

  Future<List<Note>> execute() async {
    final keys = _sessionUsecase.currentSession.keys;
    final publicKey = keys?.publicKey;
    final privateKey = keys?.privateKey;
    if (publicKey == null || publicKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    if (privateKey == null || privateKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    final result = await _notesRepository.getNotes(
      pubkey: publicKey,
      privateKey: privateKey,
    );
    return result.sorted(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );
  }
}
