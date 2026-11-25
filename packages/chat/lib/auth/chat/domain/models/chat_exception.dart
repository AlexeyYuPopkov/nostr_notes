sealed class ChatException implements Exception {
  const ChatException();
}

final class ChatNoSessionException extends ChatException {
  const ChatNoSessionException();
}

final class ChatEmptyMessageException extends ChatException {
  const ChatEmptyMessageException();
}

/// Only the author can edit a message.
final class ChatNotMyMessageException extends ChatException {
  const ChatNotMyMessageException();
}

/// Only text messages can be edited.
final class ChatNotEditableException extends ChatException {
  const ChatNotEditableException();
}
