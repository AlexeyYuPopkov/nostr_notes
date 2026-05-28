import 'package:common/data/zap/fetch_user_zapper_service.dart';
import 'package:common/data/zap/zapper.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:equatable/equatable.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/now.dart';

final class PerformLightingInvoiceService {
  final FetchUserZapperService _fetchUserZapperService;
  final ZapEventCreator _zapEventCreator;

  PerformLightingInvoiceService({
    required FetchUserZapperService fetchUserZapperService,
    required ZapEventCreator zapEventCreator,
  }) : _zapEventCreator = zapEventCreator,
       _fetchUserZapperService = fetchUserZapperService;

  Future<PerformLightingInvoiceResult> execute(
    PerformLightingPaymentUsecaseParams params,
  ) async {
    if (params.lightningAddress.isEmpty) {
      throw const AppError.common(
        message: 'User does not have a lightning address',
      );
    }

    final zapper = await _fetchUserZapperService.fetchUserZapper(
      params.lightningAddress,
    );

    if (zapper == null) {
      throw const AppError.common(message: 'Failed to fetch zapper data');
    }

    final maxSendable = zapper.maxSendable;
    final amountToSend = params.satsAmount * 1000;

    if (maxSendable != null && amountToSend > maxSendable) {
      throw AppError.common(
        message: 'The amount is above the maximum of $maxSendable sats',
      );
    }

    final event = _zapEventCreator.zapInvoice(
      zapper: zapper,
      keys: params.keys,
      relays: params.relays.toSet().toList(),
      sats: params.satsAmount,
      lnurl: zapper.originalLnurl,
      zappedEventAddress: null,
      recipientPubKey: params.recepientPubKey,
      additionalTags: params.additionalTags,
    );

    final invoiceEventId = event.id;

    if (invoiceEventId.isEmpty) {
      throw const AppError.common(
        message: 'Failed to create the invoice event',
      );
    }

    final invoice = await _fetchUserZapperService.getInvoice(
      zapper: zapper,
      sats: params.satsAmount,
      event: event,
    );

    if (invoice == null || invoice.isEmpty) {
      throw const AppError.common(
        message: 'Failed to get the invoice from the zapper',
      );
    }

    return PerformLightingInvoiceResult(
      invoice: invoice,
      invoiceEvent: event,
      payerPubKey: event.pubkey,
      createdAtSeconds: event.createdAt,
    );
  }
}

final class PerformLightingInvoiceResult {
  PerformLightingInvoiceResult({
    required this.invoice,
    required this.invoiceEvent,
    required this.payerPubKey,
    required this.createdAtSeconds,
  });
  final String invoice;
  final NostrEvent invoiceEvent;
  final String payerPubKey;
  final int createdAtSeconds;
}

final class PerformLightingPaymentUsecaseParams extends Equatable {
  final String lightningAddress;
  final int satsAmount;
  final UserKeys keys;
  final Set<String> relays;
  final String recepientPubKey;
  final List<List<String>>? additionalTags;

  const PerformLightingPaymentUsecaseParams({
    required this.lightningAddress,
    required this.satsAmount,
    required this.keys,
    required this.relays,
    required this.recepientPubKey,
    this.additionalTags,
  });

  @override
  List<Object?> get props => [
    lightningAddress,
    satsAmount,
    keys,
    relays,
    recepientPubKey,
    additionalTags,
  ];
}

final class ZapEventCreator {
  final Now _now;
  final NostrEventCreator _eventCreator;

  const ZapEventCreator({
    required NostrEventCreator eventCreator,
    Now now = const Now(),
  }) : _now = now,
       _eventCreator = eventCreator;

  NostrEvent zapInvoice({
    required UserDataZapper zapper,
    required UserKeys keys,
    required List<String> relays,
    required int sats,
    required String lnurl,
    required String recipientPubKey,
    List<List<String>>? additionalTags,
    List<String>? refernceEventIds,
    List<String>? zappedEventAddress,
  }) {
    assert(recipientPubKey.isNotEmpty, 'Recipient pubkey cannot be empty');
    assert(lnurl.isNotEmpty, 'LNURL cannot be empty');
    assert(relays.isNotEmpty, 'Relays list cannot be empty');

    assert(
      zapper.callback != null,
      'Zapper callback URL cannot be null for lightning address ${zapper.originalLnurl}',
    );
    final ev = _eventCreator.createEvent(
      kind: NostrKind.zapInvoice,
      pubkey: keys.publicKey,
      privateKey: keys.privateKey,
      content: '',
      createdAt: _now.now(),
      tags: [
        ['relays', ...relays],
        ['amount', (sats * 1000).toString()],
        ['lnurl', lnurl],
        ['p', recipientPubKey],

        if (refernceEventIds != null && refernceEventIds.isNotEmpty)
          for (var refernceEventId in refernceEventIds) ['e', refernceEventId],
        if (zappedEventAddress != null && zappedEventAddress.isNotEmpty)
          for (var zappedEventAddress in zappedEventAddress)
            [TagValue.a, zappedEventAddress],
        if (additionalTags != null && additionalTags.isNotEmpty)
          ...additionalTags,
      ],
    );
    // jsonEncode(ev.toMap());
    return ev;
  }
}
