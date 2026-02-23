import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_close.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';
import 'package:nostr_notes/services/nostr_client/nostr_relay.dart';
import 'package:rxdart/rxdart.dart';

import 'publish_event_report.dart';

final class SingleRelayPublisher {
  static const defaultWindow = Duration(seconds: 2);
  final NostrRelay relay;
  final NostrEvent event;
  final Duration window;

  SingleRelayPublisher({
    required this.relay,
    required this.event,
    this.window = defaultWindow,
  });

  final _set = <String>{};
  bool _isCompleted = false;

  bool get isCompleted => _isCompleted;

  Future<PublishEventReport> execute() async {
    if (_isCompleted) {
      throw Exception('PublishEvent can be executed only once');
    }
    final result = await _publishEventToAll(event);
    _isCompleted = true;
    return result;
  }

  Future<PublishEventReport> _publishEventToAll(NostrEvent event) async {
    _set.add(relay.url);
    assert(_set.isNotEmpty, 'No relays to publish to');

    final List<NostrEventOk> okEvents = [];
    final List<NostrEventClose> closeEvents = [];

    final eventId = event.id;

    final sendFuture = relay.eventStream
        .map((e) {
          if (e is NostrEventOk) {
            if (e.eventId == eventId) {
              _set.remove(e.relay);
              okEvents.add(e);
            }
          }

          if (e is NostrEventClose) {
            if (e.subscriptionId == eventId) {
              _set.remove(e.relay);
              closeEvents.add(e);
            }
          }

          if (_set.isEmpty) {
            return event;
          } else {
            return null;
          }
        })
        .whereNotNull()
        .take(1)
        .first;

    relay.sendEvent(event);

    final result = await Future.any([
      sendFuture,
      Future.delayed(defaultWindow),
    ]);

    // client.sendCloseForAll(subscriptionId);

    if (result is NostrEvent) {
      return PublishEventReport(
        events: okEvents,
        close: closeEvents,
        exceededTimeout: null,
        event: result,
      );
    } else {
      return PublishEventReport(
        events: okEvents,
        close: closeEvents,
        exceededTimeout: defaultWindow,
        event: event,
      );
    }
  }
}
