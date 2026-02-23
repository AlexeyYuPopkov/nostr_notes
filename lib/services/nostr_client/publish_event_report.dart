import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_close.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';

final class PublishEventReport {
  final Duration? exceededTimeout;
  final List<NostrEventOk> events;
  final List<NostrEventClose> close;
  final NostrEvent event;

  const PublishEventReport({
    required this.events,
    required this.close,
    required this.exceededTimeout,
    required this.event,
  });

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
