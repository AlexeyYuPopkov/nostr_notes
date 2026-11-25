import 'package:chat/auth/chat/data/direct_messages/chat_message_body_codec.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webrtc_call/webrtc_call.dart';

void main() {
  test('a text stays plain text on the wire', () {
    expect(ChatMessageBodyCodec.encode(const ChatText('Hello')), 'Hello');
    expect(ChatMessageBodyCodec.decode('Hello'), const ChatText('Hello'));
  });

  test('a call invite survives a round trip', () {
    const invite = ChatCallInvite(callId: 'c1', media: CallMedia.audio);

    final wire = ChatMessageBodyCodec.encode(invite);

    expect(wire, '{"type":"call_invite","call_id":"c1","media":"audio"}');
    expect(ChatMessageBodyCodec.decode(wire), invite);
  });

  for (final (notice, wire) in [
    (const ChatCallDecline('c1'), '{"type":"call_decline","call_id":"c1"}'),
    (const ChatCallCancel('c1'), '{"type":"call_cancel","call_id":"c1"}'),
  ]) {
    test('$wire survives a round trip', () {
      expect(ChatMessageBodyCodec.encode(notice), wire);
      expect(ChatMessageBodyCodec.decode(wire), notice);
    });
  }

  for (final plaintext in [
    '{"note":"just JSON someone typed"}',
    '{"type":"call_invite","call_id":"c1","media":"hologram"}',
    '{"type":"call_invite","call_id":"","media":"video"}',
    '{not json',
  ]) {
    test('$plaintext reads as text', () {
      expect(ChatMessageBodyCodec.decode(plaintext), ChatText(plaintext));
    });
  }
}
