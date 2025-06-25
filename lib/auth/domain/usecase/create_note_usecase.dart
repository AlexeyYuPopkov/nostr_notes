import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

final class CreateNoteUsecase {
  static const summaryLength = 100;
  final SessionUsecase _sessionUsecase;
  final EventPublisher _eventPublisher;

  CreateNoteUsecase({
    required SessionUsecase sessionUsecase,
    required EventPublisher eventPublisher,
  })  : _sessionUsecase = sessionUsecase,
        _eventPublisher = eventPublisher;

  Future<EventPublisherResult> execute({
    required String content,
    required String? dTag,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  }) {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      throw const NotAuthenticatedError();
    }

    final summary = content.length > summaryLength
        ? content.substring(0, summaryLength)
        : content;

    return _eventPublisher.publishNote(
      content: content,
      summary: summary,
      publicKey: keys.publicKey,
      privateKey: keys.privateKey,
      dTag: dTag,
      now: now,
      uuid: uuid,
      randomBytes: randomBytes,
    );
  }
}
