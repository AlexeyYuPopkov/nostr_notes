import 'package:chat/auth/chat/domain/models/chat_message.dart';

abstract interface class EditChatMessageUsecase {
  /// Replaces [message] (same `d`) and queues the new version for relays.
  Future<void> execute({required ChatMessage message, required String text});
}
