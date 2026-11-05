import 'dart:convert';

import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:chat/auth/settings/domain/models/profile_exception.dart';
import 'package:chat/auth/settings/domain/models/profile_fields.dart';
import 'package:chat/auth/settings/domain/usecase/update_profile_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr/nostr_client/nostr_publisher.dart';

import 'profile_events_helper.dart';

/// Kind 0 keys: https://github.com/nostr-protocol/nips/blob/master/24.md#kind-0
abstract final class _ProfileKeys {
  static const name = 'name';
  static const displayName = 'display_name';
  static const picture = 'picture';

  /// NIP-24 deprecated aliases, to be removed when found.
  static const deprecated = {'displayName', 'username'};
}

final class UpdateProfileUsecaseImpl
    with ProfileEventsHelper
    implements UpdateProfileUsecase {
  /// Long enough for the first publish to also wait out a relay's WebSocket
  /// handshake; [NostrPublisher] returns early once every relay replies.
  static const defaultPublishWindow = Duration(seconds: 10);

  final SessionUsecase _sessionUsecase;
  final RawEventStore _eventStore;
  final NostrClient _client;
  final RelaysListRepo _relaysListRepo;
  final NostrEventCreator _eventCreator;
  final DateTime Function() _now;
  final Duration _publishWindow;

  UpdateProfileUsecaseImpl({
    required this._sessionUsecase,
    required this._eventStore,
    required this._client,
    required this._relaysListRepo,
    this._eventCreator = const NostrEventCreator(),
    this._now = DateTime.now,
    this._publishWindow = defaultPublishWindow,
  });

  @override
  Future<void> execute(ProfileFields fields) async {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      throw const ProfileNoSessionException();
    }

    final previous = newestProfileEvent(
      await _eventStore.queryEvents(profileQuery(keys.publicKey)),
    );

    final event = _eventCreator.createEvent(
      kind: NostrKind.user,
      content: jsonEncode(_mergedContent(previous, fields.trimmed())),
      createdAt: _createdAtAfter(previous),
      tags: previous?.tags ?? const [],
      pubkey: keys.publicKey,
      privateKey: keys.privateKey,
    );

    await _eventStore.upsert([event]);
    await _publish(event);
  }

  Future<void> _publish(NostrEvent event) async {
    final relays = _relaysListRepo.getRelaysList();
    if (relays.isEmpty) {
      throw const ProfileNotPublishedException();
    }

    _client.syncRelays(relays);
    final report = await NostrPublisher(
      client: _client,
      event: event,
      window: _publishWindow,
    ).execute();

    if (!report.isAnySuccess) {
      throw const ProfileNotPublishedException();
    }
  }

  /// Relays keep only the newest kind 0, so the new event must be strictly
  /// newer than the stored one even if the device clock is behind.
  DateTime _createdAtAfter(NostrEvent? previous) {
    final now = _now();
    if (previous == null) {
      return now;
    }

    final nowSeconds =
        now.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    if (nowSeconds > previous.createdAt) {
      return now;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      (previous.createdAt + 1) * Duration.millisecondsPerSecond,
    );
  }

  static Map<String, Object?> _mergedContent(
    NostrEvent? previous,
    ProfileFields fields,
  ) {
    final content = _decodeContent(previous)
      ..removeWhere((key, _) => _ProfileKeys.deprecated.contains(key));

    void put(String key, String value) {
      if (value.isEmpty) {
        content.remove(key);
      } else {
        content[key] = value;
      }
    }

    put(_ProfileKeys.name, fields.name);
    put(_ProfileKeys.displayName, fields.displayName);
    put(_ProfileKeys.picture, fields.picture);

    return content;
  }

  static Map<String, Object?> _decodeContent(NostrEvent? event) {
    if (event == null) {
      return {};
    }
    try {
      final decoded = jsonDecode(event.content);
      return decoded is Map<String, Object?> ? {...decoded} : {};
    } on FormatException {
      return {};
    }
  }
}
