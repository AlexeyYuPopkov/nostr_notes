import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nostr_notes/services/model/base_nostr_event.dart';

export 'tag/nostr_event_tags.dart';

part 'nostr_event.g.dart';

@immutable
@JsonSerializable()
final class NostrEvent extends BaseNostrEvent {
  @override
  EventType get eventType => EventType.event;

  static const dummyKind = 999999;
  @JsonKey(name: 'kind', defaultValue: NostrEvent.dummyKind)
  final int kind;
  @JsonKey(name: 'id', defaultValue: '')
  final String id;
  @JsonKey(name: 'pubkey', defaultValue: '')
  final String pubkey;
  @JsonKey(name: 'created_at', defaultValue: 0)
  final int createdAt;
  @JsonKey(name: 'tags', defaultValue: [])
  final List<List<String>> tags;
  @JsonKey(name: 'content', defaultValue: '')
  final String content;
  @JsonKey(name: 'sig', defaultValue: '')
  final String sig;

  const NostrEvent({
    required this.kind,
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.tags,
    required this.content,
    required this.sig,
  });

  factory NostrEvent.fromJson(Map<String, dynamic> json) =>
      _$NostrEventFromJson(json);

  Map<String, dynamic> toJson() => _$NostrEventToJson(this);

  @override
  String toString() => jsonEncode(toJson());

  String serialized() {
    final result = jsonEncode([
      EventType.event.type,
      toJson(),
    ]);

    return result;
  }
}
