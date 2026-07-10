import 'dart:async';

import 'package:nostr/model/base_nostr_event.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_event_eose.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/nostr_client.dart';

final class AsyncFetcher {
  final NostrClient _client;

  AsyncFetcher({required NostrClient client}) : _client = client;

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

      if (event is NostrEvent) {
        events[event.id] = event;
      } else if (event is NostrEventEose &&
          event.subscriptionId == subscriptionId) {
        eoseRelays.add(event.relay);

        switch (policy) {
          case ReturnFirstPolicy():
            complete(null);
          case WaitForAllPolicy():
            if (eoseRelays.length >= relayCount) {
              complete(null);
            }
        }
      }
    });

    subscriptionId = _client.sendRequestToAll(req);

    if (policy case WaitForAllPolicy(:final timeout)) {
      timer = Timer(timeout, () => complete(AsyncFetchError.timoutError));
    }

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
  const AsyncFetchPolicy();
}

final class ReturnFirstPolicy extends AsyncFetchPolicy {
  const ReturnFirstPolicy();
}

final class WaitForAllPolicy extends AsyncFetchPolicy {
  final Duration timeout;
  const WaitForAllPolicy({this.timeout = const Duration(seconds: 3)});
}

enum AsyncFetchError { timoutError }
