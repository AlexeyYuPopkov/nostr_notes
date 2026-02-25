import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

final class CreateNoteUsecase {
  static const summaryLength = 100;
  final SessionUsecase _sessionUsecase;
  final NoteCryptoUseCase _noteCryptoUseCase;
  final NotesRepository _notesRepository;

  CreateNoteUsecase({
    required SessionUsecase sessionUsecase,
    required NoteCryptoUseCase noteCryptoUseCase,
    required NotesRepository notesRepository,
  }) : _sessionUsecase = sessionUsecase,

       _noteCryptoUseCase = noteCryptoUseCase,
       _notesRepository = notesRepository;

  Future<Note> execute({
    required String content,
    required String? dTag,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  }) async {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      throw const NotAuthenticatedError();
    }

    final note = Note(
      eventId: '',
      dTag: dTag ?? '',
      content: content,
      summary: '',
      createdAt: DateTime.fromMicrosecondsSinceEpoch(0),
    );

    final summary = note.content.length > summaryLength
        ? note.content.substring(0, summaryLength)
        : note.content;

    final encryptedNote = await _noteCryptoUseCase.encryptNote(
      note.copyWith(summary: summary.byStripMarkDownSymbols()),
    );

    final result = await _notesRepository.publishNote(
      note: encryptedNote,
      pubkey: keys.publicKey,
      privateKey: keys.privateKey,
      now: now,
      uuid: uuid,
      randomBytes: randomBytes,
    );

    final targetNote = result;

    final decryptedNote = await _noteCryptoUseCase.decryptNote(targetNote);

    return decryptedNote;
  }
}

extension on String {
  String byStripMarkDownSymbols() {
    return replaceAll(RegExp(r'[#*`~]'), '');
  }
}
