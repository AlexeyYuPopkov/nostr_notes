import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/presentation/common/chat_message_preview.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webrtc_call/webrtc_call.dart';

/// An invite, decline or cancel in the conversation.
final class CallBubble extends StatelessWidget {
  final ChatMessageBody body;
  final bool isSentByMe;

  const CallBubble({super.key, required this.body, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = isSentByMe ? colors.onPrimary : colors.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSentByMe ? colors.primary : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Sizes.indent2x),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.indent2x,
          vertical: Sizes.indent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Sizes.indent,
          children: [
            Icon(_icon, color: foreground),
            Text(body.preview(context), style: TextStyle(color: foreground)),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (body) {
    ChatCallInvite(media: CallMedia.audio) => Icons.call,
    ChatCallInvite(media: CallMedia.video) => Icons.videocam,
    ChatCallDecline() => Icons.call_end,
    ChatCallCancel() => Icons.phone_missed,
    ChatText() => Icons.chat_bubble_outline,
  };
}
