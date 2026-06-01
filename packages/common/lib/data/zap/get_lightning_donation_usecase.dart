import 'package:common/data/zap/fetch_lightning_payment_params.dart';
import 'package:common/data/zap/zap_confirmation_dto.dart';
import 'package:common/data/zap/zap_request_description.dart';
import 'package:common/domain/model/zap_confirmation.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr_notes/core/event_kind.dart';

final class GetLightningDonationUsecase {
  const GetLightningDonationUsecase({required RawEventStore eventStore})
    : _eventStore = eventStore;

  final RawEventStore _eventStore;

  Stream<List<ZapConfirmation>> execute({
    required FetchLightningPaymentParams params,
    // required String eventATag,
    // required String eventPubkey,
    // String clientTagValue = '',
  }) {
    return _eventStore
        .watchEvents(
          RawEventQuery(
            kinds: const [NostrKind.zapConfirmation],
            tagFilters: [
              if (params.eventATag.isNotEmpty)
                TagFilter(TagValue.a, [params.eventATag]),
              if (params.eventPubkey.isNotEmpty)
                TagFilter(TagValue.p, [params.eventPubkey]),
            ],
          ),
        )
        .map(
          (events) => events
              .where((event) {
                final descriptionMap = ZapRequestDescription.parseFromReceipt(
                  event,
                );
                return ZapRequestDescription.hasClientTag(
                  descriptionMap,
                  params.clientTagValue,
                );
              })
              .toList(growable: false),
        )
        .map((events) => events.map(ZapConfirmationMapper.map).toList());
  }
}
