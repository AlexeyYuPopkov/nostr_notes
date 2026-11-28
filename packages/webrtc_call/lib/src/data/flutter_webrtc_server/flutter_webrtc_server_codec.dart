import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../../domain/signaling_message.dart';
import 'signaling_dtos.dart';

/// Wire format of flutter-webrtc-server: `{"type": ..., "data": ...}`.
/// Protocol and quirks: doc/webrtc-backend.md §6.2.
abstract final class FlutterWebrtcServerCodec {
  static String encodeNew(SignalingPeer self) =>
      _encode('new', PeerDto.fromDomain(self).toJson());

  /// The server echoes it back, which tells a live socket from a dead one.
  static String encodeKeepalive() => _encode('keepalive', const {});

  static String encode(SignalingMessage message) => switch (message) {
    SignalingOffer() => _encode('offer', {
      ..._negotiation(message),
      'media': message.media.name,
      'description': SessionDescriptionDto.fromDomain(
        message.description,
      ).toJson(),
    }),
    SignalingAnswer() => _encode('answer', {
      ..._negotiation(message),
      'description': SessionDescriptionDto.fromDomain(
        message.description,
      ).toJson(),
    }),
    SignalingCandidate() => _encode('candidate', {
      ..._negotiation(message),
      'candidate': IceCandidateDto.fromDomain(message.candidate).toJson(),
    }),
    SignalingBye() => _encode('bye', {'session_id': message.sessionId}),
    SignalingPeers() || SignalingError() => throw ArgumentError.value(
      message,
      'message',
      'is sent by the server only',
    ),
  };

  /// `null` for keep-alives, `leave` (broken on the server) and anything
  /// unknown or malformed.
  static SignalingMessage? decode(String raw) {
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return null;
    }

    return switch (json) {
      {'type': 'peers', 'data': final List<Object?> peers} => SignalingPeers(
        peers.map(_parsePeer).nonNulls.toSet(),
      ),
      {
        'type': 'offer',
        'data':
            {
              'from': final String from,
              'to': final String to,
              'session_id': final String sessionId,
              'description': final Object? description,
            } &&
            final Map<String, Object?> data,
      } =>
        switch (_parse(description, SessionDescriptionDto.fromJson)) {
          final description? => SignalingOffer(
            from: from,
            to: to,
            sessionId: sessionId,
            media: data['media'] == CallMedia.audio.name
                ? CallMedia.audio
                : CallMedia.video,
            description: description.toDomain(),
          ),
          null => null,
        },
      {
        'type': 'answer',
        'data': {
          'from': final String from,
          'to': final String to,
          'session_id': final String sessionId,
          'description': final Object? description,
        },
      } =>
        switch (_parse(description, SessionDescriptionDto.fromJson)) {
          final description? => SignalingAnswer(
            from: from,
            to: to,
            sessionId: sessionId,
            description: description.toDomain(),
          ),
          null => null,
        },
      {
        'type': 'candidate',
        'data': {
          'from': final String from,
          'to': final String to,
          'session_id': final String sessionId,
          'candidate': final Object? candidate,
        },
      } =>
        switch (_parse(candidate, IceCandidateDto.fromJson)) {
          final candidate? => SignalingCandidate(
            from: from,
            to: to,
            sessionId: sessionId,
            candidate: candidate.toDomain(),
          ),
          null => null,
        },
      {'type': 'bye', 'data': {'session_id': final String sessionId}} =>
        SignalingBye(sessionId: sessionId),
      {
        'type': 'error',
        'data': {
          'request': final String request,
          'reason': final String reason,
        },
      } =>
        SignalingError(request: request, reason: reason),
      _ => null,
    };
  }

  static String _encode(String type, Map<String, Object?> data) =>
      jsonEncode({'type': type, 'data': data});

  static Map<String, Object?> _negotiation(SignalingNegotiation message) => {
    'from': message.from,
    'to': message.to,
    'session_id': message.sessionId,
  };

  static SignalingPeer? _parsePeer(Object? json) =>
      _parse(json, PeerDto.fromJson)?.toDomain();

  static T? _parse<T>(Object? json, T Function(Map<String, Object?>) fromJson) {
    if (json is! Map<String, Object?>) return null;
    try {
      return fromJson(json);
    } on CheckedFromJsonException {
      return null;
    }
  }
}
