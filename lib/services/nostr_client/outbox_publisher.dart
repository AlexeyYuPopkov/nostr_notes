// import 'dart:async';
// import 'dart:developer' as dev;

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:tribly/base/contracts/disposable.dart';
// import 'package:tribly/base/contracts/initializable.dart';
// import 'package:tribly/base/contracts/resumable.dart';
// import 'package:tribly/common/domain/nostr_client_factory/nostr_client_factory_interface.dart';
// import 'package:tribly/common/domain/nostr_kind.dart';
// import 'package:tribly/infrastructure/event_store/database/app_database.dart';
// import 'package:tribly/infrastructure/event_store/database/daos/outbox_dao_interface.dart';
// import 'package:tribly/infrastructure/event_store/raw_event_store.dart';
// import 'package:tribly/services/nostr/client/nostr_client_interface.dart';

// /// Interface for the outbox publisher service.
// abstract interface class OutboxPublisherInterface
//     implements Initializable, Disposable, Resumable {}

// /// Watches the outbox table and publishes pending events to Nostr relays.
// ///
// /// This is the "Nostr Adapter" layer that handles outbound sync from SQL → relays.
// /// The app core writes to SQL + outbox, and this service handles the async
// /// publishing in the background.
// class OutboxPublisher implements OutboxPublisherInterface {
//   OutboxPublisher({
//     required OutboxDaoInterface outboxDao,
//     required RawEventStore rawEventStore,
//     required NostrClientFactoryInterface nostrClientFactory,
//   }) : _outboxDao = outboxDao,
//        _rawEventStore = rawEventStore,
//        _nostrClientFactory = nostrClientFactory;

//   final OutboxDaoInterface _outboxDao;
//   final RawEventStore _rawEventStore;
//   final NostrClientFactoryInterface _nostrClientFactory;

//   StreamSubscription<List<OutboxEventData>>? _subscription;
//   NostrClientInterface? _client;
//   bool _isProcessing = false;
//   bool _isPaused = false;
//   bool _isDisposing = false;

//   static const _maxRetries = 5;
//   static const _retryDelays = [
//     Duration(seconds: 5),
//     Duration(seconds: 30),
//     Duration(minutes: 2),
//     Duration(minutes: 10),
//     Duration(minutes: 30),
//   ];

//   @override
//   Future<void> init() async {
//     // Cancel existing subscription to prevent memory leak on app resume
//     await _subscription?.cancel();
//     _isDisposing = false; // Reset in case we're re-initializing after dispose
//     _subscription = _outboxDao.watchPending().listen(_onPendingEvents);
//     dev.log('OutboxPublisher initialized', name: 'OutboxPublisher');
//   }

//   @override
//   Future<void> dispose() async {
//     _isDisposing = true;

//     // Wait for any in-flight operations to complete (with timeout)
//     final timeout = DateTime.now().add(const Duration(seconds: 5));
//     while (_isProcessing && DateTime.now().isBefore(timeout)) {
//       await Future.delayed(const Duration(milliseconds: 50));
//     }

//     if (_isProcessing) {
//       dev.log(
//         'Warning: Disposed while still processing',
//         name: 'OutboxPublisher',
//       );
//     }

//     await _subscription?.cancel();
//     _subscription = null;
//     dev.log('OutboxPublisher disposed', name: 'OutboxPublisher');
//   }

//   @override
//   void pause() {
//     _isPaused = true;
//     _subscription?.pause();
//     dev.log('OutboxPublisher paused', name: 'OutboxPublisher');
//   }

//   @override
//   void resume() {
//     _isPaused = false;
//     _subscription?.resume();
//     // Process any pending events that accumulated while paused
//     _processQueue();
//     dev.log('OutboxPublisher resumed', name: 'OutboxPublisher');
//   }

//   void _onPendingEvents(List<OutboxEventData> pending) {
//     if (pending.isEmpty || _isProcessing || _isPaused) return;
//     _processQueue();
//   }

//   Future<void> _processQueue() async {
//     if (_isProcessing || _isPaused || _isDisposing) return;
//     _isProcessing = true;

//     try {
//       final pending = await _outboxDao.getPending();

//       for (final item in pending) {
//         try {
//           await _publishEvent(item);
//         } catch (e, stackTrace) {
//           // Log error but continue processing remaining events
//           // Error already handled in _handleFailure (marked failed, retry scheduled)
//           dev.log(
//             'Exception processing ${item.eventId}: $e\n$stackTrace',
//             name: 'OutboxPublisher',
//             error: e,
//             stackTrace: stackTrace,
//           );
//           // Explicitly report to Crashlytics since we're not rethrowing
//           try {
//             unawaited(
//               FirebaseCrashlytics.instance.recordError(
//                 e,
//                 stackTrace,
//                 reason:
//                     'OutboxPublisher failed to publish event ${item.eventId}',
//               ),
//             );
//           } catch (_) {
//             // Crashlytics not available (e.g., in tests)
//           }
//         }
//       }
//     } finally {
//       _isProcessing = false;
//     }
//   }

