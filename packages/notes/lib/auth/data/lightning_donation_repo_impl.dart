import 'package:common/data/zap/lightning_donation_repo.dart';
import 'package:common/data/zap/perform_lighting_invoice_service.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

final class LightningDonationRepoImpl implements LightningDonationRepo {
  final SessionUsecase _sessionUsecase;
  final RelaysListRepo _relaysListRepo;
  final PerformLightingInvoiceService _performLightingInvoiceService;

  LightningDonationRepoImpl({
    required SessionUsecase sessionUsecase,
    required RelaysListRepo relaysListRepo,
    required PerformLightingInvoiceService performLightingInvoiceService,
  }) : _sessionUsecase = sessionUsecase,
       _relaysListRepo = relaysListRepo,
       _performLightingInvoiceService = performLightingInvoiceService;

  @override
  Future<String> getInvoice({required int sats}) async {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) throw const AppError.notAuthenticated();

    final relays = _relaysListRepo.getRelaysList();

    final result = await _performLightingInvoiceService.execute(
      PerformLightingPaymentUsecaseParams(
        lightningAddress: AppConfig.kDevLightningAddress,
        satsAmount: sats,
        keys: keys,
        relays: relays,
        recepientPubKey: AppConfig.kDevNostrPubkey,
        additionalTags: const [
          [TagValue.client, AppConfig.appId],
        ],
      ),
    );

    return result.invoice;
  }
}
