import 'dart:async';
import 'dart:developer';
import 'package:common/data/zap/fetch_lightning_donation_usecase.dart';
import 'package:common/data/zap/fetch_lightning_payment_params.dart';
import 'package:common/data/zap/get_lightning_donation_usecase.dart';
import 'package:common/domain/model/zap_confirmation.dart';
import 'package:flutter/foundation.dart';
import 'package:nostr_notes/app/app_config.dart';

final class DonateViaLightningVm {
  final FetchLightningDonationUsecase _fetchLightningDonationUsecase;
  final GetLightningDonationUsecase _getLightningDonationUsecase;

  StreamSubscription? _getSubscription;
  StreamSubscription? _fetchSubscription;

  final ValueNotifier<int> invoice = ValueNotifier(0);

  DonateViaLightningVm({
    required FetchLightningDonationUsecase fetchLightningDonationUsecase,
    required GetLightningDonationUsecase getLightningDonationUsecase,
    String clientTagValue = AppConfig.appId,
  }) : _fetchLightningDonationUsecase = fetchLightningDonationUsecase,
       _getLightningDonationUsecase = getLightningDonationUsecase;

  void subscribe(FetchLightningPaymentParams params) {
    _getSubscription?.cancel();
    _getSubscription = _getLightningDonationUsecase
        .execute(params: params)
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
