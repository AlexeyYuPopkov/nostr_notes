import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:rxdart/rxdart.dart';

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

    return _notesRepository.watchNotes(pubkey: publicKey).switchMap((items) {
      if (items.isEmpty) {
        return Stream.value(<Note>[]);
      }

      return Stream.fromFuture(_decryptNotes(items)).map((decryptedNotes) {
        return decryptedNotes.sorted(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
      });
    });
  }

  Future<Iterable<Note>> _decryptNotes(Iterable<Note> notes) async {
    final decryptedNotes = <Note>[];

    for (final note in notes) {
      try {
        final decryptedNote = await _noteCryptoUseCase.decryptNote(note);
        decryptedNotes.add(decryptedNote);
      } catch (e, s) {
        log('Failed to decrypt note ${note.dTag}: $e', stackTrace: s);
      }
    }

    return decryptedNotes;
  }
}
