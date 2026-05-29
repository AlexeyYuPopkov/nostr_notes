import 'dart:async';
import 'dart:developer';
import 'package:common/data/zap/fetch_lightning_donation_usecase.dart';
import 'package:common/data/zap/get_lightning_donation_usecase.dart';
import 'package:common/domain/model/zap_confirmation.dart';
import 'package:flutter/foundation.dart';
import 'package:nostr_notes/app/app_config.dart';

final class DonateViaLightningVm {
  final FetchLightningDonationUsecase _fetchLightningDonationUsecase;
  final GetLightningDonationUsecase _getLightningDonationUsecase;
  final String _eventATag;
  final String _eventPubkey;
  final String _invoiceEventId;
  final String _payerPubKey;
  final String _clientTagValue;

  StreamSubscription? _getSubscription;
  StreamSubscription? _fetchSubscription;

  final ValueNotifier<int> invoice = ValueNotifier(0);

  DonateViaLightningVm({
    required FetchLightningDonationUsecase fetchLightningDonationUsecase,
    required GetLightningDonationUsecase getLightningDonationUsecase,
    String eventATag = '',
    String eventPubkey = AppConfig.kDevNostrPubkey,
    String invoiceEventId = '',
    String payerPubKey = '',
    String clientTagValue = AppConfig.appId,
  }) : _fetchLightningDonationUsecase = fetchLightningDonationUsecase,
       _getLightningDonationUsecase = getLightningDonationUsecase,
       _eventATag = eventATag,
       _eventPubkey = eventPubkey,
       _invoiceEventId = invoiceEventId,
       _payerPubKey = payerPubKey,
       _clientTagValue = clientTagValue;

  void subscribe() {
    final params = FetchLightningDonationUsecaseParams(
      eventATag: _eventATag,
      eventPubkey: _eventPubkey,
      invoiceEventId: _invoiceEventId,
      payerPubKey: _payerPubKey,
      clientTagValue: _clientTagValue,
    );

    _getSubscription?.cancel();
    _getSubscription = _getLightningDonationUsecase
        .execute(
          eventATag: _eventATag,
          eventPubkey: _eventPubkey,
          clientTagValue: _clientTagValue,
        )
        .listen((zaps) {
          invoice.value = ZapConfirmationSum.fromEvents(zaps).satsAmount;
        });

    if (params.hasRequiredTags) {
      _fetchSubscription?.cancel();
      _fetchSubscription = _fetchLightningDonationUsecase
          .execute(params)
          .listen((e) {
            log(e.toString(), name: 'DonateViaLightningVm');
          });
    }
  }

  Future<void> dispose() => disposeAsync();

  Future<void> disposeAsync() async {
    await _getSubscription?.cancel();
    await _fetchSubscription?.cancel();
    invoice.dispose();
  }
}