//   Future<void> _publishEvent(OutboxEventData item) async {
//     try {
//       // Mark as broadcasting
//       await _outboxDao.markBroadcasting(item.eventId);

//       // Get the raw event from the store
//       final events = await _rawEventStore.queryEvents(
//         RawEventQuery(ids: [item.eventId]),
//       );

//       if (events.isEmpty) {
//         await _outboxDao.markFailed(item.eventId, 'Event not found in store');
//         dev.log(
//           'Event ${item.eventId} not found in store',
//           name: 'OutboxPublisher',
//         );
//         return;
//       }

//       final event = events.first;

//       // Get or create client
//       _client ??= _nostrClientFactory.create();

//       // Publish to relays
//       final success = await _client!.publish(event);

//       if (success) {
//         await _outboxDao.markSent(
//           item.eventId,
//           confirmedRelays: _client!.relays,
//         );
//         final kindName = _getKindName(event.kind);
//         dev.log(
//           'Published ${item.eventId} ($kindName)',
//           name: 'OutboxPublisher',
//         );
//         // ignore: avoid_print
//         print(
//           '🚀 [OUTBOX] Published $kindName (${item.eventId.substring(0, 8)}...) to ${_client!.relays.length} relays',
//         );
//       } else {
//         await _handleFailure(item, 'Publish returned false');
//       }
//     } catch (e) {
//       await _handleFailure(item, e.toString());
//       rethrow; // Caught at _processQueue level for logging, continues to next event
//     }
//   }

//   Future<void> _handleFailure(OutboxEventData item, String reason) async {
//     final attempts = item.attemptCount + 1;
//     dev.log(
//       'Failed to publish ${item.eventId} (attempt $attempts): $reason',
//       name: 'OutboxPublisher',
//     );

//     if (attempts >= _maxRetries) {
//       await _outboxDao.markFailed(item.eventId, reason);
//     } else {
//       // Reset to pending for retry (the delay is handled by not processing immediately)
//       await _outboxDao.retryFailed(item.eventId);

//       // Schedule retry with backoff
//       final delay = _retryDelays[attempts - 1];
//       Future.delayed(delay, _processQueue);
//     }
//   }

//   /// Manually retry all failed events
//   Future<void> retryAllFailed() async {
//     await _outboxDao.retryAllFailed();
//     _processQueue();
//   }

//   /// Clean up old sent events
//   Future<int> cleanup({Duration olderThan = const Duration(days: 7)}) async {
//     return _outboxDao.cleanupOldSent(olderThan: olderThan);
//   }

//   /// Returns a human-readable name for the event kind
//   String _getKindName(int kind) {
//     return switch (kind) {
//       NostrKind.user => 'profile update',
//       NostrKind.post => 'post',
//       NostrKind.followKind => 'follow list',
//       NostrKind.directMessage => 'direct message',
//       NostrKind.deletionKind => 'deletion',
//       NostrKind.reaction => 'reaction',
//       NostrKind.listingMessage => 'listing message',
//       NostrKind.nip17MsgKind => 'NIP-17 message',
//       NostrKind.listing => 'listing',
//       NostrKind.scheduledEvent => 'scheduled event',
//       NostrKind.community => 'community',
//       NostrKind.communityUpdate => 'community update',
//       NostrKind.communityTopicKind => 'community topic',
//       NostrKind.communityTopicCommentKind => 'topic comment',
//       NostrKind.metadataLabel => 'custom metadata',
//       NostrKind.zapConfirmation => 'zap',
//       NostrKind.zapInvoice => 'zap invoice',
//       NostrKind.muteList => 'mute list',
//       NostrKind.communitiesList => 'communities list',
//       NostrKind.associationsList => 'associations list',
//       NostrKind.donationMethods => 'donation methods',
//       NostrKind.relaysList => 'relays list',
//       NostrKind.interestsLists => 'interests list',
//       NostrKind.listingApprovalRequest => 'listing approval',
//       NostrKind.scheduledEventApprovalRequest => 'event approval',
//       NostrKind.postApprovalRequest => 'post approval',
//       NostrKind.communityTopicApprovalRequest => 'topic approval',
//       NostrKind.applicationSpecificDataKind => 'app data',
//       _ => 'kind $kind',
//     };
//   }
// }

// /// No-op implementation for testing
// class NoopOutboxPublisher implements OutboxPublisherInterface {
//   const NoopOutboxPublisher();

//   @override
//   Future<void> init() async {}

//   @override
//   Future<void> dispose() async {}

//   @override
//   void pause() {}

//   @override
//   void resume() {}

//   Future<void> retryAllFailed() async {}

//   Future<int> cleanup({Duration olderThan = const Duration(days: 7)}) async {
//     return 0;
//   }
// }
