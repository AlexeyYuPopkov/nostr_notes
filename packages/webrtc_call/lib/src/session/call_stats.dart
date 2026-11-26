import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// How a connected call reaches the peer, for checking the network setup.
final class CallStats extends Equatable {
  /// `host`, `srflx`, `prflx` or `relay` (through TURN).
  final String? localCandidateType;
  final Duration? roundTripTime;
  final int? outgoingKbps;
  final int? incomingKbps;

  const CallStats({
    this.localCandidateType,
    this.roundTripTime,
    this.outgoingKbps,
    this.incomingKbps,
  });

  @override
  List<Object?> get props => [
    localCandidateType,
    roundTripTime,
    outgoingKbps,
    incomingKbps,
  ];
}

/// The selected candidate pair of one `getStats` call.
final class CandidatePairSnapshot {
  static const _bitsPerByte = 8;
  static const _bitsPerKilobit = 1000;

  final String? localCandidateType;
  final Duration? roundTripTime;
  final num? bytesSent;
  final num? bytesReceived;

  const CandidatePairSnapshot({
    this.localCandidateType,
    this.roundTripTime,
    this.bytesSent,
    this.bytesReceived,
  });

  /// Null when no pair is selected yet.
  static CandidatePairSnapshot? read(List<StatsReport> reports) {
    final byId = {for (final report in reports) report.id: report};
    final pair = _selectedPair(reports, byId);
    if (pair == null) return null;
    final values = pair.values;
    final rttSeconds = _number(values['currentRoundTripTime']);
    return CandidatePairSnapshot(
      localCandidateType:
          switch (byId[values['localCandidateId']]?.values['candidateType']) {
            final String type => type,
            _ => null,
          },
      roundTripTime: rttSeconds == null
          ? null
          : Duration(
              microseconds: (rttSeconds * Duration.microsecondsPerSecond)
                  .round(),
            ),
      bytesSent: _number(values['bytesSent']),
      bytesReceived: _number(values['bytesReceived']),
    );
  }

  /// Bitrates since [previous], taken [elapsed] earlier.
  CallStats since(CandidatePairSnapshot? previous, Duration elapsed) =>
      CallStats(
        localCandidateType: localCandidateType,
        roundTripTime: roundTripTime,
        outgoingKbps: _kbps(previous?.bytesSent, bytesSent, elapsed),
        incomingKbps: _kbps(previous?.bytesReceived, bytesReceived, elapsed),
      );

  static int? _kbps(num? before, num? after, Duration elapsed) {
    if (before == null || after == null || elapsed <= Duration.zero) {
      return null;
    }
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    return ((after - before) * _bitsPerByte / _bitsPerKilobit / seconds)
        .round();
  }

  static num? _number(Object? value) => value is num ? value : null;

  /// The transport names the pair in use; older stacks only mark it
  /// nominated and succeeded.
  static StatsReport? _selectedPair(
    List<StatsReport> reports,
    Map<String, StatsReport> byId,
  ) {
    for (final report in reports) {
      if (report.type != 'transport') continue;
      final pair = byId[report.values['selectedCandidatePairId']];
      if (pair != null) return pair;
    }
    for (final report in reports) {
      final values = report.values;
      if (report.type == 'candidate-pair' &&
          values['state'] == 'succeeded' &&
          values['nominated'] == true) {
        return report;
      }
    }
    return null;
  }
}
