import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/nostr_relay.dart';
import 'package:rxdart/rxdart.dart';
import 'model/nostr_req.dart';

final class NostrClient {
  final _relays = <String, NostrRelay>{};

  void addRelay(String url) {
    if (!_relays.containsKey(url)) {
      final relay = NostrRelay(url);
      _relays[url] = relay;
    }
  }

  void removeRelay(String url) {
    final relay = _relays[url];
    relay?.disconnect();
    _relays.remove(url);
  }

  void sendEventToAll(NostrReq req) {
    for (final relay in _relays.values) {
      relay.sendEvent(req);
    }
  }

  Future<void> connect() async {
    await Future.wait([
      for (final relay in _relays.values) relay.connect(),
    ]);
  }

  Stream<NostrEvent> stream() {
    return Rx.merge([
      for (final relay in _relays.values) relay.events,
    ]);
  }

  void disconnect() {
    for (final relay in _relays.values) {
      relay.disconnect();
    }
  }
}
