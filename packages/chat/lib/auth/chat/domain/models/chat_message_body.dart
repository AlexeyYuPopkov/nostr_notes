import 'package:equatable/equatable.dart';
import 'package:webrtc_call/webrtc_call.dart';

/// What a chat message carries.
sealed class ChatMessageBody extends Equatable {
  const ChatMessageBody();
}

final class ChatText extends ChatMessageBody {
  final String text;

  const ChatText(this.text);

  @override
  List<Object?> get props => [text];
}

/// The sender started a call; the peer joins it by accepting.
final class ChatCallInvite extends ChatMessageBody {
  /// Ties the invite to the replies about the same call.
  final String callId;
  final CallMedia media;

  const ChatCallInvite({required this.callId, required this.media});

  @override
  List<Object?> get props => [callId, media];
}

/// A reply to a [ChatCallInvite] with the same [callId].
sealed class ChatCallNotice extends ChatMessageBody {
  final String callId;

  const ChatCallNotice(this.callId);

  @override
  List<Object?> get props => [callId];
}

/// The invited peer turned the call down.
final class ChatCallDecline extends ChatCallNotice {
  const ChatCallDecline(super.callId);
}

/// The caller hung up before the peer answered.
final class ChatCallCancel extends ChatCallNotice {
  const ChatCallCancel(super.callId);
}
