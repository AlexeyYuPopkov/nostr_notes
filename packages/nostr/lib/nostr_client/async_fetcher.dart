import 'dart:async';

import 'package:nostr/model/base_nostr_event.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_event_eose.dart';
import 'package:nostr/model/nostr_event_with_relay.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/nostr_client.dart';

final class AsyncFetcher {
  final NostrClient _client;

  AsyncFetcher({required this._client});

  Future<ResultWithRelay> fetchEvents({
    required NostrReq req,
    AsyncFetchPolicy policy = const WaitForAllPolicy(),
  }) async {
    final relayCount = _client.count;

    if (relayCount == 0) {
      return const ResultWithRelay(events: {}, error: null);
    }

    final events = <String, NostrEvent>{};
    final completer = Completer<ResultWithRelay>();
    final eoseRelays = <String>{};

    // subscriptionId is set synchronously before any event callbacks fire.
    String? subscriptionId;
    StreamSubscription<BaseNostrEvent>? subscription;
    Timer? timer;

    void complete(Object? error) {
      if (completer.isCompleted) return;
      timer?.cancel();
      completer.complete(
        ResultWithRelay(events: Map.unmodifiable(events), error: error),
      );
    }

    subscription = _client.stream().listen((event) {
      if (completer.isCompleted) return;

      if (event is NostrEventWithRelay &&
          event.subscriptionId == subscriptionId) {
        events[event.id] = event;
      } else if (event is NostrEventEose &&
          event.subscriptionId == subscriptionId) {
        eoseRelays.add(event.relay);

        final everyRelayAnswered = eoseRelays.length >= relayCount;
        switch (policy) {
          case ReturnFirstPolicy():
            if (events.isNotEmpty || everyRelayAnswered) complete(null);
          case WaitForAllPolicy():
            if (everyRelayAnswered) complete(null);
        }
      }
    });

    subscriptionId = _client.sendRequestToAll(req);

    timer = Timer(policy.timeout, () => complete(AsyncFetchError.timoutError));

    final result = await completer.future;
    await subscription.cancel();
    _client.sendCloseForAll(subscriptionId);

    return result;
  }
}

final class ResultWithRelay {
  final Map<String, NostrEvent> events;
  final Object? error;

  const ResultWithRelay({required this.events, required this.error});
}

sealed class AsyncFetchPolicy {
  /// Upper bound on the wait: a relay may never send EOSE.
  final Duration timeout;

  const AsyncFetchPolicy({this.timeout = const Duration(seconds: 3)});
}

/// Completes at the first EOSE once some relay has delivered events, or when
/// every relay has answered. An EOSE from a relay that simply lacks the data
/// does not end the wait.
final class ReturnFirstPolicy extends AsyncFetchPolicy {
  const ReturnFirstPolicy({super.timeout});
}

final class WaitForAllPolicy extends AsyncFetchPolicy {
  const WaitForAllPolicy({super.timeout});
}

enum AsyncFetchError { timoutError }
