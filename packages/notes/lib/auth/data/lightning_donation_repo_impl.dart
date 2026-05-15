import 'package:common/data/zap/fetch_user_zapper_service.dart';
import 'package:common/data/zap/lightning_donation_repo.dart';
import 'package:common/data/zap/perform_lighting_invoice_usecase.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

final class LightningDonationRepoImpl implements LightningDonationRepo {
  final SessionUsecase _sessionUsecase;
  final RelaysListRepo _relaysListRepo;

  late final _usecase = PerformLightingInvoiceUsecase(
    fetchUserZapperService: const FetchUserZapperService(),
    zapEventCreator: const ZapEventCreator(eventCreator: NostrEventCreator()),
  );

  LightningDonationRepoImpl({
    required SessionUsecase sessionUsecase,
    required RelaysListRepo relaysListRepo,
  }) : _sessionUsecase = sessionUsecase,
       _relaysListRepo = relaysListRepo;

  @override
  Future<String> getInvoice({required int sats}) async {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) throw const AppError.notAuthenticated();

    final relays = _relaysListRepo.getRelaysList();

    final result = await _usecase.execute(
      PerformLightingPaymentUsecaseParams(
        lightningAddress: AppConfig.kDevLightningAddress,
        satsAmount: sats,
        keys: keys,
        relays: relays,
        recepientPubKey: AppConfig.kDevNostrPubkey,
      ),
    );

    return result.invoice;
  }
}
