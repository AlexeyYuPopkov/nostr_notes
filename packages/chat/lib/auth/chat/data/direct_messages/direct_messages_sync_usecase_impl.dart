import 'dart:async';

import 'package:chat/auth/chat/domain/usecase/direct_messages_sync_usecase.dart';
import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:collection/collection.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:common/services/outbox/outbox_publisher.dart';
import 'package:common/tools/disposable.dart';
import 'package:nostr/model/nostr_event_with_relay.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:rxdart/rxdart.dart';

import 'direct_message_tags.dart';

/// Both directions of relay traffic for direct messages: a live REQ that
/// fills the store, and the outbox that delivers what was written to it.
final class DirectMessagesSyncUsecaseImpl
    implements DirectMessagesSyncUsecase, Disposable {
  static const _batchWindow = Duration(milliseconds: 100);

  /// Relays may hold back or reorder events; re-asking a little before the
  /// newest stored one costs only duplicates the store ignores.
  static const _sinceOverlap = Duration(days: 1);

  final SessionUsecase _sessionUsecase;
  final NostrClient _client;
  final RelaysListRepo _relaysListRepo;
  final RawEventStore _eventStore;
  final OutboxPublisher _outboxPublisher;

  Stream<Never>? _running;
  String? _subscriptionId;

  DirectMessagesSyncUsecaseImpl({
    required this._sessionUsecase,
    required this._client,
    required this._relaysListRepo,
    required this._eventStore,
    required this._outboxPublisher,
  });

  @override
  Stream<Never> execute() {
    final pubkey = _sessionUsecase.currentSession.pubkey;
    if (pubkey.isEmpty) {
      return const Stream.empty();
    }
    return _running ??= _run(pubkey);
  }

  /// Shared while listened to. A shared stream is done for good once its last
  /// listener leaves, so the next [execute] builds a new one.
  Stream<Never> _run(String pubkey) {
    return _session(pubkey).doOnCancel(() => _running = null).share();
  }

  Stream<Never> _session(String pubkey) {
    final incoming = _client
        .stream()
        .whereType<NostrEventWithRelay>()
        .where((event) => _isDirectMessageOf(event, pubkey))
        .bufferTime(_batchWindow)
        .where((events) => events.isNotEmpty)
        .asyncMap(_eventStore.upsert);

    // A REQ lives on the relays connected when it was sent.
    final subscribe = _client.relaysListStream
        .where((relays) => relays.isNotEmpty)
        .distinct(const SetEquality<String>().equals)
        .asyncMap((_) => _subscribe(pubkey));

    return Rx.merge([incoming, subscribe])
        .doOnListen(() {
          _client.syncRelays(_relaysListRepo.getRelaysList());
          unawaited(_outboxPublisher.init());
        })
        .doOnCancel(_closeSubscription)
        .ignoreElements();
  }

  static bool _isDirectMessageOf(NostrEventWithRelay event, String pubkey) {
    return event.kind == NostrKind.directMessage &&
        (event.pubkey == pubkey || DirectMessageTags.peerOf(event) == pubkey);
  }

  Future<void> _subscribe(String pubkey) async {
    final since = await _since(pubkey);
    _closeSubscription();
    _subscriptionId = _client.sendRequestToAll(
      NostrReq(
        filters: [
          NostrFilter(
            kinds: const [NostrKind.directMessage],
            authors: [pubkey],
            since: since,
          ),
          NostrFilter(
            kinds: const [NostrKind.directMessage],
            p: [pubkey],
            since: since,
          ),
        ],
      ),
    );
  }

  Future<int?> _since(String pubkey) async {
    final newest = await Future.wait([
      _eventStore.queryEvents(
        DirectMessageTags.sentBy(pubkey).copyWith(limit: 1),
      ),
      _eventStore.queryEvents(
        DirectMessageTags.receivedBy(pubkey).copyWith(limit: 1),
      ),
    ]);
    final newestCreatedAt = newest.flattened.map((e) => e.createdAt).maxOrNull;
    if (newestCreatedAt == null) {
      return null;
    }
    return newestCreatedAt - _sinceOverlap.inSeconds;
  }

  void _closeSubscription() {
    final id = _subscriptionId;
    if (id != null) {
      _client.sendCloseForAll(id);
      _subscriptionId = null;
    }
  }

  @override
  Future<void> dispose() async {
    _closeSubscription();
    _running = null;
  }
}
