import 'package:chat/common/domain/models/chat.dart';
import 'package:chat/common/domain/models/chat_message.dart';
import 'package:chat/common/domain/repo/chats_repo.dart';

/// In-memory stand-in until messages come from Nostr relays.
final class FakeChatsRepo implements ChatsRepo {
  static const samplePubkeys = [
    '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d',
    '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2',
  ];

  final List<String> _pubkeys;
  final _messages = <String, List<ChatMessage>>{};

  FakeChatsRepo({this._pubkeys = samplePubkeys});

  @override
  Future<List<Chat>> getChats() async {
    return [for (final pubkey in _pubkeys) Chat(pubkey: pubkey)];
  }

  @override
  Future<List<ChatMessage>> getMessages({required String pubkey}) async {
    return List.unmodifiable(_messages[pubkey] ?? const <ChatMessage>[]);
  }

  @override
  Future<void> sendMessage({
    required String pubkey,
    required String text,
  }) async {
    _messages.putIfAbsent(pubkey, () => []).add(ChatMessage(text: text));
  }
}
