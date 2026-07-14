import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_nostr_event.dart';
import 'nostr_event.dart';

export 'tag/nostr_event_tags.dart';

part 'nostr_event_with_relay.g.dart';

@immutable
@JsonSerializable()
final class NostrEventWithRelay extends NostrEvent {
  @override
  EventType get eventType => EventType.event;
  @JsonKey(name: 'relay', defaultValue: '')
  final String relay;
  @JsonKey(name: 'subscriptionId', defaultValue: '')
  final String subscriptionId;

  const NostrEventWithRelay({
    required super.kind,
    required super.id,
    required super.pubkey,
    required super.createdAt,
    required super.tags,
    required super.content,
    required super.sig,
    required this.relay,
    required this.subscriptionId,
  });

  // factory NostrEventWithRelay.fromJson(Map<String, dynamic> json) =>
  //     _$NostrEventWithRelayFromJson(json);

  factory NostrEventWithRelay.fromJsonWithRelay(
    Map<String, dynamic> json,
    String relay,
    String subscriptionId,
  ) => _$NostrEventWithRelayFromJson({
    ...json,
    'relay': relay,
    'subscriptionId': subscriptionId,
  });

  @override
  Map<String, dynamic> toJson() => _$NostrEventWithRelayToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
