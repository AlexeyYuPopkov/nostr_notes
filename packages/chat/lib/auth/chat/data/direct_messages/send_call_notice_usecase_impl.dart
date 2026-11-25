import 'package:chat/auth/chat/domain/models/chat_exception.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/chat/domain/usecase/send_call_notice_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:nostr/key_tool/key_tool.dart';

import 'direct_message_writer.dart';

final class SendCallNoticeUsecaseImpl implements SendCallNoticeUsecase {
  final SessionUsecase _sessionUsecase;
  final DirectMessageWriter _writer;
  final DateTime Function() _now;
  final String Function() _newMessageId;

  SendCallNoticeUsecaseImpl({
    required this._sessionUsecase,
    required this._writer,
    this._now = DateTime.now,
    this._newMessageId = KeyTool.random64HexChars,
  });

  @override
  Future<void> execute({
    required String peerPubkey,
    required ChatCallNotice notice,
  }) async {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      throw const ChatNoSessionException();
    }

    final now = _now();
    await _writer.write(
      keys: keys,
      id: _newMessageId(),
      peerPubkey: peerPubkey,
      body: notice,
      publishedAtSeconds:
          now.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond,
      createdAt: now,
    );
  }
}
