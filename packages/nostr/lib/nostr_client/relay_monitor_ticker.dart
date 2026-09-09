import 'dart:async';
import 'dart:developer';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/nostr_client.dart';

/// Periodically nudges every currently-configured relay over the client's
/// own existing connections, so an otherwise-idle relay still produces a
/// signal (at minimum an EOSE) for [NostrClient.delegate] to observe —
/// without opening any dedicated probe sockets of its own. A relay that's
/// actually down surfaces through the client's normal error/reconnect path
/// ([NostrRelay.sendRequest] already retries via `_recover()`), so there's
/// no separate timeout/health state to track here.
final class RelayMonitorTicker {
  // `until: 1` (1970-01-01T00:00:01Z) can't match any real event, so every
  // probe gets EOSE and nothing else — that's all a liveness signal needs.
  // sendRequestToAll rides the client's own [NostrClient.stream()], the
  // same stream NotesRepositoryImpl upserts everything from without
  // filtering by subscription; an unconstrained filter here would leak
  // arbitrary third-party events into local storage on every tick.
  static const _probeReq = NostrReq(
    filters: [NostrFilter(kinds: _probeKinds, limit: 1, until: 1)],
  );
  static const _probeKinds = [0, 1, 4, 7, 10002];

  final NostrClient _client;
  final Duration interval;

  Timer? _timer;

  RelayMonitorTicker({
    required NostrClient client,
    this.interval = const Duration(seconds: 15),
  }) : _client = client;

  void start() {
    _timer?.cancel();
    _probe();
    _timer = Timer.periodic(interval, (_) => _probe());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    stop();
  }

  void _probe() {
    _client.sendRequestToAll(_probeReq);
    log('RelayMonitorTicker - Probe', name: 'RelayMonitorTicker');
  }
}
