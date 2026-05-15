// import 'package:nostr/model/nostr_event.dart';
// import 'package:nostr/model/nostr_filter.dart';
// import 'package:nostr_notes/core/event_kind.dart';
// import 'package:nostr_notes/core/tools/now.dart';

// final class CheckListingDonationUsecase {
//   const CheckListingDonationUsecase({
//     required NostrClientInterface nostrClient,
//     required NostrLoader nostrLoader,
//     Now now = const Now(),
//   }) : _now = now;
//   final NostrClientInterface _nostrClient;
//   final Now _now;

//   Future<ZapConfirmation> execute({
//     required String eventATag,
//     required String eventPubkey,
//     required String invoiceEventId,
//     required String payerPubKey,
//     timeout = const Duration(minutes: 5),
//   }) async {
//     const payerTag = '#P';
//     final stream = _nostrClient.queryEvents(
//       filters: [
//         NostrFilter(
//           kinds: const [NostrKind.zapConfirmation],
//           a: [eventATag],
//           p: [eventPubkey],
//           additional: {
//             payerTag: [payerPubKey],
//           },
//           since: _now.now(),
//         ),
//       ],
//       relays: _nostrClient.relays,
//       onEose: (relay, eose) {},
//     );

//     final zapConfirmEvent = await stream.stream
//         .where((e) {
//           if (e.kind != NostrKind.zapConfirmation) {
//             return false;
//           }

//           final targetEventAuthor = e.getFirstTag(TagValue.p);

//           if (targetEventAuthor != eventId.pubkey) {
//             return false;
//           }

//           final payetPubkey = e.getFirstTag('P');

//           if (payetPubkey != payerPubKey) {
//             return false;
//           }

//           final description = e.getFirstTag('description');

//           return description != null && description.contains(invoiceEventId);
//         })
//         .timeout(timeout)
//         .first;

//     _nostrClient.closeREQ(stream.subscriptionId);

//     return ZapConfirmation(zapConfirmEvent);
//   }
// }

// final class ZapConfirmation {
//   const ZapConfirmation(this.event);
//   final NostrEvent event;
// }
