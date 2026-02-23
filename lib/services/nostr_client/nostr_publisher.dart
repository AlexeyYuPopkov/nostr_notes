import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_close.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';
import 'package:nostr_notes/services/nostr_client/nostr_client.dart';
import 'package:rxdart/rxdart.dart';

import 'publish_event_report.dart';

final class NostrPublisher {
  NostrPublisher({
    required this.client,
    required this.event,
    this.window = defaultWindow,
  });
  static const defaultWindow = Duration(seconds: 2);

  final _set = <String>{};
  bool _isCompleted = false;

  final NostrClient client;
  final NostrEvent event;
  final Duration window;

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
    _set.addAll({...client.relays});
    assert(_set.isNotEmpty, 'No relays to publish to');

    final List<NostrEventOk> okEvents = [];
    final List<NostrEventClose> closeEvents = [];

    final eventId = event.id;

    final sendFuture = client
        .stream()
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

    client.sendEventToAll(event);

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
