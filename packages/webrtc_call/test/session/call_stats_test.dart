import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_call/src/session/call_stats.dart';

List<StatsReport> _reports({required int sent, required int received}) => [
  StatsReport('T', 'transport', 0, {'selectedCandidatePairId': 'P'}),
  StatsReport('P', 'candidate-pair', 0, {
    'localCandidateId': 'L',
    'currentRoundTripTime': 0.042,
    'bytesSent': sent,
    'bytesReceived': received,
  }),
  StatsReport('L', 'local-candidate', 0, {'candidateType': 'relay'}),
];

void main() {
  test('bitrates come from the bytes moved since the last snapshot', () {
    final before = CandidatePairSnapshot.read(_reports(sent: 0, received: 0));
    final after = CandidatePairSnapshot.read(
      _reports(sent: 125000, received: 250000),
    )!;

    expect(
      after.since(before, const Duration(seconds: 1)),
      const CallStats(
        localCandidateType: 'relay',
        roundTripTime: Duration(milliseconds: 42),
        outgoingKbps: 1000,
        incomingKbps: 2000,
      ),
    );
  });

  test('the first snapshot has no bitrates yet', () {
    final first = CandidatePairSnapshot.read(_reports(sent: 1, received: 1))!;

    final stats = first.since(null, Duration.zero);

    expect(stats.outgoingKbps, isNull);
    expect(stats.localCandidateType, 'relay');
  });

  test('falls back to the nominated pair without a transport report', () {
    final snapshot = CandidatePairSnapshot.read([
      StatsReport('P', 'candidate-pair', 0, {
        'state': 'succeeded',
        'nominated': true,
        'localCandidateId': 'L',
      }),
      StatsReport('L', 'local-candidate', 0, {'candidateType': 'srflx'}),
    ]);

    expect(snapshot?.localCandidateType, 'srflx');
  });
}
