import 'dart:convert';

import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:webrtc_call/webrtc_call.dart';

/// The NIP-44 plaintext of a direct message: a text as is, anything else as a
/// JSON object with a `type`.
abstract final class ChatMessageBodyCodec {
  static const _callInviteType = 'call_invite';
  static const _callDeclineType = 'call_decline';
  static const _callCancelType = 'call_cancel';

  static String encode(ChatMessageBody body) => switch (body) {
    ChatText(:final text) => text,
    ChatCallInvite(:final callId, :final media) => jsonEncode({
      'type': _callInviteType,
      'call_id': callId,
      'media': media.name,
    }),
    ChatCallDecline(:final callId) => _encodeNotice(_callDeclineType, callId),
    ChatCallCancel(:final callId) => _encodeNotice(_callCancelType, callId),
  };

  static String _encodeNotice(String type, String callId) =>
      jsonEncode({'type': type, 'call_id': callId});

  /// A plaintext that is not one of our JSON bodies is a text, so messages
  /// from before structured bodies keep reading as they were.
  static ChatMessageBody decode(String plaintext) =>
      _decodeStructured(plaintext) ?? ChatText(plaintext);

  static ChatMessageBody? _decodeStructured(String plaintext) {
    if (!plaintext.startsWith('{')) return null;
    final Object? json;
    try {
      json = jsonDecode(plaintext);
    } on FormatException {
      return null;
    }
    return switch (json) {
      {
        'type': _callInviteType,
        'call_id': final String callId,
        'media': final String media,
      }
          when callId.isNotEmpty =>
        switch (CallMedia.values.asNameMap()[media]) {
          final CallMedia media => ChatCallInvite(callId: callId, media: media),
          null => null,
        },
      {'type': _callDeclineType, 'call_id': final String callId}
          when callId.isNotEmpty =>
        ChatCallDecline(callId),
      {'type': _callCancelType, 'call_id': final String callId}
          when callId.isNotEmpty =>
        ChatCallCancel(callId),
      _ => null,
    };
  }
}
