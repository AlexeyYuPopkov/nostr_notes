import 'package:chat/auth/chat/domain/models/chat_exception.dart';
import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/usecase/edit_chat_message_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:collection/collection.dart';
import 'package:common/services/event_store/raw_event_store.dart';

import 'direct_message_tags.dart';
import 'direct_message_writer.dart';

final class EditChatMessageUsecaseImpl implements EditChatMessageUsecase {
  final SessionUsecase _sessionUsecase;
  final RawEventStore _eventStore;
  final DirectMessageWriter _writer;
  final DateTime Function() _now;

  EditChatMessageUsecaseImpl({
    required this._sessionUsecase,
    required this._eventStore,
    required this._writer,
    this._now = DateTime.now,
  });

  @override
  Future<void> execute({
    required ChatMessage message,
    required String text,
  }) async {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      throw const ChatNoSessionException();
    }
    if (message.authorPubkey != keys.publicKey) {
      throw const ChatNotMyMessageException();
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const ChatEmptyMessageException();
    }

    final previous = await _eventStore.queryEvents(
      DirectMessageTags.byId(author: keys.publicKey, id: message.id),
    );

    await _writer.write(
      keys: keys,
      id: message.id,
      peerPubkey: message.peerPubkey,
      text: trimmed,
      publishedAtSeconds:
          message.publishedAt.millisecondsSinceEpoch ~/
          Duration.millisecondsPerSecond,
      createdAt: _createdAtAfter(previous.map((e) => e.createdAt).maxOrNull),
      replacedEventIds: {for (final event in previous) event.id},
    );
  }

  /// Relays keep only the newest version of an addressable event, so an edit
  /// must be strictly newer even when the device clock is behind.
  DateTime _createdAtAfter(int? previousSeconds) {
    final now = _now();
    final nowSeconds =
        now.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    if (previousSeconds == null || nowSeconds > previousSeconds) {
      return now;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      (previousSeconds + 1) * Duration.millisecondsPerSecond,
    );
  }
}
