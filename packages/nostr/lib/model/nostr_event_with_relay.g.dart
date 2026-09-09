// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nostr_event_with_relay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NostrEventWithRelay _$NostrEventWithRelayFromJson(Map<String, dynamic> json) =>
    NostrEventWithRelay(
      kind: (json['kind'] as num?)?.toInt() ?? 999999,
      id: json['id'] as String? ?? '',
      pubkey: json['pubkey'] as String? ?? '',
      createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map(
                (e) => (e as List<dynamic>).map((e) => e as String).toList(),
              )
              .toList() ??
          [],
      content: json['content'] as String? ?? '',
      sig: json['sig'] as String? ?? '',
      relay: json['relay'] as String? ?? '',
      subscriptionId: json['subscriptionId'] as String? ?? '',
    );

Map<String, dynamic> _$NostrEventWithRelayToJson(
  NostrEventWithRelay instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'id': instance.id,
  'pubkey': instance.pubkey,
  'created_at': instance.createdAt,
  'tags': instance.tags,
  'content': instance.content,
  'sig': instance.sig,
  'relay': instance.relay,
  'subscriptionId': instance.subscriptionId,
};
