import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:collection/collection.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

abstract final class ChatMessageMapper {
  static const _callBodyKey = 'callBody';

  /// Keyed by `d`, so an edit updates the bubble in place.
  static core.Message toUi(ChatMessage message) {
    final status = switch (message.delivery) {
      ChatMessageDelivery.sending => core.MessageStatus.sending,
      ChatMessageDelivery.sent => core.MessageStatus.sent,
    };
    return switch (message.body) {
      ChatText(:final text) => core.Message.text(
        id: message.id,
        authorId: message.authorPubkey,
        createdAt: message.publishedAt,
        editedAt: message.editedAt,
        text: text,
        status: status,
      ),
      ChatCallInvite() || ChatCallNotice() => core.Message.custom(
        id: message.id,
        authorId: message.authorPubkey,
        createdAt: message.publishedAt,
        metadata: {_callBodyKey: message.body},
        status: status,
      ),
    };
  }

  /// The call invite or notice [toUi] put into a custom message.
  static ChatMessageBody? callBodyOf(core.CustomMessage message) =>
      switch (message.metadata?[_callBodyKey]) {
        final ChatMessageBody body => body,
        _ => null,
      };
}

extension ChatControllerSync on core.ChatController {
  /// Applies [next] with the smallest change the list can animate: appended
  /// messages are inserted, changed ones updated; anything else resets it.
  Future<void> syncWith(List<core.Message> next) async {
    final current = messages;
    final currentIds = current.map((e) => e.id).toList();
    final nextIds = next.map((e) => e.id).toList();

    final keepsOrder =
        nextIds.length >= currentIds.length &&
        const ListEquality<String>().equals(
          nextIds.sublist(0, currentIds.length),
          currentIds,
        );
    if (!keepsOrder) {
      await setMessages(next);
      return;
    }

    for (final (index, message) in current.indexed) {
      if (message != next[index]) {
        await updateMessage(message, next[index]);
      }
    }
    final appended = next.sublist(current.length);
    if (appended.isNotEmpty) {
      await insertAllMessages(appended);
    }
  }
}
