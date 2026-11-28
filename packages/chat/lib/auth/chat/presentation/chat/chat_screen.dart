import 'dart:async';

import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/presentation/chat/provider/chat_data.dart';
import 'package:chat/auth/chat/presentation/chat/provider/chat_provider.dart';
import 'package:chat/auth/chat/presentation/chat/provider/chat_state.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/presentation/chat/widgets/call_bubble.dart';
import 'package:chat/auth/chat/presentation/chat/widgets/chat_message_mapper.dart';
import 'package:chat/auth/chat/presentation/chat/widgets/editing_banner.dart';
import 'package:chat/auth/chat/presentation/chat/widgets/message_actions_sheet.dart';
import 'package:chat/auth/chat/presentation/common/user_title.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/account_avatar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webrtc_call/webrtc_call.dart';

abstract interface class ChatScreenCoordinator {
  Future<void> onCallRoute(
    BuildContext context, {
    required String peerPubkey,
    required CallMedia media,
  });
}

final class ChatScreen extends ConsumerStatefulWidget {
  /// A key, not a Semantics id: flutter_chat_ui's Composer is a Positioned
  /// child of the chat's Stack, so it cannot be wrapped.
  static const composerKey = ValueKey('ChatScreen.composer');
  static const sendButtonSemanticsId = 'ChatScreen.sendButton';
  static const audioCallSemanticsId = 'ChatScreen.audioCall';
  static const videoCallSemanticsId = 'ChatScreen.videoCall';

  final String pubkey;
  final ChatScreenCoordinator coordinator;

  const ChatScreen({
    super.key,
    required this.pubkey,
    required this.coordinator,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

final class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _appBarAvatarSize = 32.0;

  final _chatController = core.InMemoryChatController();
  final _composerController = TextEditingController();

  ChatProviderProvider get _provider => chatProviderProvider(widget.pubkey);

  @override
  void dispose() {
    _chatController.dispose();
    _composerController.dispose();
    super.dispose();
  }

  void _onState(ChatState? previous, ChatState next) {
    final data = next.data;
    if (previous?.data.messages != data.messages) {
      unawaited(
        _chatController.syncWith(
          data.messages.map((message) => message.toUiMessage()).toList(),
        ),
      );
    }

    final editingText = data.editing?.text;
    if (editingText != null && previous?.data.editing != data.editing) {
      _composerController.text = editingText;
    }

    if (next is ChatSendError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.chatSendError)));
    }
  }

  void _onSend(String text) {
    unawaited(ref.read(_provider.notifier).submit(text));
  }

  void _cancelEditing() {
    _composerController.clear();
    ref.read(_provider.notifier).cancelEditing();
  }

  Future<void> _onLongPress(core.Message message) async {
    final chatMessage = ref
        .read(_provider)
        .data
        .messages
        .where((e) => e.id == message.id)
        .firstOrNull;
    final text = chatMessage?.text;
    if (chatMessage == null || text == null) {
      return;
    }

    final action = await MessageActionsSheet.show(
      context,
      canEdit: ref.read(_provider).data.canEdit(chatMessage),
    );
    switch (action) {
      case MessageAction.edit:
        ref.read(_provider.notifier).startEditing(chatMessage);
      case MessageAction.copy:
        await Clipboard.setData(ClipboardData(text: text));
      case null:
        break;
    }
  }

  void _call(CallMedia media) {
    unawaited(
      widget.coordinator.onCallRoute(
        context,
        peerPubkey: widget.pubkey,
        media: media,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider, _onState);
    final state = ref.watch(_provider);
    final data = state.data;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AccountAvatar(
              pubkey: data.peer.pubkey,
              size: _appBarAvatarSize,
              pictureUrl: data.peer.picture,
            ),
            const SizedBox(width: Sizes.indent),
            Expanded(
              child: Text(
                data.peer.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            identifier: ChatScreen.audioCallSemanticsId,
            label: l10n.chatAudioCall,
            child: IconButton(
              tooltip: l10n.chatAudioCall,
              icon: const Icon(Icons.call),
              onPressed: () => _call(CallMedia.audio),
            ),
          ),
          Semantics(
            identifier: ChatScreen.videoCallSemanticsId,
            label: l10n.chatVideoCall,
            child: IconButton(
              tooltip: l10n.chatVideoCall,
              icon: const Icon(Icons.videocam),
              onPressed: () => _call(CallMedia.video),
            ),
          ),
        ],
      ),
      body: switch (state) {
        ChatLoading() => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        ChatLoadError() => Center(child: Text(l10n.chatLoadError)),
        ChatCommon() || ChatSendError() => ui.Chat(
          chatController: _chatController,
          currentUserId: data.myPubkey,
          resolveUser: (id) async => _resolveUser(data, id),
          onMessageSend: _onSend,
          onMessageLongPress:
              (context, message, {required index, required details}) =>
                  unawaited(_onLongPress(message)),
          theme: core.ChatTheme.fromThemeData(theme),
          backgroundColor: theme.colorScheme.surface,
          builders: core.Builders(
            composerBuilder: (context) => ui.Composer(
              key: ChatScreen.composerKey,
              textEditingController: _composerController,
              hintText: l10n.chatMessageHint,
              sendIcon: Semantics(
                identifier: ChatScreen.sendButtonSemanticsId,
                label: l10n.chatSend,
                child: const Icon(Icons.send),
              ),
              topWidget: data.editing == null
                  ? null
                  : EditingBanner(onCancel: _cancelEditing),
            ),
            textMessageBuilder:
                (context, message, index, {required isSentByMe, groupStatus}) =>
                    ui.SimpleTextMessage(
                      message: message,
                      index: index,
                      topWidget: message.editedAt == null
                          ? null
                          : const EditedLabel(),
                    ),
            customMessageBuilder:
                (context, message, index, {required isSentByMe, groupStatus}) =>
                    switch (ChatMessageMapper.callBodyOf(message)) {
                      final ChatMessageBody body => CallBubble(
                        body: body,
                        isSentByMe: isSentByMe,
                      ),
                      null => const SizedBox.shrink(),
                    },
            emptyChatListBuilder: (context) =>
                ui.EmptyChatList(text: context.l10n.chatEmpty),
          ),
        ),
      },
    );
  }

  static core.User _resolveUser(ChatData data, String id) {
    final user = id == data.peer.pubkey ? data.peer : null;
    return core.User(id: id, name: user?.title, imageSource: user?.picture);
  }
}

extension on ChatMessage {
  core.Message toUiMessage() => ChatMessageMapper.toUi(this);
}
