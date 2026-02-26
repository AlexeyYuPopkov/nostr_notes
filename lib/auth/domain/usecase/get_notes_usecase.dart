import 'package:collection/collection.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';

import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

class GetNotesUsecase {
  final NotesRepository _notesRepository;
  final SessionUsecase _sessionUsecase;
  final NoteCryptoUseCase _noteCryptoUseCase;

  GetNotesUsecase({
    required NotesRepository notesRepository,
    required SessionUsecase sessionUsecase,
    required NoteCryptoUseCase noteCryptoUseCase,
  }) : _notesRepository = notesRepository,
       _sessionUsecase = sessionUsecase,
       _noteCryptoUseCase = noteCryptoUseCase;

  Stream<List<Note>> execute() {
    final keys = _sessionUsecase.currentSession.keys;
    final publicKey = keys?.publicKey;

    if (publicKey == null || publicKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    return _notesRepository.watchNotes(pubkey: publicKey).asyncMap((
      items,
    ) async {
      return [
        for (final note in items) await _noteCryptoUseCase.decryptSummary(note),
      ].sorted((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }
}
