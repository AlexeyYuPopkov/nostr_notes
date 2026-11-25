import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_call/webrtc_call.dart';

import '../tools/fake_web_rtc.dart';

const _self = 'alice';
const _peer = 'bob';
const _outgoingSessionId = '$_self-$_peer';
const _incomingSessionId = '$_peer-$_self';
const _remoteSdp = SessionDescription(sdp: 'remote-sdp', type: 'answer');
const _candidate = IceCandidate(
  candidate: 'candidate:1',
  sdpMid: '0',
  sdpMLineIndex: 0,
);

void main() {
  late FakeSignaling signaling;
  late FakePlatform platform;
  late PeerConnectionSession session;

  setUp(() async {
    signaling = FakeSignaling();
    platform = FakePlatform();
    session = PeerConnectionSession(
      signaling: signaling,
      selfId: _self,
      iceServers: const [],
      platform: platform,
    );
    await session.initialize();
  });

  tearDown(() async {
    await session.dispose();
    await signaling.dispose();
  });

  Future<void> peersOnline(Set<String> ids) async {
    signaling.receive(
      SignalingPeers({
        for (final id in ids) SignalingPeer(id: id, name: id, userAgent: ''),
      }),
    );
    await pumpEventQueue();
  }

  Future<void> receive(SignalingMessage message) async {
    signaling.receive(message);
    await pumpEventQueue();
  }

  group('outgoing call', () {
    test('waits until the callee is online before sending the offer', () async {
      await peersOnline({_self});

      await session.call(_peer, media: CallMedia.video);

      expect(session.phase.value, CallPhase.calling);
      expect(signaling.sent.whereType<SignalingOffer>(), isEmpty);

      await peersOnline({_self, _peer});

      expect(signaling.sent.whereType<SignalingOffer>().single.to, _peer);
    });

    test('sends the offer right away when the callee is online', () async {
      await peersOnline({_self, _peer});

      await session.call(_peer, media: CallMedia.video);

      final offer = signaling.sent.whereType<SignalingOffer>().single;
      expect(offer.sessionId, _outgoingSessionId);
      expect(offer.media, CallMedia.video);
    });

    test('an audio call asks for no camera and offers audio', () async {
      await peersOnline({_self, _peer});

      await session.call(_peer, media: CallMedia.audio);

      expect(platform.mediaConstraints.single['video'], isFalse);
      expect(
        signaling.sent.whereType<SignalingOffer>().single.media,
        CallMedia.audio,
      );
    });

    test('the answer moves the call to connecting', () async {
      await peersOnline({_self, _peer});
      await session.call(_peer, media: CallMedia.video);

      await receive(_answer());

      expect(session.phase.value, CallPhase.connecting);
      expect(platform.peerConnection.remoteDescription?.sdp, _remoteSdp.sdp);
    });

    test('ends with noAnswer when the callee never comes online', () async {
      await peersOnline({_self});

      await session.call(
        _peer,
        media: CallMedia.video,
        answerTimeout: const Duration(milliseconds: 10),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(session.phase.value, CallPhase.idle);
      expect(session.lastEndReason.value, CallEndReason.noAnswer);
      expect(signaling.sent, isEmpty);
      expect(platform.peerConnection.isClosed, isTrue);
      expect(platform.localStream.isStopped, isTrue);
    });

    test(
      'ends with noAnswer and a bye when the offer is not answered',
      () async {
        await peersOnline({_self, _peer});

        await session.call(
          _peer,
          media: CallMedia.video,
          answerTimeout: const Duration(milliseconds: 10),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(session.lastEndReason.value, CallEndReason.noAnswer);
        expect(
          signaling.sent.last,
          const SignalingBye(sessionId: _outgoingSessionId),
        );
      },
    );

    test('an answer in time cancels the noAnswer timeout', () async {
      await peersOnline({_self, _peer});
      await session.call(
        _peer,
        media: CallMedia.video,
        answerTimeout: const Duration(milliseconds: 10),
      );

      await receive(_answer());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(session.phase.value, CallPhase.connecting);
    });

    test('the end reason is set by the time the call goes idle', () async {
      await peersOnline({_self});
      await session.call(_peer, media: CallMedia.video);
      CallEndReason? reasonSeenOnIdle;
      session.phase.addListener(() {
        if (session.phase.value == CallPhase.idle) {
          reasonSeenOnIdle = session.lastEndReason.value;
        }
      });

      await session.hangUp();

      expect(reasonSeenOnIdle, CallEndReason.hungUp);
    });

    test('hanging up before the offer sends no bye', () async {
      await peersOnline({_self});
      await session.call(_peer, media: CallMedia.video);

      await session.hangUp();

      expect(signaling.sent, isEmpty);
      expect(session.lastEndReason.value, CallEndReason.hungUp);
    });

    test('ends with remoteHungUp when the callee goes offline', () async {
      await peersOnline({_self, _peer});
      await session.call(_peer, media: CallMedia.video);
      await receive(_answer());

      await peersOnline({_self});

      expect(session.phase.value, CallPhase.idle);
      expect(session.lastEndReason.value, CallEndReason.remoteHungUp);
    });
  });

  group('incoming call', () {
    test('is answered with the offered media', () async {
      await receive(_offer(media: CallMedia.audio));

      expect(platform.mediaConstraints.single['video'], isFalse);
      expect(session.media.value, CallMedia.audio);
      expect(session.peerId.value, _peer);
      expect(
        signaling.sent.whereType<SignalingAnswer>().single.sessionId,
        _incomingSessionId,
      );
    });

    test('is rejected with a bye while in another call', () async {
      await peersOnline({_self, _peer, 'carol'});
      await session.call(_peer, media: CallMedia.video);

      await receive(
        const SignalingOffer(
          from: 'carol',
          to: _self,
          sessionId: 'carol-$_self',
          media: CallMedia.video,
          description: SessionDescription(sdp: 'sdp', type: 'offer'),
        ),
      );

      expect(
        signaling.sent.last,
        const SignalingBye(sessionId: 'carol-$_self'),
      );
      expect(session.peerId.value, _peer);
    });
  });

  test('a call the peer declined ends without a bye', () async {
    await peersOnline({_self});
    await session.call(_peer, media: CallMedia.video);

    await session.declinedByPeer();

    expect(session.phase.value, CallPhase.idle);
    expect(session.lastEndReason.value, CallEndReason.declined);
    expect(signaling.sent, isEmpty);
  });

  group('awaiting an accepted call', () {
    test('answers the offer of the awaited peer', () async {
      session.awaitCall(_peer, media: CallMedia.audio);
      expect(session.phase.value, CallPhase.connecting);
      expect(platform.mediaConstraints, isEmpty);

      await receive(_offer(media: CallMedia.video));

      expect(
        signaling.sent.whereType<SignalingAnswer>().single.sessionId,
        _incomingSessionId,
      );
      expect(session.media.value, CallMedia.video);
    });

    test('ends with noAnswer and no bye when no offer comes', () async {
      session.awaitCall(
        _peer,
        media: CallMedia.audio,
        offerTimeout: const Duration(milliseconds: 10),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(session.phase.value, CallPhase.idle);
      expect(session.lastEndReason.value, CallEndReason.noAnswer);
      expect(signaling.sent, isEmpty);
    });

    test('rejects an offer from someone else', () async {
      session.awaitCall(_peer, media: CallMedia.audio);

      await receive(
        const SignalingOffer(
          from: 'carol',
          to: _self,
          sessionId: 'carol-$_self',
          media: CallMedia.video,
          description: SessionDescription(sdp: 'sdp', type: 'offer'),
        ),
      );

      expect(signaling.sent, [const SignalingBye(sessionId: 'carol-$_self')]);
      expect(session.peerId.value, _peer);
    });
  });

  group('both sides calling each other', () {
    test(
      'the side with the smaller id keeps calling and drops the offer',
      () async {
        await peersOnline({_self, _peer});
        await session.call(_peer, media: CallMedia.video);
        final sentBefore = signaling.sent.length;

        await receive(_offer(media: CallMedia.video));

        expect(signaling.sent.length, sentBefore);
        expect(session.phase.value, CallPhase.calling);
        expect(session.peerId.value, _peer);
        expect(session.lastEndReason.value, isNull);
      },
    );

    test('the side with the greater id answers the peer instead', () async {
      const smallerPeer = 'aaron';
      await peersOnline({_self, smallerPeer});
      await session.call(smallerPeer, media: CallMedia.audio);
      final ownConnection = platform.peerConnection;

      await receive(
        const SignalingOffer(
          from: smallerPeer,
          to: _self,
          sessionId: '$smallerPeer-$_self',
          media: CallMedia.video,
          description: SessionDescription(sdp: 'offer-sdp', type: 'offer'),
        ),
      );

      expect(ownConnection.isClosed, isTrue);
      expect(signaling.sent.whereType<SignalingBye>(), isEmpty);
      expect(
        signaling.sent.whereType<SignalingAnswer>().single.sessionId,
        '$smallerPeer-$_self',
      );
      expect(session.phase.value, CallPhase.connecting);
      expect(session.media.value, CallMedia.video);
      expect(session.lastEndReason.value, isNull);
    });
  });

  test(
    'candidates that come before the remote description wait for it',
    () async {
      await peersOnline({_self, _peer});
      await session.call(_peer, media: CallMedia.video);

      await receive(
        const SignalingCandidate(
          from: _peer,
          to: _self,
          sessionId: _outgoingSessionId,
          candidate: _candidate,
        ),
      );
      expect(platform.peerConnection.candidates, isEmpty);

      await receive(_answer());

      expect(
        platform.peerConnection.candidates.single.candidate,
        'candidate:1',
      );
    },
  );

  test('the remote bye ends the call with remoteHungUp', () async {
    await receive(_offer(media: CallMedia.video));

    await receive(const SignalingBye(sessionId: _incomingSessionId));

    expect(session.phase.value, CallPhase.idle);
    expect(session.lastEndReason.value, CallEndReason.remoteHungUp);
  });

  test('the connected peer connection moves the call to connected', () async {
    await receive(_offer(media: CallMedia.video));

    platform.peerConnection.onConnectionState?.call(
      RTCPeerConnectionState.RTCPeerConnectionStateConnected,
    );

    expect(session.phase.value, CallPhase.connected);
  });

  test('a failed media request ends the call with failed', () async {
    platform.mediaError = Exception('camera denied');
    await peersOnline({_self, _peer});

    await session.call(_peer, media: CallMedia.video);

    expect(session.lastEndReason.value, CallEndReason.failed);
    expect(session.lastError.value, contains('camera denied'));
    expect(signaling.sent, isEmpty);
  });

  group('call controls', () {
    test('a video call starts on the loudspeaker', () async {
      await receive(_offer(media: CallMedia.video));

      expect(platform.speakerphoneCalls, [true]);
      expect(session.speakerOn.value, isTrue);
    });

    test('an audio call starts on the earpiece', () async {
      await receive(_offer(media: CallMedia.audio));

      expect(platform.speakerphoneCalls, [false]);
      expect(session.speakerOn.value, isFalse);
    });

    test('muting disables the local audio track only', () async {
      await receive(_offer(media: CallMedia.video));

      session.setMicrophoneMuted(true);

      expect(session.microphoneMuted.value, isTrue);
      expect(platform.localStream.audioTrack.enabled, isFalse);
      expect(platform.localStream.videoTrack!.enabled, isTrue);
    });

    test('the next call starts unmuted', () async {
      await receive(_offer(media: CallMedia.audio));
      session.setMicrophoneMuted(true);
      await receive(const SignalingBye(sessionId: _incomingSessionId));

      await receive(_offer(media: CallMedia.audio));

      expect(session.microphoneMuted.value, isFalse);
    });

    test('switching the camera flips the front camera flag', () async {
      await receive(_offer(media: CallMedia.video));

      await session.switchCamera();

      expect(
        platform.switchedCameraTracks.single,
        platform.localStream.videoTrack,
      );
      expect(session.usingFrontCamera.value, isFalse);
    });
  });
}

SignalingAnswer _answer() => const SignalingAnswer(
  from: _peer,
  to: _self,
  sessionId: _outgoingSessionId,
  description: _remoteSdp,
);

SignalingOffer _offer({required CallMedia media}) => SignalingOffer(
  from: _peer,
  to: _self,
  sessionId: _incomingSessionId,
  media: media,
  description: const SessionDescription(sdp: 'offer-sdp', type: 'offer'),
);
