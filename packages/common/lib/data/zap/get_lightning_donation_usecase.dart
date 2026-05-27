import 'package:common/data/zap/fetch_lightning_donation_usecase.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr_notes/core/event_kind.dart';

final class GetLightningDonationUsecase {
  const GetLightningDonationUsecase({required RawEventStore eventStore})
    : _eventStore = eventStore;

  final RawEventStore _eventStore;

  Stream<List<ZapConfirmation>> execute({
    required String eventATag,
    required String eventPubkey,
  }) {
    return _eventStore
        .watchEvents(
          RawEventQuery(
            kinds: const [NostrKind.zapConfirmation],
            tagFilters: [
              if (eventATag.isNotEmpty) TagFilter(TagValue.a, [eventATag]),
              if (eventPubkey.isNotEmpty) TagFilter(TagValue.p, [eventPubkey]),
            ],
          ),
        )
        .map((events) => events.map((e) => ZapConfirmation(e)).toList());
  }
}
