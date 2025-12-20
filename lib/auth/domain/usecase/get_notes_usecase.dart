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
    return [
      for (final note in result) await _noteCryptoUseCase.decryptSummary(note),
    ].sorted((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
