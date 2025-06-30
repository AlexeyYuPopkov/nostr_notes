import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

final class CreateNoteUsecase {
  static const summaryLength = 100;
  final SessionUsecase _sessionUsecase;
  final EventPublisher _eventPublisher;
  final NoteCryptoUseCase _noteCryptoUseCase;

  CreateNoteUsecase({
    required SessionUsecase sessionUsecase,
    required EventPublisher eventPublisher,
    required NoteCryptoUseCase noteCryptoUseCase,
  })  : _sessionUsecase = sessionUsecase,
        _eventPublisher = eventPublisher,
        _noteCryptoUseCase = noteCryptoUseCase;

  Future<EventPublisherResult> execute({
    // required Note note,
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
      dTag: '',
      content: content,
      summary: '',
      createdAt: DateTime.fromMicrosecondsSinceEpoch(0),
    );

    final summary = note.content.length > summaryLength
        ? note.content.substring(0, summaryLength)
        : note.content;

    final encryptedNote = await _noteCryptoUseCase.encryptNote(
      note.copyWith(
        summary: summary,
      ),
    );

    return _eventPublisher.publishNote(
      content: encryptedNote.content,
      summary: encryptedNote.summary,
      publicKey: keys.publicKey,
      privateKey: keys.privateKey,
      dTag: dTag,
      now: now,
      uuid: uuid,
      randomBytes: randomBytes,
    );
  }
}
