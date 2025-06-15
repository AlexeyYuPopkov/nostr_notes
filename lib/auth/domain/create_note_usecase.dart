import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

final class CreateNoteUsecase {
  final SessionUsecase _sessionUsecase;

  final EventPublisher _eventPublisher;

  CreateNoteUsecase({
    required SessionUsecase sessionUsecase,
    required EventPublisher eventPublisher,
  })  : _sessionUsecase = sessionUsecase,
        _eventPublisher = eventPublisher;

  Future<void> execute({
    required String content,
  }) {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      throw const NotAuthenticatedError();
    }

    return _eventPublisher.publishNote(
      content: content,
      publicKey: keys.publicKey,
      privateKey: keys.privateKey,
    );
  }
}
