import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_close.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';

final class PublishEventReport {
  const PublishEventReport({
    required this.okEvents,
    required this.close,
    required this.exceededTimeout,
    required this.event,
  });

  final Duration? exceededTimeout;
  final List<NostrEventOk> okEvents;
  final List<NostrEventClose> close;
  final NostrEvent event;

  bool get isSuccess => okEvents.map((e) => e.isOk).every((e) => e);
  bool get isAnySuccess => okEvents.map((e) => e.isOk).any((e) => e);

  PublishError? get error {
    if (okEvents.isEmpty) {
      return NotPublished(exceededTimeout);
    } else if (close.isNotEmpty) {
      return PartialPublish(exceededTimeout);
    } else {
      return null;
    }
  }
}

sealed class PublishError implements Exception {
  const PublishError();
}

final class NotPublished extends PublishError {
  const NotPublished(this.exceededTimeout);
  final Duration? exceededTimeout;
  String get message => 'Not published to any relay';
}

final class PartialPublish extends PublishError {
  const PartialPublish(this.exceededTimeout);
  final Duration? exceededTimeout;
  String get message => 'Published to some relays only';
}
