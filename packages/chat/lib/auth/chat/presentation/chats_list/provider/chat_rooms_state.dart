import 'package:equatable/equatable.dart';

import 'chat_rooms_data.dart';

sealed class ChatRoomsState extends Equatable {
  final ChatRoomsData data;

  const ChatRoomsState({required this.data});

  @override
  List<Object?> get props => [data];
}

final class ChatRoomsLoading extends ChatRoomsState {
  const ChatRoomsLoading({required super.data});
}

final class ChatRoomsError extends ChatRoomsState {
  final Object error;
  const ChatRoomsError({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}

final class ChatRoomsCommon extends ChatRoomsState {
  const ChatRoomsCommon({required super.data});
}
