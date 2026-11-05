import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:chat/auth/chat/presentation/common/user_title.dart';
import 'package:common/presentation/account_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final class ChatRoomCell extends StatelessWidget {
  static const avatarSize = 48.0;

  final ChatRoom room;
  final VoidCallback onTap;

  const ChatRoomCell({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final peer = room.peer;

    return Semantics(
      identifier: semanticsIdFor(peer.pubkey),
      button: true,
      child: ListTile(
        leading: AccountAvatar(
          pubkey: peer.pubkey,
          size: avatarSize,
          pictureUrl: peer.picture,
        ),
        title: Text(peer.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          room.lastMessage.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatTime(context, room.lastMessage.publishedAt),
          style: theme.textTheme.bodySmall,
        ),
        onTap: onTap,
      ),
    );
  }

  static String semanticsIdFor(String pubkey) => 'ChatRoomCell.$pubkey';

  static String _formatTime(BuildContext context, DateTime time) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final isToday =
        time.year == now.year && time.month == now.month && time.day == now.day;
    return isToday
        ? DateFormat.Hm(locale).format(time)
        : DateFormat.MMMd(locale).format(time);
  }
}
