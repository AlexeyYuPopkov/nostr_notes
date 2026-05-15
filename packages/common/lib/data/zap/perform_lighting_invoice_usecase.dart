// import 'package:common/domain/error/app_error.dart';
// import 'package:equatable/equatable.dart';
// import 'package:nostr/model/nostr_event.dart';
// import 'package:nostr/model/nostr_filter.dart';
// import 'package:nostr_notes/core/event_kind.dart';
// import 'package:nostr_notes/core/tools/now.dart';

// final class PerformLightingInvoiceUsecase {
//   // const PerformLightingInvoiceUsecase({
//   //   FetchUserZapperService fetchUserZapperService =
//   //       const FetchUserZapperService(),
//   //   required SessionInteractor sessionInteractor,
//   //   required RelayListProvider relayListProvider,
//   //   NostrEventCreator nostrEventCreator = const NostrEventCreator(),
//   // }) : _fetchUserZapperService = fetchUserZapperService,
//   //      _sessionInteractor = sessionInteractor,
//   //      _relayListProvider = relayListProvider,
//   //      _nostrEventCreator = nostrEventCreator;
//   // final FetchUserZapperService _fetchUserZapperService;
//   // final SessionInteractor _sessionInteractor;
//   // final RelayListProvider _relayListProvider;
//   // final NostrEventCreator _nostrEventCreator;

//   Future<PerformLightingInvoiceResult> execute(
//     PerformLightingPaymentUsecaseParams params,
//   ) async {
//     if (params.lightningAddress.isEmpty) {
//       throw AppError.common(message: 'User does not have a lightning address');
//     }

//     if (params.eventId.isValid == false) {
//       throw AppError.common(message: 'Invalid event address');
//     }

//     final zapper = await _fetchUserZapperService.fetchUserZapper(
//       params.lightningAddress,
//     );

//     if (zapper == null) {
//       throw AppError.common(message: 'Failed to fetch zapper data');
//     }

//     final keys = _sessionInteractor.currentSessionState.keys;

//     if (keys is EmptyKeychain) {
//       throw const AppError.noAuth();
//     }

//     final maxSendable = zapper.maxSendable;
//     final amountToSend = params.satsAmount * 1000;

//     if (maxSendable != null && amountToSend > maxSendable) {
//       throw AppError.common(
//         message: 'The amount is above the maximum of $maxSendable sats',
//       );
//     }

//     // if (params.satsAmount < (zapper.minSendable ?? 0)) {
//     //   throw AppError.common(
//     //     message:
//     //         'The amount is below the minimum of ${zapper.minSendable ?? 0} sats',
//     //   );
//     // }

//     final event = _nostrEventCreator.zapInvoice(
//       zapper: zapper,
//       keys: keys,
//       relays: _relayListProvider.getRelays().toSet().toList(),
//       sats: params.satsAmount,
//       lnurl: zapper.originalLnurl,
//       zappedEventAddress: params.eventId,
//       recipientPubKey: params.eventId.pubkey,
//       additionalTags: [
//         [
//           'exchange_info',
//           params.exchangeInfo.amount.toString(),
//           params.exchangeInfo.currency,
//         ],
//       ],
//     );

//     final invoiceEventId = event.id;

//     if (invoiceEventId.isEmpty) {
//       throw AppError.common(message: 'Failed to create the invoice event');
//     }

//     final invoice = await _fetchUserZapperService.getInvoice(
//       zapper: zapper,
//       sats: params.satsAmount,
//       event: event,
//     );

//     if (invoice == null) {
//       throw AppError.common(message: 'failedToGetInvoice'.tr());
//     }

//     final createdAtSeconds = event.createdAt.millisecondsSinceEpoch ~/ 1000;

//     return PerformLightingInvoiceResult(
//       invoice: invoice,
//       invoiceEvent: event,
//       payerPubKey: event.pubkey,
//       createdAtSeconds: createdAtSeconds,
//     );
//   }
// }

// final class PerformLightingInvoiceResult {
//   PerformLightingInvoiceResult({
//     required this.invoice,
//     required this.invoiceEvent,
//     required this.payerPubKey,
//     required this.createdAtSeconds,
//   });
//   final String invoice;
//   final NostrEvent invoiceEvent;
//   final String payerPubKey;
//   final int createdAtSeconds;
// }

// final class PerformLightingPaymentUsecaseParams extends Equatable {
//   // final Now now;
//   // final Random64HexChars random;

//   const PerformLightingPaymentUsecaseParams({
//     required this.lightningAddress,
//     required this.satsAmount,
//     required this.exchangeInfo,
//     required this.eventId,
//     // this.now = const Now(),
//     // this.random = const Random64HexChars(),
//   });

//   factory PerformLightingPaymentUsecaseParams.withUser({
//     required EventAddress eventId,
//     required UserInfoBase user,
//     required int satsAmount,
//     required Amount exchangeInfo,
//     // Now now = const Now(),
//     // Random64HexChars random = const Random64HexChars(),
//   }) {
//     return PerformLightingPaymentUsecaseParams(
//       lightningAddress: user.lightningAddress ?? '',
//       satsAmount: satsAmount,
//       exchangeInfo: exchangeInfo,
//       eventId: eventId,
//       // now: now,
//       // random: random,
//     );
//   }
//   final String lightningAddress;
//   final int satsAmount;
//   final Amount exchangeInfo;
//   final EventAddress eventId;

//   @override
//   List<Object?> get props => [
//     lightningAddress,
//     satsAmount,
//     eventId,
//     exchangeInfo,
//   ];
// }

// extension on UserInfoBase {
//   String? get lightningAddress {
//     final lud06 = this.lud06?.toLowerCase();
//     final lud16 = this.lud16?.toLowerCase();

//     if (lud06 == null && lud16 == null) {
//       return null;
//     }
//     return (lud06 ?? lud16 ?? '').trim();
//   }
// }
