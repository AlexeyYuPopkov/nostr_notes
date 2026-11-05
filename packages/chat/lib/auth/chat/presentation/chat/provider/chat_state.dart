import 'package:equatable/equatable.dart';

import 'chat_data.dart';

sealed class ChatState extends Equatable {
  final ChatData data;

  const ChatState({required this.data});

  @override
  List<Object?> get props => [data];
}

final class ChatLoading extends ChatState {
  const ChatLoading({required super.data});
}

final class ChatCommon extends ChatState {
  const ChatCommon({required super.data});
}

final class ChatLoadError extends ChatState {
  final Object error;

  const ChatLoadError({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}

/// Shown once; the conversation stays usable.
final class ChatSendError extends ChatState {
  final Object error;

  const ChatSendError({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}
