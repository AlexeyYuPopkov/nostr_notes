import 'dart:async';
import 'package:rxdart/rxdart.dart';

import '../model/base_nostr_event.dart';
import '../model/relay_health.dart';
import 'nostr_client.dart';
import 'nostr_client_delegate.dart';
import 'relay_monitor_ticker.dart';

final class RelaysMonitor implements NostrClientDelegate {
  final NostrClient _client;
  final RelayMonitorTicker _ticker;

  RelaysMonitor({
    required NostrClient client,
    Duration tickerInterval = const Duration(seconds: 15),
    RelayMonitorTicker? ticker,
  }) : _client = client,
       _ticker =
           ticker ??
           RelayMonitorTicker(client: client, interval: tickerInterval) {
    _client.delegate = this;
    // BehaviorSubject — replays the current relay set synchronously, so
    // this alone seeds the initial status map too.
    _relaysSub = _client.relaysListStream.listen(_onRelaysChanged);
  }

  final _liveStatus = <String, RelayStatus>{};
  Set<String> _knownUrls = const {};

  late final StreamSubscription<Set<String>> _relaysSub;
  late final _statusSubject = BehaviorSubject<Map<String, RelayStatus>>.seeded(
    const {},
  );

  bool _paused = false;

  /// The client only reports relay activity to its delegate while something
  /// listens to [NostrClient.stream]; the monitor can't rely on another
  /// feature (e.g. notes sync, absent during onboarding) doing so.
  StreamSubscription<BaseNostrEvent>? _activitySub;

  Stream<Map<String, RelayStatus>> get statuses => _statusSubject.stream;

  void _onRelaysChanged(Set<String> urls) {
    _knownUrls = urls;
    for (final removed in _liveStatus.keys.toSet().difference(urls)) {
      _liveStatus.remove(removed);
    }
    if (urls.isEmpty) {
      _stopProbing();
    } else if (!_paused) {
      _startProbing();
    }
    _emit();
  }

  void _startProbing() {
    _activitySub ??= _client.stream().listen((_) {});
    _ticker.start();
  }

  void _stopProbing() {
    _ticker.stop();
    _activitySub?.cancel();
    _activitySub = null;
  }

  @override
  void onRelayActivity(String url) {
    _liveStatus[url] = RelayStatus.connected;
    _emit();
  }

  @override
  void onRelayError(String url, Object error, StackTrace? stackTrace) {
    _liveStatus[url] = RelayStatus.disconnected;
    _emit();
  }

  void _emit() {
    if (_statusSubject.isClosed) return;
    final merged = <String, RelayStatus>{
      for (final url in _knownUrls)
        url: _liveStatus[url] ?? RelayStatus.warning,
    };
    _statusSubject.add(merged);
  }

  /// Stops the periodic ticker (app backgrounded, say) — the real
  /// connection's own signals need no equivalent pause, they simply stop
  /// arriving on their own once whatever uses that connection pauses too.
  void pause() {
    if (_paused) return;
    _paused = true;
    _stopProbing();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    if (_knownUrls.isNotEmpty) {
      _startProbing();
    }
  }

  Future<void> dispose() async {
    await _relaysSub.cancel();
    await _activitySub?.cancel();
    _activitySub = null;
    await _ticker.dispose();
    if (identical(_client.delegate, this)) {
      _client.delegate = null;
    }
    await _statusSubject.close();
  }
}
