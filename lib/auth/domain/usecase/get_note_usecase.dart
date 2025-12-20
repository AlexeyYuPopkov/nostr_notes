import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';

import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

class GetNoteUsecase {
  final NotesRepository _notesRepository;
  final SessionUsecase _sessionUsecase;
  final NoteCryptoUseCase _noteCryptoUseCase;

  GetNoteUsecase({
    required NotesRepository notesRepository,
    required SessionUsecase sessionUsecase,
    required NoteCryptoUseCase noteCryptoUseCase,
  }) : _notesRepository = notesRepository,
       _sessionUsecase = sessionUsecase,
       _noteCryptoUseCase = noteCryptoUseCase;

  Future<Note?> execute(String id) async {
    final keys = _sessionUsecase.currentSession.keys;
    final publicKey = keys?.publicKey;
    final privateKey = keys?.privateKey;
    if (publicKey == null || publicKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    if (privateKey == null || privateKey.isEmpty) {
      throw const AppError.notAuthenticated();
    }

    final encryptedResult = await _notesRepository.getNote(
      pubkey: publicKey,
      privateKey: privateKey,
      id: id,
    );

    if (encryptedResult == null) {
      return null;
    }

    final result = await _noteCryptoUseCase.decryptNote(encryptedResult);

    return result;
  }
}
