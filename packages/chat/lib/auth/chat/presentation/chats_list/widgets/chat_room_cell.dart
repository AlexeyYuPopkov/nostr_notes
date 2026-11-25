import 'package:chat/auth/chat/presentation/common/chat_message_preview.dart';
import 'dart:async';

import 'package:chat/auth/chat/domain/models/chat_room.dart';
import 'package:chat/auth/chat/domain/usecase/get_user_usecase.dart';
import 'package:chat/auth/chat/presentation/common/user_title.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/presentation/account_avatar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// The peer's profile as stored, kept current while the cell is shown.
final class ChatRoomCellVM {
  final ValueNotifier<User> peer;

  final GetUserUseCase _getUserUsecase = GetIt.I.get();
  StreamSubscription<User>? _subscription;

  ChatRoomCellVM({required String peerPubkey})
    : peer = ValueNotifier(User(pubkey: peerPubkey));

  void init() {
    _subscription = _getUserUsecase
        .execute(pubkey: peer.value.pubkey)
        .listen((user) => peer.value = user);
  }

  void dispose() {
    unawaited(_subscription?.cancel());
    peer.dispose();
  }
}

final class ChatRoomCell extends StatefulWidget {
  static const avatarSize = 48.0;

  final ChatRoom room;
  final VoidCallback onTap;

  const ChatRoomCell({super.key, required this.room, required this.onTap});

  @override
  State<ChatRoomCell> createState() => _ChatRoomCellState();

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

final class _ChatRoomCellState extends State<ChatRoomCell> {
  late ChatRoomCellVM _vm = ChatRoomCellVM(peerPubkey: widget.room.peerPubkey);

  @override
  void initState() {
    super.initState();
    _vm.init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatRoomCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.room.peerPubkey != widget.room.peerPubkey) {
      _vm.dispose();
      _vm = ChatRoomCellVM(peerPubkey: widget.room.peerPubkey)..init();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      identifier: ChatRoomCell.semanticsIdFor(widget.room.peerPubkey),
      button: true,
      child: ValueListenableBuilder(
        valueListenable: _vm.peer,
        builder: (context, peer, child) {
          return ListTile(
            leading: AccountAvatar(
              pubkey: peer.pubkey,
              size: ChatRoomCell.avatarSize,
              pictureUrl: peer.picture,
            ),
            title: Text(
              peer.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              widget.room.lastMessage.body.preview(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              ChatRoomCell._formatTime(
                context,
                widget.room.lastMessage.publishedAt,
              ),
              style: theme.textTheme.bodySmall,
            ),
            onTap: widget.onTap,
          );
        },
      ),
    );
  }
}
