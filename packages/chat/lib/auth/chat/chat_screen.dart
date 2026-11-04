import 'package:chat/auth/chat/provider/chat_messages_provider.dart';
import 'package:chat/common/domain/models/chat_message.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ChatScreen extends ConsumerStatefulWidget {
  static const messageFieldSemanticsId = 'ChatScreen.messageField';
  static const sendButtonSemanticsId = 'ChatScreen.sendButton';

  final String pubkey;

  const ChatScreen({super.key, required this.pubkey});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

final class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _messageController.clear();
    ref.read(chatMessagesProvider(widget.pubkey).notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        ref.watch(chatMessagesProvider(widget.pubkey)).value ??
        const <ChatMessage>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pubkey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(Sizes.indent2x),
                itemCount: messages.length,
                itemBuilder: (context, index) => Text(messages[index].text),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Sizes.indent),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      identifier: ChatScreen.messageFieldSemanticsId,
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: context.l10n.chatMessageHint,
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  Semantics(
                    identifier: ChatScreen.sendButtonSemanticsId,
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      tooltip: context.l10n.chatSend,
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
