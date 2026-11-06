import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:collection/collection.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

abstract final class ChatMessageMapper {
  /// Keyed by `d`, so an edit updates the bubble in place.
  static core.Message toUi(ChatMessage message) {
    return core.Message.text(
      id: message.id,
      authorId: message.authorPubkey,
      createdAt: message.publishedAt,
      editedAt: message.editedAt,
      text: message.text,
      status: switch (message.delivery) {
        ChatMessageDelivery.sending => core.MessageStatus.sending,
        ChatMessageDelivery.sent => core.MessageStatus.sent,
      },
    );
  }
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
