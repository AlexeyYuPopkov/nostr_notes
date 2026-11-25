import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/l10n/localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webrtc_call/webrtc_call.dart';

extension ChatMessagePreview on ChatMessageBody {
  /// One line for the chats list and the call bubbles.
  String preview(BuildContext context) => switch (this) {
    ChatText(:final text) => text,
    ChatCallInvite(media: CallMedia.audio) => context.l10n.chatCallInviteAudio,
    ChatCallInvite(media: CallMedia.video) => context.l10n.chatCallInviteVideo,
    ChatCallDecline() => context.l10n.chatCallDeclined,
    ChatCallCancel() => context.l10n.chatCallCancelled,
  };
}
