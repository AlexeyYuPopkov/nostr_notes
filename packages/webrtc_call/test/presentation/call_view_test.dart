import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webrtc_call/webrtc_call.dart';

import '../tools/fake_web_rtc.dart';

const _peerName = 'Bob';

void main() {
  late FakeSignaling signaling;
  late FakePlatform platform;
  late PeerConnectionSession session;

  setUp(() async {
    signaling = FakeSignaling();
    platform = FakePlatform();
    session = PeerConnectionSession(
      signaling: signaling,
      selfId: 'alice',
      iceServers: const [],
      platform: platform,
    );
  });

  Future<void> startIncomingCall(WidgetTester tester, CallMedia media) async {
    await tester.runAsync(() async {
      await session.initialize();
      signaling.receive(
        SignalingOffer(
          from: 'bob',
          to: 'alice',
          sessionId: 'bob-alice',
          media: media,
          description: const SessionDescription(sdp: 'sdp', type: 'offer'),
        ),
      );
      await pumpEventQueue();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: CallView(session: session, peerName: _peerName),
      ),
    );
  }

  tearDown(() async {
    await session.dispose();
    await signaling.dispose();
  });

  testWidgets('an audio call shows the peer name and state, no video', (
    tester,
  ) async {
    await startIncomingCall(tester, CallMedia.audio);

    expect(find.text(_peerName), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('Connecting…'), findsOneWidget);
    expect(find.byType(CallVideoView), findsNothing);
    expect(find.byTooltip('Switch camera'), findsNothing);
  });

  testWidgets('a video call shows the remote video and the local preview', (
    tester,
  ) async {
    await startIncomingCall(tester, CallMedia.video);

    expect(find.byType(CallVideoView), findsNWidgets(2));
    expect(find.byTooltip('Switch camera'), findsOneWidget);
  });

  testWidgets('the state follows the call phase', (tester) async {
    await startIncomingCall(tester, CallMedia.audio);

    platform.peerConnection.onConnectionState?.call(
      RTCPeerConnectionState.RTCPeerConnectionStateConnected,
    );
    await tester.pump();

    expect(find.text('Connected'), findsOneWidget);
  });

  testWidgets('the mute button toggles the microphone', (tester) async {
    await startIncomingCall(tester, CallMedia.audio);

    await tester.tap(find.byTooltip('Mute'));
    await tester.pump();

    expect(session.microphoneMuted.value, isTrue);
    expect(find.byTooltip('Unmute'), findsOneWidget);
  });

  testWidgets('the hang-up button ends the call', (tester) async {
    await startIncomingCall(tester, CallMedia.audio);

    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Hang up'));
      await pumpEventQueue();
    });
    await tester.pump();

    expect(session.lastEndReason.value, CallEndReason.hungUp);
    expect(find.text('Call ended'), findsOneWidget);
  });

  testWidgets('shows the candidate type of the connected call when asked', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await session.initialize();
      signaling.receive(
        const SignalingOffer(
          from: 'bob',
          to: 'alice',
          sessionId: 'bob-alice',
          media: CallMedia.audio,
          description: SessionDescription(sdp: 'sdp', type: 'offer'),
        ),
      );
      await pumpEventQueue();
      platform.peerConnection.stats = [
        StatsReport('T', 'transport', 0, {'selectedCandidatePairId': 'P'}),
        StatsReport('P', 'candidate-pair', 0, {'localCandidateId': 'L'}),
        StatsReport('L', 'local-candidate', 0, {'candidateType': 'relay'}),
      ];
      platform.peerConnection.onConnectionState?.call(
        RTCPeerConnectionState.RTCPeerConnectionStateConnected,
      );
      await pumpEventQueue();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CallView(
          session: session,
          peerName: _peerName,
          showsCandidateType: true,
        ),
      ),
    );

    expect(find.text('Connected · relay'), findsOneWidget);
  });
}
