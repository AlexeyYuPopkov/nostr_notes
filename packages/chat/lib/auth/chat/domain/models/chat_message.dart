import 'package:equatable/equatable.dart';

import 'chat_message_body.dart';
import 'room_id.dart';

enum ChatMessageDelivery { sending, sent }

final class ChatMessage extends Equatable {
  /// The `d` tag: stays the same across edits.
  final String id;
  final String eventId;
  final String authorPubkey;
  final String peerPubkey;
  final ChatMessageBody body;
  final DateTime publishedAt;

  /// Null until the message is edited.
  final DateTime? editedAt;
  final ChatMessageDelivery delivery;

  const ChatMessage({
    required this.id,
    required this.eventId,
    required this.authorPubkey,
    required this.peerPubkey,
    required this.body,
    required this.publishedAt,
    this.editedAt,
    this.delivery = ChatMessageDelivery.sent,
  });

  RoomId get roomId => RoomId.of(authorPubkey, peerPubkey);

  /// Null for anything but a text message.
  String? get text => switch (body) {
    ChatText(:final text) => text,
    ChatCallInvite() || ChatCallNotice() => null,
  };

  bool get isEdited => editedAt != null;

  DateTime get lastChangedAt => editedAt ?? publishedAt;

  /// The other side of the conversation as seen by [myPubkey].
  String counterpartOf(String myPubkey) =>
      authorPubkey == myPubkey ? peerPubkey : authorPubkey;

  ChatMessage copyWith({ChatMessageDelivery? delivery}) {
    return ChatMessage(
      id: id,
      eventId: eventId,
      authorPubkey: authorPubkey,
      peerPubkey: peerPubkey,
      body: body,
      publishedAt: publishedAt,
      editedAt: editedAt,
      delivery: delivery ?? this.delivery,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    authorPubkey,
    peerPubkey,
    body,
    publishedAt,
    editedAt,
    delivery,
  ];
}
