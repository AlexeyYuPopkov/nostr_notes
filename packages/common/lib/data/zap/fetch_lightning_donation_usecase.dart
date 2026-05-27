import 'dart:async';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:rxdart/rxdart.dart';

final class FetchLightningDonationUsecase {
  const FetchLightningDonationUsecase({
    required NostrClient nostrClient,
    required RawEventStore eventStore,
    Now now = const Now(),
  }) : _nostrClient = nostrClient,
       _eventStore = eventStore,
       _now = now;

  final NostrClient _nostrClient;
  final Now _now;
  final RawEventStore _eventStore;

  Stream<NostrEvent> execute({
    required String eventATag,
    required String eventPubkey,
    required String invoiceEventId,
    required String payerPubKey,
  }) {
    late final StreamController<NostrEvent> controller;
    late StreamSubscription sub;
    late String subscriptionId;

    controller = StreamController<NostrEvent>(
      onListen: () {
        sub = _nostrClient
            .stream()
            .where(
              (e) => e is NostrEvent && e.kind == NostrKind.zapConfirmation,
            )
            .map((e) => e as NostrEvent)
            .where(
              (e) => _isValidZap(
                e,
                eventPubkey: eventPubkey,
                invoiceEventId: invoiceEventId,
                payerPubKey: payerPubKey,
              ),
            )
            .doOnData((event) => _eventStore.upsert([event]))
            .listen(controller.add, onError: controller.addError);

        subscriptionId = _nostrClient.sendRequestToAll(
          NostrReq(
            filters: [
              NostrFilter(
                kinds: const [NostrKind.zapConfirmation],
                a: [eventATag],
                p: [eventPubkey],
                additional: {
                  '#P': [payerPubKey],
                },
                since: _now.now().millisecondsSinceEpoch ~/ 1000,
              ),
            ],
          ),
        );
      },
      onCancel: () async {
        await sub.cancel();
        _nostrClient.sendCloseForAll(subscriptionId);
      },
    );

    return controller.stream;
  }

  bool _isValidZap(
    NostrEvent e, {
    required String eventPubkey,
    required String invoiceEventId,
    required String payerPubKey,
  }) {
    if (e.kind != NostrKind.zapConfirmation) {
      return false;
    }

    final pTag = e.getFirstTagStr('p');
    if (pTag != eventPubkey) {
      return false;
    }

    final payerTag = e.getFirstTagStr('P');
    if (payerTag != payerPubKey) {
      return false;
    }

    final description = e.getFirstTagStr('description');
    return description != null && description.contains(invoiceEventId);
  }
}
