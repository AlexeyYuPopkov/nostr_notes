import 'dart:async';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:rxdart/rxdart.dart';

import 'fetch_lightning_payment_params.dart';
import 'zap_request_description.dart';

final class FetchLightningDonationUsecase {
  const FetchLightningDonationUsecase({
    required NostrClient nostrClient,
    required RawEventStore eventStore,
  }) : _nostrClient = nostrClient,
       _eventStore = eventStore;

  final NostrClient _nostrClient;
  final RawEventStore _eventStore;

  Stream<NostrEvent> execute(FetchLightningPaymentParams params) {
    assert(
      params.hasRequiredTags,
      'At least one of the parameters should be provided',
    );
    if (!params.hasRequiredTags) {
      return const Stream.empty();
    }
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
                eventPubkey: params.eventPubkey,
                invoiceEventId: params.invoiceEventId,
                payerPubKey: params.payerPubKey,
                clientTagValue: params.clientTagValue,
              ),
            )
            .doOnData((event) => _eventStore.upsert([event]))
            .listen(controller.add, onError: controller.addError);

        final req = NostrReq(
          filters: [
            NostrFilter(
              kinds: const [NostrKind.zapConfirmation],
              a: params.eventATag.isNotEmpty ? [params.eventATag] : null,
              p: params.eventPubkey.isNotEmpty ? [params.eventPubkey] : null,
              // additional: params.payerPubKey.isNotEmpty
              //     ? {
              //         '#P': [params.payerPubKey],
              //       }
              //     : null,
            ),
          ],
        );

        subscriptionId = _nostrClient.sendRequestToAll(req);
      },
      onCancel: () async {
        await sub.cancel();
        _nostrClient.sendCloseForAll(subscriptionId);
      },
    );

    return controller.stream.where(
      (event) => _isValidZap(
        event,
        eventPubkey: params.eventPubkey,
        invoiceEventId: params.invoiceEventId,
        payerPubKey: params.payerPubKey,
        clientTagValue: params.clientTagValue,
      ),
    );
  }

  bool _isValidZap(
    NostrEvent e, {
    required String eventPubkey,
    required String invoiceEventId,
    required String payerPubKey,
    required String clientTagValue,
  }) {
    if (e.kind != NostrKind.zapConfirmation) {
      return false;
    }

    final pTag = e.getFirstTagStr(TagValue.p);
    if (eventPubkey.isNotEmpty && (pTag == null || pTag != eventPubkey)) {
      return false;
    }

    final descriptionMap = ZapRequestDescription.parseFromReceipt(e);

    if (descriptionMap == null) {
      return false;
    }

    if (descriptionMap['pubkey'] != payerPubKey) {
      return false;
    }

    if (!ZapRequestDescription.hasClientTag(descriptionMap, clientTagValue)) {
      return false;
    }

    return ZapRequestDescription.matchesInvoiceId(
      descriptionMap,
      invoiceEventId,
    );
  }
}
