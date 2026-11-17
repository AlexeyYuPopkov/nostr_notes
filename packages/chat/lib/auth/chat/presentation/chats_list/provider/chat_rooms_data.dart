import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:equatable/equatable.dart';

final class ChatRoomsData extends Equatable {
  final List<ChatRoom> rooms;

  const ChatRoomsData({required this.rooms});

  const ChatRoomsData.initial() : rooms = const [];

  @override
  List<Object?> get props => [rooms];
}
