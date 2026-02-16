import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_close.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';
import 'package:nostr_notes/services/nostr_client/nostr_client.dart';
import 'package:rxdart/rxdart.dart';

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

// extension ToNostrEventVariantMapper on TriblyNostrEvent {
//   NostrEvent toTriblyNostrEvent() {
//     return NostrEvent(
//       id: id,
//       kind: kind,
//       content: content ?? '',
//       sig: sig ?? '',
//       pubkey: pubkey,
//       tags: tags,
//       createdAt: createdAt.millisecondsSinceEpoch ~/ 1000,
//     );
//   }
// }

final class PublishEventReport {
  const PublishEventReport({
    required this.events,
    required this.close,
    required this.exceededTimeout,
    required this.event,
  });

  final Duration? exceededTimeout;
  final List<NostrEventOk> events;
  final List<NostrEventClose> close;
  final NostrEvent event;

  PublishError? get error {
    if (events.isEmpty) {
      return NotPublished(exceededTimeout: exceededTimeout);
    }

    final failed = events.where((e) => !e.isOk).toList();
    if (failed.length == events.length) {
      return NotPublished(exceededTimeout: exceededTimeout, failed: failed);
    } else if (failed.isNotEmpty || close.isNotEmpty) {
      return PartialPublish(exceededTimeout: exceededTimeout, failed: failed);
    }

    return null;
  }
}

sealed class PublishError implements Exception {
  const PublishError({this.exceededTimeout, this.failed = const []});
  final Duration? exceededTimeout;
  final List<NostrEventOk> failed;

  String get failedMessages =>
      failed.map((e) => '${e.relay}: ${e.message}').join('; ');
}

final class NotPublished extends PublishError {
  const NotPublished({super.exceededTimeout, super.failed});

  @override
  String toString() => failed.isEmpty
      ? 'Not published to any relay'
      : 'Not published: $failedMessages';
}

final class PartialPublish extends PublishError {
  const PartialPublish({super.exceededTimeout, super.failed});

  @override
  String toString() => failed.isEmpty
      ? 'Published to some relays only'
      : 'Partial publish: $failedMessages';
}
