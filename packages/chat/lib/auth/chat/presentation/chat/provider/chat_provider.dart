import 'dart:async';

import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:chat/auth/chat/domain/usecase/edit_chat_message_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_chat_messages_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/get_contact_usecase.dart';
import 'package:chat/auth/chat/domain/usecase/send_chat_message_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chat_data.dart';
import 'chat_state.dart';

part 'chat_provider.g.dart';

@riverpod
final class ChatProvider extends _$ChatProvider {
  late final GetChatMessagesUsecase _getMessages = GetIt.I.get();
  late final GetContactUsecase _getContact = GetIt.I.get();
  late final SendChatMessageUsecase _sendMessage = GetIt.I.get();
  late final EditChatMessageUsecase _editMessage = GetIt.I.get();

  ChatData get _data => state.data;

  @override
  ChatState build(String peerPubkey) {
    final myPubkey = GetIt.I.get<SessionUsecase>().currentSession.pubkey;

    final messages = _getMessages
        .execute(peerPubkey: peerPubkey)
        .listen(_onMessages, onError: _onLoadError);
    final peer = _getContact
        .execute(peerPubkey)
        .listen(
          (peer) => state = _withData(_data.copyWith(peer: peer)),
          onError: _onLoadError,
        );
    ref.onDispose(() {
      unawaited(messages.cancel());
      unawaited(peer.cancel());
    });

    return ChatLoading(
      data: ChatData.initial(myPubkey: myPubkey, peerPubkey: peerPubkey),
    );
  }

  void _onMessages(List<ChatMessage> messages) {
    state = ChatCommon(data: _data.copyWith(messages: messages));
  }

  void _onLoadError(Object error) {
    state = ChatLoadError(data: _data, error: error);
  }

  ChatState _withData(ChatData data) => switch (state) {
    ChatLoading() => ChatLoading(data: data),
    ChatLoadError(:final error) => ChatLoadError(data: data, error: error),
    ChatCommon() || ChatSendError() => ChatCommon(data: data),
  };

  void startEditing(ChatMessage message) {
    if (_data.isMine(message)) {
      state = _withData(_data.withEditing(message));
    }
  }

  void cancelEditing() => state = _withData(_data.withEditing(null));

  /// Sends [text], or replaces the message being edited with it.
  Future<void> submit(String text) async {
    final editing = _data.editing;
    try {
      if (editing == null) {
        await _sendMessage.execute(peerPubkey: peerPubkey, text: text);
      } else {
        await _editMessage.execute(message: editing, text: text);
      }
      if (!ref.mounted) return;
      state = _withData(_data.withEditing(null));
    } catch (error) {
      if (!ref.mounted) return;
      state = ChatSendError(data: _data, error: error);
    }
  }
}
