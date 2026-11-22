import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:webrtc_call/src/data/flutter_webrtc_server/flutter_webrtc_server_codec.dart';
import 'package:webrtc_call/webrtc_call.dart';

const _description = SessionDescription(sdp: 'v=0', type: 'offer');
const _candidate = IceCandidate(
  candidate: 'candidate:1 1 udp 2122260223 10.0.0.2 50000 typ host',
  sdpMid: '0',
  sdpMLineIndex: 0,
);

void main() {
  group('decode', () {
    test('peers', () {
      final message = FlutterWebrtcServerCodec.decode(
        '{"type":"peers","data":[{"id":"a","name":"A","user_agent":"ua"},'
        '{"id":"b"},{"name":"no id"}]}',
      );

      expect(
        message,
        SignalingPeers({
          const SignalingPeer(id: 'a', name: 'A', userAgent: 'ua'),
          const SignalingPeer(id: 'b', name: '', userAgent: ''),
        }),
      );
    });

    test('offer', () {
      final message = FlutterWebrtcServerCodec.decode(
        '{"type":"offer","data":{"from":"a","to":"b","session_id":"a-b",'
        '"media":"audio","description":{"sdp":"v=0","type":"offer"}}}',
      );

      expect(
        message,
        const SignalingOffer(
          from: 'a',
          to: 'b',
          sessionId: 'a-b',
          media: CallMedia.audio,
          description: _description,
        ),
      );
    });

    test('offer without media is a video call', () {
      final message = FlutterWebrtcServerCodec.decode(
        '{"type":"offer","data":{"from":"a","to":"b","session_id":"a-b",'
        '"description":{"sdp":"v=0","type":"offer"}}}',
      );

      expect((message! as SignalingOffer).media, CallMedia.video);
    });

    test('candidate', () {
      final message = FlutterWebrtcServerCodec.decode(
        jsonEncode({
          'type': 'candidate',
          'data': {
            'from': 'a',
            'to': 'b',
            'session_id': 'a-b',
            'candidate': {
              'candidate': _candidate.candidate,
              'sdpMid': '0',
              'sdpMLineIndex': 0,
            },
          },
        }),
      );

      expect(
        message,
        const SignalingCandidate(
          from: 'a',
          to: 'b',
          sessionId: 'a-b',
          candidate: _candidate,
        ),
      );
    });

    test('bye as the server forwards it, without from', () {
      final message = FlutterWebrtcServerCodec.decode(
        '{"type":"bye","data":{"session_id":"a-b","to":"b"}}',
      );

      expect(message, const SignalingBye(sessionId: 'a-b'));
    });

    test('error', () {
      final message = FlutterWebrtcServerCodec.decode(
        '{"type":"error","data":{"request":"offer",'
        '"reason":"Peer [x] not found "}}',
      );

      expect(
        message,
        const SignalingError(request: 'offer', reason: 'Peer [x] not found '),
      );
    });

    test('skips keep-alives, leave, malformed and unknown messages', () {
      const ignored = [
        '{}',
        '{"type":"keepalive","data":{}}',
        '{"type":"leave","data":"b"}',
        '{"type":"offer","data":{"from":"a"}}',
        '{"type":"something"}',
        'not json',
      ];

      for (final raw in ignored) {
        expect(FlutterWebrtcServerCodec.decode(raw), isNull, reason: raw);
      }
    });
  });

  group('encode', () {
    test('every client message survives decoding', () {
      const messages = <SignalingMessage>[
        SignalingOffer(
          from: 'a',
          to: 'b',
          sessionId: 'a-b',
          media: CallMedia.video,
          description: _description,
        ),
        SignalingAnswer(
          from: 'b',
          to: 'a',
          sessionId: 'a-b',
          description: SessionDescription(sdp: 'v=0', type: 'answer'),
        ),
        SignalingCandidate(
          from: 'a',
          to: 'b',
          sessionId: 'a-b',
          candidate: _candidate,
        ),
        SignalingBye(sessionId: 'a-b'),
      ];

      for (final message in messages) {
        final encoded = FlutterWebrtcServerCodec.encode(message);
        expect(FlutterWebrtcServerCodec.decode(encoded), message);
      }
    });

    test('new', () {
      final encoded = FlutterWebrtcServerCodec.encodeNew(
        const SignalingPeer(id: 'a', name: 'A', userAgent: 'ua'),
      );

      expect(jsonDecode(encoded), {
        'type': 'new',
        'data': {'id': 'a', 'name': 'A', 'user_agent': 'ua'},
      });
    });

    test('server-only messages are rejected', () {
      expect(
        () => FlutterWebrtcServerCodec.encode(const SignalingPeers({})),
        throwsArgumentError,
      );
    });
  });
}
